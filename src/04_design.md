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


## Commands and Events

## HTTP API endpoints

## Authentication and Authorization

## Websocket Application Protocol

## Websocket Server

## Command Processor

## Datomic Transaction Retry

## Update Handler

## Query Service

