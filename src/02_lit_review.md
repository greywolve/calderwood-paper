# Literature Review

## Place-orientated Programming

Information consists of facts. A fact is something that is known to happen. It
is precise, immutable and it has a time dimension - it is known to have happened
at a particular point in time.
  
A place is a particular portion of space, used for a particular purpose. In
computer systems this would correlate to an address in memory, or a sector on
disk.

Information systems today generally operate by replacing old information with
new information. A fact is associated with a particular place and new facts
overwrite old facts. Rich Hickey refers to this as place-orientated programming.
[@36_hickey_2012]

This was not always the case. Before computers our information systems were
always accumulating. Accountants do not use erasers, they use double ledger
entry. Places were not important, facts were. This was born out of the
limitations of early computers, but storage capacity has increased a million
fold since then. When the scale of something increases so dramatically, do the
same rules still apply? [@36_hickey_2012]

Place-orientated programming gives us the current view of the world, only the
very newest facts. However, making good decisions tends to require past facts,
in addition to the newer facts. Often to build a coherent picture of the world
requires digging through database logs, a very suboptimal way of finding past
facts. [@36_hickey_2012]

A well designed information system would have first class support for facts and
operate in a very similar fashion to pre-computer record keeping systems.

## CRUD Flavored REST

REST or REpresentational State Transfer is the brain child of Rory Fielding, and
was first described in his doctoral thesis. It is effectively a generalization
of the Web's architectural principles into an architectural style that can
support almost any kind of application.  His work led to a new perspective on
the Web and how it could be used for purposes other than simple information
retrieval and storage. [@22_webber_parastatidis_robinson_2010]

CRUD is an acronym for create, read, update and delete. It defines the four
basic functions of peristant storage. It is currently the dominant way of
modifying resources in a web application, usually exposed via a RESTful
interface. Resources can be created, read, updated and deleted. Web application
frameworks, such as Rails (Ruby), Play (Java), Express (node.js), have
popularised this approach, by providing good support for creation of these end
points. This can be viewed as "CRUD" flavoured REST. [@23_calderwood_2015] 

HTTP Verb  Path                   Used For                 CRUD letter
---------  ----                   -------                  -----------
GET        /articles              List articles            R
POST       /articles              Create a new article     C
GET        /articles/:id          Get article with :id     R
PUT        /articles/:id          Update article with :id  U
DELETE     /articles/:id          Delete article with :id  D

: A typical "CRUD" flavoured REST API {#tbl:crud_rest_api}

CRUD typically gives us only the current view of the world, and emphasizes
place-orientated programming where new facts replace old. Update and delete
cause old facts to be lost. If I update or delete an article in
[@tbl:crud_rest_api] then the past content of that article is essentially lost.
This might not be of great importance in a content based domain, but it could be
very important for a shopping cart.

Steve Yegge wrote an excellent rant against Java (and Object-orientated
programming) and it's over emphasis on nouns rather than verbs. [@26_yegge_2016]
Which makes more sense? Paying your credit card bill by updating a bill
sub-resource of a credit card resource, or simply calling a pay-card-card-bill
API end point? CRUD flavoured REST is really the kingdom of nouns for
distributed systems. [@23_calderwood_2015] The description of what actually
happened is lost in a haze of resources and sub-resources.

Bobby Calderwood lists some other negative aspects of CRUD based REST:
[@23_calderwood_2015]

- It causes a proliferation of HTTP API end points since every resource now
  needs its own path, along with it's CRUD operations. Add sub-resources and the
  problem is further compounded.

 - It burdens the client with resource orchestration. The client now needs to
 deal with resource orchestration, and has to be aware of operational complexity
 that should be hidden within the backend. This detracts from the clients
 responsibility - the user.

- It's difficult to scale since reads and writes are typically coupled together
in the same set of API endpoints.

He also lists some positive aspects: [@23_calderwood_2015]

- Hiring for applications built this way tends to be easier.
- Tooling and support is generally good, so it's easy to get something up into
  production.
- It may be superior for certain domains, for example, domains that are heavily
  content based.
- It may also be a better choice if you cannot afford extra operational costs of
  an added messaging and event tracking system.

## Essential REST

Essential REST exemplifies the heart of REST, and it's good parts. These
include: [@23_calderwood_2015]

- Clear communication semantics for big distributed systems in low-rust,
  low-coordination contexts.
- Proxying and caching of various types of requests over an unknown network path.
- Clear error codes when requests fail.
- Loose coupling from the underlying backend implementation.
- An emphasis on being self describing or ease of consumption, exploration and
  navigation.
- A data orientated approach, requests are responses are just data, and are
  often encoded in formats such as JSON or EDN.

"CRUD" flavored REST is merely one way of building a RESTful API, but it is not
the only way. It is certainly possible to build API end-points which are far
more descriptive and verb orientated, such as "/pay-credit-card-bill" as opposed
to "/credit-card/:id/bill/:id".


## Architecting for Data Science

Data science can be broadly defined as "the transformation of data using
mathematics and statistics into valuable insights, decisions, and products." It
is the same as, or very closely related to terms such as business analytics,
operations research, business intelligence, competitive intelligence, data
analysis and modeling, and knowledge extraction. [@40_foreman_2013] In essence
the purpose of data science is to extract value from data.

Data science enables the creation of data products. This differs from simply
consuming data like many web applications do - data applications directly
acquire their value from the data itself, and create more data as an output. The
quintessential example of this is Google search which was the first search
engine to realize that one could use input data other than text on the page. The
PageRank algorithm that now powers Google search was one of the first to start
using external data, such as the number of inbound links, in order to rank the
page. There are numerous other examples from other companies such as Amazon,
Linkedin etc. [@38_loukides_2010]

It is not just huge companies with massive amounts of data that can benefit from
data science. Increasingly these techniques are being used in smaller sized
datasets too in order to make better decisions in business and other domains.
[@40_foreman_2013]

In CRUD based systems, data science is often an after thought, and generally
logs have to be mined in order to obtain the data necessary to gain insight,
since databases in these systems only store the newest facts. This essentially
creates more barriers to entry for data analysis. [@23_calderwood_2015]

What tends to matter is a system is what your user tried to do, and how you
helped them to do it. CRUD heavy systems tend to obscure these important
details by not storing all the information.

## Event Sourcing

Martin Fowler describes Event Sourcing as follows: [@16_fowler_2005]

> We can query an application's state to find out the current state of the
> world, and this answers many questions. However there are times when we don't
> just want to see where we are, we also want to know how we got there.
>
> Event Sourcing ensures that all changes to application state are stored as a
> sequence of events. Not just can we query these events, we can also use the
> event log to reconstruct past states, and as a foundation to automatically
> adjust the state to cope with retroactive changes.

Event Sourcing is an architectural pattern in which changes to an applications
state are captured as a time ordered series of event objects. It is then
possible to reconstitute the application state, to any point in time, simply by
replaying these events, along with the initial application state. Unlike CRUD
based systems, no data is lost, and Event Sourced applications naturally support
data science. [@23_calderwood_2015]

The history of Event Sourced applications goes back as far the IBM IMS TM
transaction manager which was used as part of an inventory system to manage the
bill of materials for the Apollo space program. The system was capable of 2300
transactions per second, on 1960s hardware, an impressive feat, even by todays
standards. [@19_thompson_2012]

Events describe something that has happened in the past and typically have names
such as UserLoggedIn, OrderShipped, and PageViewed. Events are created by
Commands, which operate in the present tense. For example, UserLogin and
ShipOrder. Once events are created they are essentially immutable facts, that
cannot be changed. [@15_introduction_to_cqrs_server_2015]

Events are stored in an Event Store, which can be implemented in any type of
persistent storage, though a database is always preferable. The Event Store then
acts as the system of record, tracking all changes to the application state over
time. Event Stores are typically optimized for fast time based range queries,
for example, finding all the OrderShipped events between two dates.
[@20_young_2010]

Events are aggregated into derived views, or read models, which can result in
very efficient queries for data later. These aggregates can be rebuilt on the
fly as events are processed and stored. Event Listeners can also be attached,
which perform external actions, such as sending email, or creating assets for
downloading. [@15_introduction_to_cqrs_server_2015]

Event Sourcing hasn't seen mainstream popularity in general, though custom built
Event Sourced applications are popular in the financial industry, especially in
high speed trading. A notable example is the LMAX architecture, which used a
single thread to process incoming trade events with exceptionally low latency
and high throughput. [@17_fowler_2011]

The downsides of Event Sourcing are best found by talking to practitioners that
use it in industry. Some of these are the following:

- Event Sourcing is a different way of thinking about applications, and it may
  be difficult to hire for as a result, as most people wouldn't have worked with
  such an application in the past.
- Versioning of events can be difficult, given that events are immutable. If you
  need to make changes to events that apply retroactively, this is can be quite
  a challenge, and will usually involve correcting events, or rebuilding a new
  event stream, which can be costly if there are millions of events.
- Certain domains are better suited to CRUD based designs, such as content based
  applications, like blogs. If your application does not require you to care
  about past data, and you only need to care about the present moment, then
  Event Sourcing will probably only add complexity to your system.

## CQRS

CQRS or Command and Query Responsibility Segregation is an intimidating acronym
with a very simple meaning - separate your reads from your writes. It was
popularized by Greg Young. [@18_fowler_2011]

In typical CRUD based APIs reading and writing are intertwined. Typically the
same server will serve both updates to resources in addition to queries on them.
Yet in most applications read and write loads are seldom equal.

The simplest reason for CQRS is scaling. If your reads and your writes are
separated then it's possible to independently scale them. If your application is
write heavy you may choose to have more servers servicing writes, likewise, if
your application is more read heavy, you may want to add a few more servers for
queries. [@18_fowler_2011]

Bobby Calderwood suggests a simple way to achieve this, by defining only three
end points. [@tbl:cqrs_endpoints] lists them. Three endpoints greatly simplifies
the HTTP API endpoint proliferation typically experienced in CRUD systems.
[@23_calderwood_2015]

 Path                   Used For 
 ----                   -------- 
 /command               Issuing a command
 /query                 Performing a query (pull)
 /update                Real-time push via WebSockets or SSE

: CQRS HTTP API endpoints {#tbl:cqrs_endpoints}

Martin Fowler advises caution when implementing CQRS, as it can add plenty of
additional, unneeded complexity if the domain it is applied to does not benefit
from it. [@18_fowler_2011] Bobby Calderwood argues that CQRS complexity mostly
occurs when it is applied on the micro level, particularly with OOP principles.
He does not see the same problems occurring when it is applied at the macro
level, i.e HTTP API level, with a functional programming approach.
[@23_calderwood_2015]

## Avoiding the Tarpit

According to Mosely and Marks in their iconic 2006 paper, "Out of the Tarpit",
complexity is the root cause of most problems in software development, because
understanding of the software, they argue, is greatly undermined by complexity.
[@10_moseleymarks_2006]

They categorize complexity into two types, essential and accidental. Essential
complexity is inherent in the problem, whereas accidental complexity is
additional complexity created by the programmer, and orthogonal to solving the
problem at hand. Accidental complexity is the enemy of the programmer.

Complexity in software they argue is primarily caused by mutable state, and
control. It is difficult to keep track of all possible states that a system can
be in. Likewise control is difficult because order is important. If one
statement is incorrectly placed before another then the program is typically
incorrect too.

Object-orientated programming has been one approach to handling this
complexity. However it fails for two primary reasons. OOP conflates the notion
of intensional identity (an object's identity) and extensional identity (the
object's attributes). This increases the number of states which need to be
considered. Secondly each object method accessing the object's state needs to
enforce integrity constraints, it is also akward to enforce multi-object
integrity constraints. OOP also uses traditional flow control structures, and
thus has no solution to taming complexity associated with control.
[@10_moseleymarks_2006]

They further state:

> The bottom line is that all forms of OOP rely on state (contained within
> objects) and in general all behaviour is affected by this state. As a result
> of this, OOP suffers directly from the problems associated with state, and as
> such we believe that it does not provide an adequate foundation for avoiding
> complexity.

Functional programming in it's purest form eschews mutable state and side
effects, and thus avoids much of the complexity associated with state. Higher
level functions such as filter and map, allow a slighly better form of
control, though order still matters to a large degree. The biggest weakness of
functional programming is it's strength too, since all non-trivial programs
require a certain amount of essential state. [@10_moseleymarks_2006]

Mosely and Marks recommend two strategies for dealing with complexity. Avoid
it, accept only essential complexity, and if you can't avoid it, for reasons
of ease of use, or performance, then separate it out in order to better manage
it.

## Service-orientated Architecture and Microservices

Service-orientated architectural or SOA is a design paradigm centered around the
idea of multiple services, which collaborate to provide functionality to the
overall system. Each service is autonomous, and operates as a separate operating
system process. All communication between these services has be occur through a
network protocol, rather than direct method calls within the same process. No
memory is shared directly between services, and each service usually has it's
own database. [@28_newman]

SOA developed as an alternative to large monolithic applications, where
different parts of the application were often tightly coupled, and difficult
replace, or rewrite. SOA aimed to address this by building an application out of
composable services, with strict interface boundaries. [@28_newman]

Microservices emerged from real-world use as one specific way of implementing
SOA. It involves much finer grained services, which focus on a doing single
tasks well. In general the goal for each service is to have a small amount of
code, that is easy to understand, change and maintain. [@28_newman]

Microservices are said to have a number of benefits: [@28_newman]

- They promote technology heterogeneity. Services can be written using any
  language or technology stack. This means that if one part of the system
  require more performance then it's possible to rewrite it later in a faster
  language, or more suitable technology stack.

- Services can be independently scaled. In a large monolithic application,
  everything must scale together, but in a Microservice architecture the
  cardinality of each service is independent.

- Services are optimized for "replaceability". As long as a service maintains its
  interface contract, it's possible to rewrite it, without affecting any other
  parts of the system. 

![Netflix topology](figures/netflix_topology.png){#fig:netflix_topology}

But at the same time, they also have a number of tradeoffs: [@23_calderwood_2015]

- There is an explosion of HTTP API endpoints. A graph of connections between
  Netflix services is shown in [@fig:netflix_topology].
  [@33_netflix_ribbon_2016] So many end points quickly become a nightmare to
  reason about.

- Teams tend to reinvent the wheel constantly. Each service has to solve the
  same set of problems, but often in a different technology stack. Databases,
  cache, deployment, authentication, and authorization to name a few.

- All end points are subtly different, which makes building clients for these
  services more difficult. It creates an additional problem to the front-end
  teams, which now need to be concerned with both user experience, and how to
  orchestrate resources across a large number of varying HTTP API endpoints.


## Stream Processing

Stream processing typically involves processing large amounts of events in
sequential order. These event form an event stream. As new events are generates,
they are added to the stream, which is usually a persistent queue of some type,
that guarantees order, such as Apache Kafka. It is very closely related to Event
Sourcing, and big Internet companies such as Linkedin typically have teams of
data analysts consuming these events in order to improve their products.
[@37_kleppmann_2016]

![Stream Processing [@37_kleppmann_2016]](figures/stream_processing.png){#fig:stream_processing}

Event streams can be consumed by multiple consumers in parallel, and offer a
unidirectional flow of data through the system. As seen in
[@fig:stream_processing] the flow of events can be used to update full-text
search indexes, such as Solr, build read models, rebuild caches, and even
produce new output streams which can be joined with other event streams, or
consumed by other downstream consumers. [@37_kleppmann_2016]

Event streams are often connected to distributed stream processing frameworks,
which attempt to shield developers from the operation complexity of distributing
work across a cluster of machines. Such frameworks include Samza, Storm, Onyx,
Spark, and Flink. [@37_kleppmann_2016]

## Websockets

Todd L. Montgomery gave an excellent talk at React 2014 on the need to embrace
asynchrony in our web applications. He argues that synchronous (or blocking)
calls tend to produce systems that are both coupled, and less performant.
Asynchronous systems allow requests to be processed independently of responses,
which encourages loose coupling. In addition to this, while an asynchronous
request is being made, other work can be done on the client while it waits for a
response. While it is possible to make HTTP requests asynchronously via threads
or callbacks, in practice a large amount of developers tend to wait for a
response in order to do error handling, before continuing. [@27_montgomery_2014]

In the past clients have had to result to solutions such as HTTP long polling in
order to break the coupling between HTTP requests and responses. The HTML5
standard sought to include a better solution to the problem, in the form of the
Websocket Protocol (RFC 6455), which allows a full duplex, bidirectional
connection from client to server. Websockets piggy back on top of the HTTP
protocol, and can be seen as thin layer of abstraction on top the underlying TCP
connection. The results in much higher performance, saving bandwidth, CPU power,
and latency, and making Websockets ideal for real-time, asynchronous
applications. [@5_wang_salim_moskovits_2013]

## CAP Theorem 

Eric Brewer first introduced the CAP Theorem in 2000. The theorem centers around
the idea that there is a fundamental tradeoff between consistency, availability,
and partition tolerance in distributed systems. [@31_gilbertlynch_2012]

An informal definition for consistency is simply that that each server returns
the right response to each request. Right in this context means, correct
according to the desired service specification. [@31_gilbertlynch_2012]

Availability means that each request to a server will eventually receive a
response. [@31_gilbertlynch_2012]

Partition tolerance refers to the underlying system. Networks are unreliable and
it is highly likely that servers are partitioned into groups that cannot
communicate with each other for extended periods of time. [@31_gilbertlynch_2012]

In broad terms the CAP Theorem implies that you can either have a consistent and
partition tolerant system (CP), or a an available and partition tolerant system
(AP). It is impossible to have a CA system, unless that system all within in a
single node, and is not networked. 

Seth and Nancy offer a proof for the CAP Theorem that is
relatively straight forward: [@31_gilbertlynch_2012]

> Consider an execution in which the servers are partitioned into two disjoint
> sets: $\{ p_1 \}$ and $\{ p_2, . . . , p_n \}$. Some client sends a read
> request to server $p2$. Since $p1$ is in a different component of the
> partition from $p2$, every message from $p1$ to $p2$ is lost. Thus, it is
> impossible for $p2$ to distinguish the following two cases: 
>
> - There has been a previous write of value $v1$ requested of $p1$, and $p1$
> has sent an ok response.
>
> - There has been a previous write of value $v2$ requested of $p1$, and $p1$
> has sent an ok response. 
>
> No matter how long $p2$ waits, it cannot distinguish these two cases, and
> hence it cannot determine whether to return response $v1$ or response $v2$. It
> has the choice to either eventually return a response (and risk returning the
> wrong response) or to never return a response.

Event Sourced systems typically favor the AP side of the CAP Theorem, trading
consistency for high availability. [@19_thompson_2012]

## Functional programming

Fogus and Houser provide a workable definition for functional programming:
[@4_fogushouser_2014]

> Whether your own definition of functional programming hinges on the lambda
> calculus, monadic I/O, delegates, or java.lang.Runnable, your basic unit of
> currency is likely some form of procedure, function, or method—herein lies the
> root. Functional programming concerns and facilitates the application and
> composition of functions. Further, for a language to be considered functional,
> its notion of function must be first- class. First-class functions can be
> stored, passed, and returned just like any other piece of data. Beyond this core
> concept, the definitions branch toward infinity; but, thankfully, it’s enough
> to start.

Hughes argues that other functional programming features, such as higher-order
functions, and lazy evaluation, lead to better structured and more modular
programs, with less lines of code and less flow control statements. [@9_hughes_1989]

Functional programming tends to focus on minimizing state by emphasizing the use
of pure functions. Pure functions resemble mathematical functions in the sense
that always return the exact same output, given the same inputs. This is known
as referential transparency. In simpler terms, pure functions do not have side
effects. Programs that consist primarily of pure functions have minimal state,
and are thus easy to reason about and test. [@10_moseleymarks_2006]

## Clojure

A good description of Clojure can be taken from it's website: [@41_clojureorg_2016]

> Clojure is a dynamic, general-purpose programming language, combining the
> approachability and interactive development of a scripting language with an
> efficient and robust infrastructure for multithreaded programming. Clojure is
> a compiled language, yet remains completely dynamic – every feature supported
> by Clojure is supported at runtime. Clojure provides easy access to the Java
> frameworks, with optional type hints and type inference, to ensure that calls
> to Java can avoid reflection.
>
> Clojure is a dialect of Lisp, and shares with Lisp the code-as-data philosophy
> and a powerful macro system. Clojure is predominantly a functional programming
> language, and features a rich set of immutable, persistent data structures.
> When mutable state is needed, Clojure offers a software transactional memory
> system and reactive Agent system that ensure clean, correct, multithreaded
> designs.

Clojure has seen steady industry adoption in the last few years, and continues
to gain popularity. It has been marked as "Adopt" on the ThoughtWorks technology
radar since October 2012. [@42_thoughtworks_clojure_2016]

The language itself has a rich set of data structure literals, and strongly
emphasizes programming with values. Clojure also defines extensible data
notation, or EDN, to represent Clojure programs. This is effectively a way for
Clojure to serialize programs, and in particular, data structures, and pass them
over the network to communicate with other Clojure processes natively. [@43_edn]

Clojurescript is a variant of Clojure that targets Javascript as a host
language. This makes it possible to write fully isomorphic web applications,
with Clojure on both the client (web browser) and server. [@4_fogushouser_2014]

## Datomic

![Datomic's architecture [@29_rationale_2016]](figures/datomic.png){#fig:datomic_arch}

Datomic is a distributed, immutable, cloud-ready database which supports ACID
Transactions, joins, and boasts a powerful logical query language - Datalog.
What makes Datomic particular interesting is it's notion of the database as a
value. Since Datomic databases consist of a time ordered series of immutable
facts, known as datoms, it is possible to return an exact immutable value of the
database at any point in time. [@29_rationale_2016]

The Datomic team argues that databases have traditionally been called up to
deliver numerous services, such as coordination, consistency, indexing, storage,
and queries. Datomic breaks these services apart into separate components, which
each do a single task well. This, among other benefits, allows the moving of
query capabilities from the database to the application, effectively giving
applications scalable and elastic intelligence. [@29_rationale_2016]

The architecture of Datomic can be seen in [@fig:datomic_arch] it consists of
the following parts:

- **Peers.** These are a library which gets embedded into an application. Peers
  submit transaction to the transactor, and accept changes from it. They also
  provide data access, caching and query capability to the application, and can
  directly read from storage as needed. [@29_rationale_2016]

- **Transactor.** Accepts transactions, and processes them serially, and commits the results
  to storage. It then transmits any changes to the peers. The transactor is also responsible
  for building indexes in the background. [@29_rationale_2016]

- **Storage.** This provides an interaface to highly reliable and redunant
  storage, and includes backends for a number of databases, such as Amazon
  DynamoDB, and PostgresSQL. There is also an optional Memcached layer, which
  provides further caching for production use. [@29_rationale_2016]

Datomic is proprietary software, but offer a free version, limited to two peers,
which uses the H2 database engine and is suitable for small production
deployments. It also offers a professional version which provides a year of
access and updates for free.
