# Testing

## Functionality Testing

## Adding a new command

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

![Login test.](figures/test_login.pdf){#fig:test_login}

### Sending a command

![Send command.](figures/test_send_command.pdf){#fig:test_send_command}

![Send incorrect command.](figures/test_send_command_failed.pdf){#fig:test_send_command_failed}

### Performing a query

![Send query.](figures/test_send_query.pdf){#fig:test_send_query}

![Send incorrect query.](figures/test_query_failed.pdf){#fig:test_send_query_failed}

## Performance Testing

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

![Latency percentile distribution for 320 ops/s.](figures/latency320.pdf){#fig:latency320}

![Latency percentile distribution for 385 ops/s.](figures/latency385.pdf){#fig:latency385}

