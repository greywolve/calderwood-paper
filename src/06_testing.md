# Testing

## Functionality Testing

## Adding a new command

Adding a new command for a visiting a page was simply a case of extending three
multi-methods.

```clojure
(defmethod -coerce-command :visit-page [{:keys [command/data] :as command}]
  (if (and
       (:command/user-uuid command)
       (s/valid? :command.data/visit-page data))
    [:ok command]
    [:error command :command-validation-failed]))

(defmethod -handle-command :visit-page [db {:keys [command/data
                                                   command/meta]
                                              :as command}]
  [(event command :page-view data meta)])
  
  
(defmethod -aggregate-event :page-view [db {:keys [event/data]
                                         :as event}]
  [{:db/id (d/tempid :db.part/user)
    :page-view/url (:page-view/url data)
    :page-view/user (:event/user event)}])
```

## Adding a new query

Adding a query is just as straight forward.

```clojure
(defmethod -coerce-query :list-page-views [query]
  [:ok query])

(defmethod -do-query :list-page-views [db query]
  (->> (d/q '[:find ?p ?tx
              :where [?p :page-view/url _ ?tx]]
            db)
       (mapv (fn [[p tx]]
               (let [{:keys [page-view/url
                             page-view/user]} (d/entity db p)]
                 {:page-view/timestamp (:db/txInstant (d/entity db tx))
                  :page-view/url url
                  :page-view/user (select-keys
                                   user
                                   [:user/uuid
                                    :user/email])})))))
```

### Login

Testing logging in, see [@fig:test_login]

![Login test.](figures/test_login.pdf){#fig:test_login}

### Sending a command

Sending a command using the console. Using a valid command is shown in
[@fig:test_send_command], using an invalid command is shown in
[@fig:test_send_command_failed].

![Send command.](figures/test_send_command.pdf){#fig:test_send_command}

![Send incorrect command.](figures/test_send_command_failed.pdf){#fig:test_send_command_failed}

### Performing a query

Performing a query using the console. Performing a valid query is shown in
[@fig:test_send_query], using an invalid command is shown in [@fig:test_send_query_failed].

![Send query.](figures/test_send_query.pdf){#fig:test_send_query}

![Send incorrect query.](figures/test_query_failed.pdf){#fig:test_send_query_failed}

## Performance Testing

The code used for performance testing is shown below.

```clojure
(def CLIENT-ID "12345")

(defn ws-uri-for-email [email]
  (str "ws://localhost:8080/ws?login-email=" email))

(defn output-results [results]
  (->> results
       (map (fn [{:keys [arrive-ms msg]}]
              (let [[tp _ _ data] (read-string msg)]
                (when (= tp :update)
                  (- arrive-ms
                     (-> data
                         :event/meta
                         :sent-ms))))))
       (remove nil?)
       (output-percentile-distribution)))

(defn run-perf-test [iterations interval-us]
  (let [results (volatile! [])
        latch (java.util.concurrent.CountDownLatch. 1)
        ws-socket (ws/connect
                   (ws-uri-for-email "o@o.com")
                   :on-receive
                   (fn [msg]
                     (let [results
                           (vswap! results
                                   conj
                                   {:arrive-ms (System/currentTimeMillis)
                                    :msg msg})]
                       (when (= (count results) (* 2 iterations))
                         (.countDown latch)))))
        start-ms (System/currentTimeMillis)
        _ (doseq [i (range iterations)]
            (busy-wait interval-us)
            (ws/send-msg ws-socket
                         (pr-str
                          [:cmd CLIENT-ID i
                           {:command/name :visit-page
                            :command/data
                            {:page-view/url "www.example.com"}
                            :command/meta
                            {:sent-ms (System/currentTimeMillis)}}])))
        _ (.await latch)
        ops-per-second
        (int (/  (* iterations 1000)
                 (- (System/currentTimeMillis) start-ms)))]

    {:ops-per-second ops-per-second
     :results @results}))

```

The strategy for the code above is as follows:

-  Establish a Websocket connection using a server-side client Websocket
   library.

-  Initialize a CountDownLatch, which can be used as a barrier for completion.

-  Register the *on-receieve* handler for that connection, and for each message
   that arrives, add it to a Clojure *volatile!* which is essentially a faster
   atom, with less guarantees. We don't need those guarantees though since there
   is a single thread writing to it. Include the arrival time with each message.
   When iterations * 2 messages have been received, issue a count down on the
   latch. We need 2 * iterations here because each send message will have both
   an acknowledgment response, and an update response.

-  Send **iterations** *page-view* messages (10000 in this case) through the
   Websocket connection, using a busy wait function to control throughput, since
   *Thread/sleep* is not fine grained enough.

- Await the CountDownLatch.

- Operations per second are measured based on how long it takes to send all iterations.

- The raw results, together with the operation per second are returned.

The results can then be processed using the HDRHistogram tool, and a percentile
distribution can be obtained. Inspiration for this method was taken from Gil
Tene, of Azul systems (a company that makes it's own proprietary JVM
implementation which doesn't pause during garbage collection), and his excellent
talk on "How NOT to measure latency" given at Strange Loop in 2015. [@51_gil_tene]

We are primarily interested in the max throughput we can achieve while achieving
sub 100ms latencies for the 99.9th percentile.

The maximum stable throughput with the above goal is 320/ops,
and is shown in [@fig:latency320].

Beyond this point we quickly approach latency values way above our target, see
[@fig:latency385].

![Latency percentile distribution for 320 ops/s.](figures/latency320.pdf){#fig:latency320}

![Latency percentile distribution for 385 ops/s.](figures/latency385.pdf){#fig:latency385}

