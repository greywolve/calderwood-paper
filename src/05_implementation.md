# Implementation

## Dependencies


```clojure
(defproject calderwood "0.1.0-SNAPSHOT"
  :description "Calderwood: An opinionated reference for
                event sourced applications."

  :license {:name "MIT"
            :url  "http://"}

  :dependencies [[org.clojure/clojure "1.9.0-alpha14"]
                 [org.clojure/clojurescript "1.9.293"]
                 [org.clojure/core.async "0.2.385"]
                 [org.clojure/java.classpath "0.2.3"]

                 [http-kit "2.2.0"]
                 [ring/ring-core "1.5.0"]

                 [com.datomic/datomic-free "0.9.5544"
                  :exclusions [com.google.guava/guava]]

                 [io.rkn/conformity "0.4.0"]

                 [bultitude "0.2.8"]

                 [clj-time "0.12.0"]

                 [com.taoensso/timbre       "4.8.0"]

                 [clojurewerkz/scrypt "1.2.0"]

                 [compojure                 "1.5.1"]
                 [hiccup                    "1.0.5"]

                 [rum "0.10.7"]
                 [bidi "2.0.9"]
                 [cljs-http "0.1.42"]]

  :plugins [[lein-cljsbuild "1.1.5"]]

  :profiles {:dev {:dependencies [[org.clojure/tools.namespace "0.2.11"]
                                  [stylefruits/gniazdo "1.0.0"]
                                  [org.hdrhistogram/HdrHistogram "2.1.7"]
                                  [incanter/incanter-core "1.5.6"]
                                  [incanter/incanter-charts "1.5.6"]]
                   :source-paths ["dev" "test"]}}

  :cljsbuild {:builds [{:id           "console-dev"
                        :source-paths ["src/calderwood/console"]
                        :compiler     {:output-to     
                                       "resources/public/js/console.js"
                                       :optimizations :whitespace
                                       :pretty-print  true}}]})
```

## Component system

```clojure
(defrecord DevSystem [datomic
                      local-command-queue
                      ws-channels
                      app-handler
                      http-kit-web-server
                      update-handler
                      command-processor]
  Lifecycle
  (start [component]
    (let [datomic* (start datomic)
          app-handler* (-> app-handler
                           (assoc :datomic datomic*
                                  :ws-channels ws-channels
                                  :command-queue local-command-queue)
                           start)
          http-kit-web-server* (-> http-kit-web-server
                                   (assoc :app-handler app-handler*)
                                   start)
          update-handler (-> update-handler
                             (assoc :datomic datomic*
                                    :ws-channels ws-channels)
                             start)
          command-processor (-> command-processor
                                (assoc :datomic datomic*
                                       :local-command-queue 
                                       local-command-queue)
                                start)]

      (.addShutdownHook (Runtime/getRuntime)
                        (Thread. (fn []
                                   (timbre/info "Shutdown hook")
                                   (stop component))))
      (assoc component
             :datomic datomic*
             :ws-channels ws-channels
             :app-handler app-handler*
             :http-kit-web-server http-kit-web-server*
             :update-handler update-handler
             :command-processor command-processor)))
  (stop [component]
    (timbre/info "Shutting down")
    (assoc component
           :datomic (stop datomic)
           :http-kit-web-server (stop http-kit-web-server)
           :update-hander (stop update-handler)
           :command-processor (stop command-processor))))

(defn dev-system [{:keys [db-uri]}]
  (map->DevSystem {:datomic (temp-datomic db-uri)
                   :ws-channels (ws-channels)
                   :local-command-queue (local-command-queue 1000)
                   :app-handler (app-handler)
                   :http-kit-web-server (http-kit-web-server 8080)
                   :update-handler (update-handler)
                   :command-processor (command-processor)}))

```

## HTTP API endpoints

```clojure
(defn create-handler [datomic command-queue ws-channels]
  (-> (compojure/routes
       (compojure/GET "/console" request (console-handler request))
       (compojure/GET "/ws" request (ws-handler ws-channels
                                                command-queue
                                                request))
       (compojure/POST "/query" request (query-handler request))
       (compojure/GET "/login" request (view-login-handler request))
       (compojure/POST "/login" request (login-handler request))
       (compojure/GET "/logout" request (logout-handler request))
       (compojure.route/resources "/"))
      (wrap-impersonate)
      (wrap-identity)
      (wrap-session)
      (wrap-keyword-params)
      (wrap-params)
      (wrap-components datomic ws-channels)))


(defrecord AppHandler [datomic command-queue ws-channels handler]
  Lifecycle
  (start [component]
    (if-not handler
      (assoc component :handler (create-handler
                                 datomic
                                 command-queue
                                 ws-channels))
      component))
  (stop [component]
    (assoc :handler nil)))

(defn app-handler []
  (map->AppHandler {}))
```

## Authentication and Authorization

```clojure
(defn user-credentials-valid? [db user password]
  (util/password-hash-valid? password
                             (:user/password-digest user)))

(defn create-session-tx-map [user-uuid remote-address]
  {:db/id (d/tempid :db.part/user)
   :session/uuid (d/squuid)
   :session/user [:user/uuid user-uuid]
   :session/remote-address remote-address})

(defn create-session! [conn user-uuid remote-address]
  (let [session-tx-map (create-session-tx-map
                        user-uuid
                        remote-address)
        session-uuid (:session/uuid session-tx-map)
        db-after (:db-after
                  @(d/transact conn [session-tx-map]))]
    (d/entity db-after [:session/uuid session-uuid])))

(defn login-handler [{:keys [db conn params] :as request}]
  (let [{:keys [email password]} params
        email* (-> email
                   (string/lower-case)
                   (string/trim))]
    (if-let [user (d/entity db [:user/email email*])]
      (if (user-credentials-valid? db user password)
        (let [session (create-session! conn
                                       (:user/uuid user)
                                       (:remote-addr request))]
          (-> (ring.response/redirect "/console" :see-other)
              (assoc-in [:session :session-uuid]
                        (:session/uuid session))
              (update :session
                      (fn [s] (vary-meta s assoc :recreate true)))))
        (ring.response/redirect "/login?error=true" :see-other))
      (ring.response/redirect "/login?error=true" :see-other))))

(defn logout-handler [request]
  (-> (ring.response/redirect "/login" :see-other)
      (assoc :session nil)))

(defn wrap-identity [handler]
  (fn [{:keys [db session] :as request}]
    (if-let [session (d/entity db
                               [:session/uuid (:session-uuid session)])]
      (handler (assoc request
                      :identity
                      (-> session :session/user :user/uuid)))
      (handler request))))
```

## Websocket Server

```clojure
(defn ws-handler [ws-channels command-queue request]
  (timbre/debug request)
  (if-let [id (:identity request)]
    (http-kit/with-channel request channel
      (timbre/debug "Websocket channel opened for user id:" id)
      (swap! (:channels ws-channels) assoc id channel)
      (http-kit/on-close
       channel
       (fn [status]
         (timbre/debug "Websocket channel closed for user id:" id)
         (swap! (:channels ws-channels) dissoc id)))
      (http-kit/on-receive
       channel
       (fn [msg]
         (timbre/debug "Received WS message:" msg)
         (let [[tp client-id client-seq data]
               (clojure.edn/read-string msg)]
           (when (and (= tp :cmd)
                      client-id
                      client-seq)
             (let [[ok-or-err cmd err]
                   (-> data
                       (assoc :command/user-uuid id
                              :command/client-id client-id
                              :command/client-seq client-seq)
                       (coerce-command))]
               (if (= :error ok-or-err)
                 (http-kit/send! channel (pr-str [:error
                                                  client-id
                                                  client-seq
                                                  err]))
                 (do (put-command command-queue cmd)
                     (http-kit/send! channel
                                     (pr-str [:cmd-ack
                                              client-id
                                              client-seq]))))))))))
    (not-authorized "Not authorized")))
```

### Command Queue

```clojure
(defprotocol CommandQueue
  (put-command [queue cmd]))

(defrecord LocalCommandQueue [queue]
  CommandQueue
  (put-command [component cmd]
    (.put (:queue component) cmd)))


(defn local-command-queue [buffer-size]
  (LocalCommandQueue.
   (java.util.concurrent.ArrayBlockingQueue. buffer-size)))
```

## Command Processor

```clojure
(defrecord CommandProcessor [local-command-queue datomic running?]
  Lifecycle
  (start [component]
    (reset! running? true)
    (.start
     (Thread.
      (fn []
        (timbre/debug "Starting Command Processor thread...")
        (while @running?
          (try
            (let [conn (d/connect (:db-uri datomic))
                  db (d/db conn)
                  cmd (.poll (:queue local-command-queue)
                             1000
                             java.util.concurrent.TimeUnit/MILLISECONDS)]
              (when cmd
                (timbre/info "Command received:" cmd)
                (let [event-txes (mapv (partial aggregate-event db)
                                       (handle-command db cmd))]

                  (doseq [e-tx event-txes]
                    (timbre/debug "Transacting event:" e-tx)
                    (transact-with-exponential-backoff-retry!
                     conn
                     running?
                     e-tx)))))
            (catch Exception err
              (timbre/error "Exception in Command Processor:" err)))))))
    component)
  (stop [component]
    (reset! running? false)
    component))

(defn command-processor []
  (CommandProcessor. nil nil (atom false)))
```

## Datomic Transaction Retry

```clojure
(defn transact-with-exponential-backoff-retry! [conn running? txes]
  (let [max-backoff-ms 64000
        rand-sleep-ms 1000]
    (loop [backoff-time 1]
      (when @running?
        (or (try @(d/transact conn txes)
                 (catch java.util.concurrent.ExecutionException e
                   ;; Log an application error here, not a good
                   ;; idea to try again since it won't help.
                   (timbre/error e)
                   true)
                 (catch clojure.lang.ExceptionInfo e
                   ;; Log transaction timeout/unavailable here
                   ;; exponential backoff and it might eventually
                   ;; reconnect.
                   (timbre/error e)
                   nil))
            (let [backoff-time (min backoff-time max-backoff-ms)
                  backoff-time* (+ backoff-time
                                   (rand-int rand-sleep-ms))]
              (timbre/warn "Transact failed, retrying again in:"
                           backoff-time*
                           "ms")
              (Thread/sleep backoff-time*)
              (recur (* 2 backoff-time))))))))
```

## Update Handler

```clojure
(def MILLISECONDS java.util.concurrent.TimeUnit/MILLISECONDS)

(defrecord UpdateHandler [ws-channels datomic running?]
  Lifecycle
  (start [component]
    (reset! running? true)
    (.start
     (Thread.
      (fn []
        (timbre/debug "Starting Update Handler thread...")
        (while @running?
          (try
            (let [conn      (d/connect (:db-uri datomic))
                  txr       (d/tx-report-queue conn)
                  tx-report (.poll txr
                                   1000
                                   MILLISECONDS
                                   )]
              (when tx-report
                (timbre/debug "Received update:" tx-report)
                (let [{:keys [db-after tx-data]} tx-report
                      tx (d/t->tx
                          (d/basis-t db-after))
                      {:keys [event/uuid
                              event/name
                              event/data
                              event/meta
                              event/client-id
                              event/client-seq]
                       :as tx-entity} (d/entity db-after tx)]
                  (when (:event/name tx-entity)
                    (timbre/debug "Update transaction entity:"
                                  (d/touch tx-entity))
                    (doseq [channel (vals @(:channels ws-channels))]
                      (http-kit/send!
                       channel
                       (pr-str
                        [:update
                         client-id
                         client-seq
                         {:event/uuid uuid
                          :event/name name
                          :event/data (clojure.edn/read-string data)
                          :event/meta (clojure.edn/read-string meta)
                          :event/client-seq client-seq}])))))))
            (catch Exception err
              (timbre/error "Exception in Update Handler:" err)))))))
    component)
  (stop [component]
    (reset! running? false)
    component))

(defn update-handler []
  (UpdateHandler. nil nil (atom false)))
```

## Query Service

```clojure
(defn query-handler [request]
  (if-let [id (:identity request)]
    (if-let [query (try (util/input-stream->edn (:body request))
                        (catch Exception e
                          (timbre/error "Error parsing query body:" e)
                          nil))]
      (let [[ok-or-error query* :as query-result]
            (coerce-query (assoc query
                                 :query/user [:user/uuid id]))]
        (if (= :error ok-or-error)
          (edn-response query-result)
          (edn-response [:ok (do-query (:db request)
                                       query*)])))
      (bad-request))
    (not-authorized)))
```
