# Introduction

## Project Background

This project was originally inspired by the work done by Bobby Calderwood, in
his 2015 Clojure Conj talk titled "From REST to CQRS with Clojure, Kafka, and
Datomic". In the talk he enumerated a number of problems we currently face in
the field of web development, along with what he thought was one possible
implementation of a solution. His presentation introduced the ideas of Event
Sourcing and CQRS, as ways of combating some of these problems. [@23_calderwood_2015]

A second project, by a local Cape Town company, Yuppiechef also served as
motivation for exploring this topic. Yuppiechef built a small prototype of an
Event Sourced / CQRS system which used Onyx, Kafka, Datomic and Amazon's
DynamoDB. Their code included a very through writeup, describing the problem
they were solving, along with the actual design. [@15_introduction_to_cqrs_server_2015]

One of the central ideas in both Bobby Calderwood's talk, and Yuppiechef's
writeup is that we are losing valuable data. Most web systems today are centered
around the model of Create, Read, Update, Delete, otherwise known as CRUD.
Whenever a record in the database is updated or deleted, this is done in place -
whatever the old value was is lost, or banished to obscure logs. CRUD based
systems effectively on remember the present, with the past being lost. However
much of the interesting data exists in the past.

![A CRUD based shopping cart, past states are lost, and only the latest state is kept.](figures/shopping_cart_state.pdf){#fig:shopping_cart_state}

To make these ideas more concrete, let's examine what happens to a shopping cart
in a typical CRUD application. [@fig:shopping_cart_state] illustrates this. As
we add or remove items from our cart, past states of the shopping cart are lost.
CRUD based systems keep only the latest state. You'll notice towards the end
that the potential customer initially had oranges in their shopping cart, only
to remove them towards the end. Wouldn't an ecommerce based business want to
know that?

Harvard Business Review labeled Data Science as the "sexist" career of the 21st
century, and for good reason. [@44_data_science_sexy] More and more businesses
are able to extract value from data to improve existing products and processes,
and even to create new products. An example of this is something we use
everyday - Google. Of course being able to analyze data means actually having
that data available, and this is where Event Sourced systems fit in.

![Using events to capture shopping cart actions.](figures/events.pdf){#fig:events}

Instead of storing the state of the shopping cart, why not simply store the
events that caused it to get into that state? [@fig:events] shows this in
action. Note that now we have a specific event for removing an item from the
cart. That data is now preserved, and has been made a first class citizen. Not
only that, but it's now possible to "time travel" and put the shopping cart into
any previous state; providing that each event is ordered in time.

In light of all the above, this project was born out of the desire to build a
template for an application that was architected for data science, where it
wouldn't be a struggle to mine the data needed for data analysts to do their
jobs. At the same time there were plenty of side benefits from an Event Sourced
/ CQRS system, some of which included looser coupling between services, and
simpler debugging.

Many frameworks for CRUD based systems exist, such as the ever popular Ruby on
Rails web framework. There are very few Event Sourcing / CQRS frameworks, and
barely any of them have much traction. This is most likely because Event
Sourcing is a different way of thinking about applications, but it's also
because Event Sourcing as a whole offers a lot of flexibility in how your
application grows and evolves. Greg Young, an Event Sourcing expert, advised the
public against creating another Event Sourced framework. [@45_greg_young_2012]
This project heeds his advice, and aims rather to a reference, or a template, on
which to build an Event Sourced/CQRS application. It does not intend to impose
any boundaries on the engineers using it, and in encourages them to freely
modify everything to suit their application.

## Project Objectives

### Problems to be Investigated

The following problems are to be investigated and researched.

- How to build Event Sourced / CQRS systems, and their benefits and tradeoffs.
- The importance of data science, and how applications can make data analysis
  simpler.
- Asynchronous communication on the web and how to decouple requests from
  responses.
- How to architect flexible and scalable systems.
- How to reduce HTTP API surface area, and build smaller, simpler APIs.

### List of Objectives

The goal of this project is to design and implement a template for the back-end
of a web based application, with the following objectives:

- First class support for data science.
- Fully asynchronous.
- Flexible architecture which able to adapt to change and scale.
- Initial support for 500-1000 concurrent users on modest hardware.
- Audit trail support.
- Simple to test, debug, and maintain.

### Purpose of the Project

The purpose of this project is to provide a foundation for a small to medium
sized team that would like to architect a modern web application with first
class support for data science, that is flexible, scalable, maintainable, and
performant enough.

## Scope and Limitations

This project is limited to research within the fields of web applications, and
distributed systems only. Any related fields will not be included.

Research sources for this project include books, online articles, blog posts,
and non-academic software conference talks in addition to peer reviewed
materials. Software, and web applications in particular, is a rapid moving
field, and such much of the available peer-reviewed literature becomes outdated
soon after it is published. In order to access the most relevant information it
is thus essential that these sources are consulted.

It is assumed that the reader is reasonably well versed in traditional back-end
web development, and that terms such as threads, HTTP, asynchronous
communication, etc do not need to be explained.

It is further assumed that the reader is familiar with the technologies chosen
for implementation of this project, or that they are able to find tutorials or
books to teach them the basics. Due to the short time frame given for this
project, it is impossible to include a crash course in the technologies used, in
addition to the project itself. Information on all technology used in this
project is readily available for free from numerous online sources.

This project will be tested for performance, however the results should be taken
with a pinch of salt, given that it is very difficult to predict the performance
of a real world application built on top of this framework without actually
testing that exact application. Also time constraints have resulted in
performance testing being a minor concern, and a better test can certainly be
written.

Finally, the project includes an additional component, a web console for
interacting with the back-end, and testing it. This front-end application does
not form part of the scope of this project, and therefore it's implementation,
or any details surrounding it will not be discussed at all.

## Terminology

- *UUID*, Universally unique identifier, a 128 bit number used to identify
  information in computer systems.

## Plan of Development

This project report has the following structure:

*Chapter 1* introduces the research project, it's objectives, scope, limitations and motivation.

*Chapter 2* consists of a literature review of relevant sources both in academia and industry.

*Chapter 3* gives an overview of the project methodology.

*Chapter 4* details the design of the application template.

*Chapter 5* presents the implementation of the application template design.

*Chapter 6* reviews both functional and performance tests performed, and the results of such tests.

*Chapter 7* is a discussion of the testing results, and overall implementation
in light of the project objectives.

*Chapter 8* lists recommendations for future work.
