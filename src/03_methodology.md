# Methodology

## Research

The initial phase of the project consisted of research into relevant literature
and conference talks in the field of web development and distributed systems.

Topics included:

- Event Sourcing.
- CQRS.
- Microservices.
- Data science.
- Steam processing.
- Software complexity.
- The limitations of CRUD based REST APIs.
- Functional Programming.
- Websockets.
- Datomic, an immutable database.


A variety of sources were consulted, including sources from industry.

## Design

The design phase of the project primarily focused on high level design from a
birds eye view. This consisted of the following:

- Establishing the flow of data throughout the system.
- Dividing the system into components.
- Identifying tasks for each component.
- Considering possible error points in the system, and things that can go wrong.
- The structure of events and commands.
- The HTTP API routes.

In addition the this primary task, there were a number of secondary design tasks such as:

- Designing an application level protocol for asynchronous communication over Websockets.
- Designing an algorithm for retrying database transactions.
- Choosing a method for user authentication and authorization.
- Coming up with a strategy for performance testing.

## Implementation

The project implementation phase primarily consisted of choosing libraries and
writing code to implement the design.

During implementation it was natural to re-design certain components and
algorithms when practicality forced it. Certain problems in design can only be
fully understood when an attempt at implementation is made.

## Testing

The testing phase involved two sub phases, functionality testing, and performance testing.

Functionality tests were done by using a custom built Clojurescript console
application, which allows commands and queries to be submitted to the back-end
system. The details of the construction of this application are beyond the scope
of this project, but it was necessary for more sane testing of the application
from a graphical interface. The console was also protected by the back-end
authentication / authorization scheme, which allowed testing of user login and
logout too.

Performance testing consisted of a latency and throughput test which exercised
the entire flow of data through the system by focusing on a single event, and
Websocket connection. The goal was to find the maximum throughput attainable
with acceptable latency, which was defined as under 100ms for the 99.9th
percentile.

## Results and Conclusions

In this phase of the project, results of the testing phase are analyzed together
with non-quantifiable project features and conclusions are drawn in light of the
project objectives. Was the project a success?

## Recommendations for the Future

Finally, recommendations for future work, such as exploring the use of Apache Kafka in the system, are made.


