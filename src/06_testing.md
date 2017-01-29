# Testing

Todo

## Functionality Testing

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

