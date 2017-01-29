# Design

## High-level overview

![Calderwood](figures/calderwood.pdf){#fig:calderwood}

The high level overview of the design is shown in [@fig:calderwood].

The design begins with the *SPA client*, a Javascript application running in a
modern web browser. It is assumed that this application has access to the
Websocket API. Websocket support in modern browsers is generally very good.

The *SPA client* is connected to the Websocket server via the bidirectional
connection that the Websocket protocol affords. This is represents by the two
blue queues, since the communication is fully duplex. Due to this we are able to
have fully asynchronous communication, with requests decoupled from responses.
The client is able to send commands, and receive updates. Websockets are
effectively a thin layer of abstraction above TCP, and hence like TCP, they
offer no way for the application to acknowledge data once it has been received.
Once the application is delivered a packet of data, it is then the applications
problem. It is up to the application to develop a protocol that will allow it to
identify when a command has been successfully submitted for processing. That
protocol forms part of the design process, and will be discussed in more detail
later.

The *Websocket Server* is responsible primarily for establishing, and
maintaining Websocket connections, and secondly for validating and
putting commands onto the *Command Queue*. Invalid command should
result in the client receiving a message indicating that there
was an error, and likewise an acknowledgment if everything was
validated successfully. This component can be used by other services,
such as the *Update Handler* to send updates back to client after
commands have been processed.

The *Command Queue* can either be a local concurrent queue, since there are
potentially many Websocket connections putting commands onto it, or it could be
a distributed queue which maintains order, like Apache Kafka, or NATS Streaming.
The command queue effectively keeps the *Websocket Server* and *Command
Processor* decoupled, and ensures there is some ordering of incoming commands.

The *Command Processor* is responsible for converting commands to events, and
also for aggregating those events, and transacting them to the Datomic database.
It uses a Datomic peer to read the current value of the database at the time of
receiving the command from the *Command Queue*, and uses that database value to
produce events. These events are then aggregated and transacted. Datomic allows
database transactions to be annotated with additional information. By default
Datomic only annotates each transaction with a timestamp of when that transaction
was processed. In our case we also include the event data. This allows downstream
processors, such as the *Update Handler* to easily obtain the event, and pass
it back to the client. Since transactions can timeout, it is essential that there
is some sort of retry policy in place.

The *Datomic transaction log* is a log of all transactions that have happened.
These transactions are stored as data, and Datomic provides a useful API to
access it. For our purpose we will use the transaction report queue, which gives
a real-time view into transactions as they happen. As each transaction occurred
it is pushed onto a queue, which can be read off by a consumer.

The *Update Handler* watches the *Datomic transaction log* and reads off each
incoming transaction's data. Since each transaction is annotated with the event
which is was caused by, the *Update Handler* can simply extract the event, and
send it back to the *Websocket Server*, which will in turn send it on to the
client.

Finally there is the *Query Service* which enjoys a high degree of decoupling
from the rest of the system. It's primary purpose is to process queries received
by the client, and return the relevant data from the aggregated events. It does
this by querying Datomic, use either it's indexes, or Datalog query language.
Since the overall design is a CQRS system, there can be a number of *Query
Services*, which can together support excellent read scaling. Read scaling is
also a big strength of Datomic.

## Commands and Events

*Commands* can be represented by a map or object, and have the following fields:

Field          Type              Description
-----          ----              -----------
UUID           UUID              The command's unique identifier.
Name           Clojure Keyword   The name of the command.
Data           Clojure Map       The command data, key/value pairs.
Meta           Clojure Map       Command metadata, key/value pairs.
User UUID      UUID              The user who issued the command's unique identifier.
Client ID      String            The client where the command came from's ID.
Client Seq     Long              The sequence number of client.

An example command in Clojure EDN:

```clojure
{:command/uuid #uuid "588d97e8-c456-47a0-bffd-84af06223387"
 :command/name :view-page
 :command/data {:page-view/url "http://www.example.com"}
 :command/meta {:send-timestamp #inst "2017-01-02T07:17:03.944-00:00"}
 :command/user-uuid #uuid "588d96ef-173e-422c-b89b-bb2de199322c"
 :command/client-id  "588d96ef-4c26-4769-9b86-bf893aebfa72"
 :command/client-seq 0}
```

## Effective Use of Datomic

If the reader is unfamiliar with Datomic, a good primer was written by Daniel Higginbotham,
and is available online. [@46_datomic_primer]

Datomic bases its information model around facts. A fact is Datomic is known as
a *datom* and consists of a tuple of entity, attribute, value, time, and whether
is was an addition, or a retraction. Time is a first class citizen. A *datom* in
Clojure is represented as follows:

```clojure
[10 :person/name "John" 65 true]
```
The entity is just an integer identifier. An attribute and value can be seen as
a key/value pair. Underneath the hood, they are just integers too. The time
component is represented by a special kind of entity, called a transaction
entity. The integer identifiers of these entities provide a logical time,
decoupled from wall clock time, making working with time simpler. Facts can be
either asserted, or retracted. If John changed his name to Jake, Datomic would
retract the datom above, and issue a new datom:

```clojure
[[10 :person/name "John" 66 false]
 [10 :person/name "Jake" 66 true]]
```

Entities are not required to have the same attributes, and can have a mix of attributes. All datoms
with the same entity identifier are grouped together, and the entities value at any point in time
can be established. In the snippet below we see two entities, John and Jill, John has an age attribute,
while Jill does not.

```clojure
[[10 :person/name "John" 65 true]
 [10 :person/age 30 65 true]
 [11 :person/name "Jill" 65 true]]
``` 

Datoms are very low level, and working with them in production, as the author
has for a few years, can be tedious. Even though all facts are stored, we are
often more interested in collections of facts being asserted at the same time,
rather than individual facts. Often we are more interested in actual events that
happened, like a user being created, as opposed to a particular attribute of
that user being created..

In light of this, this project uses Datomic in a way which gives an emphasis on
collections of datoms, otherwise known as transactions. Since the time component
of each datom is just itself an entity, it is possible to annotate groups of datoms
being transacted with additional data. For example:

```clojure
[[10 :person/name "John" 65 true]
 [10 :person/age 30 65 true]
 [65 :db/txInstant 65]
 [65 :event/name :user-created 65 true]]]
``` 

This now gives us a clear way to label transactions as a particular event, which is meaningful
to our domain. We can query any entity attribute, find it's transaction entity id, and establish
which event caused this change to happen.


## HTTP API endpoints

## Authentication and Authorization

## Websocket Application Protocol

## Websocket Server

## Command Processor

## Datomic Transaction Retry

## Update Handler

## Query Service

