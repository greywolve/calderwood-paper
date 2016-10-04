#Introduction

## Problem defnition

Design an application template for an information system which meets the
following criteria:

- Able to handle a large number of concurrent users with acceptable latency.
- First class support for data science.
- Parts of the system can be replaced with minimum effort.
- Simple to test, debug, and maintain.
- Allows for a heterogeous mix of programming languages and databases.

#Literature Review

## Place-orientated Programming

- Information consists of facts. A fact is something that is known to happen. It
  is precise, immutable and it has a time dimension. A fact is known to have
  happened at a particular point in time.

- A place is a particular portion of space, used for a particular purpose. In
  computer systems this would correlate to an address in memory, or a sector on
  disk.

- Information systems today generally operate by replacing old information with
  new information. A fact is associated with a particular place and new facts
  overwrite old facts. Rich Hickey refers to this as place-orientated
  programming.

- Information systems before computers were always accumulating. Accounts do not
  use erasers, they use double ledger entry. Places were not important, facts
  were.

- This was born out of the limitations of early computers, but storage capacity
  has increased a million fold since then. When the scale of something increases
  so dramatically, do the some rules still apply?
  
- Place-orientated programming gives us the current view of the world, only the newest facts. 

- Making good decisions tends to require past facts too, not just the latest facts.

@36_hickey_2012

## CRUD flavoured REST

- CRUD is an acronym for create, read, update and delete. It defines the four basic functions of peristant storage.

- CRUD is the dominant way of modifying resources in a web application, usually exposed via a RESTful interface. Resources can be created, read, updated and deleted.

- Web application frameworks, such as Rails (Ruby), Play (Java), Express (node.js), have popularised this approach.

- This can be viewed as "CRUD" flavoured REST.

- CRUD typically gives us only the current view of the world, and emphasises place-orientated programming where new facts replace old. Update and delete cause old facts to be lost.

- Steve Yegge wrote an excellent rant against Java (and Object-orientated
  programming) and it's over emphasis on nouns rather than verbs. Which makes
  more sense? Paying your credit card bill by updating a bill sub-resource of a
  credit card resource, or simply calling a pay-card-card-bill API end point?
  CRUD flavoured REST is really the kingdom of nouns for distributed systems.

@26_yegge_2016
@23_calderwood_2015
@39_getting_started_with_rails_2016

## Architecting for Data Science

- The primary purpose of data science is to extract value from data.

- Data science can be broadly defined as "the transformation of data using
  mathematics and statistics into valuable insights, decisions, and products." 

- Data science is the same as, or very closely related to terms such as
 business analytics, operations research, business intelligence, competitive
 intelligence, data analysis and modeling, and knowledge extraction.

- In CRUD based systems, data science is often an after thought, and generally
  logs have to be mined in order to obtain the data necessary to gain insight.

@38_loukides_2010
@40_foreman_2013
@36_hickey_2012

## Avoiding the tarpit

- Complexity is the root cause of most problems in software development, because
  understanding of the software is greatly undermined by complexity.

- Need to differentiate between essential and accidental complexity. Essential
  complexity is inherent in the problem, whereas accidental complexity is
  additional complexity created by the programmer, and orthogonal to solving the
  problem at hand.

- Complexity in software is primarily caused by mutable state, and control. It
  is difficult to keep track of all possible states that a system can be in.
  Likewise control is difficult because order is important. If one statement is
  incorrectly placed before another then the program is typically incorrect too

- Object-orientated programming has been one approach to handling this
  complexity. However it fails for two primary reasons. OO conflates the notion
  of intensional identity (an object's identity) and extensional identity (the
  object's attributes). This increases the number of states which need to be
  considered. Secondly each object method accessing the object's state needs to
  enforce integrity constraints, it is also akward to enforce multi-object
  integrity constraints. OO also uses traditional flow control structures, and
  thus has to solution to taming complexity associated with control.

- "The bottom line is that all forms of OOP rely on state (contained within
  objects) and in general all behaviour is affected by this state. As a result
  of this, OOP suffers directly from the problems associated with state, and as
  such we believe that it does not provide an adequate foundation for avoiding
  complexity."

- Functional programming in it's purest form eschews mutable state and side
  effects, and thus avoids much of the complexity associated with state. Higher
  level functions such as filter and map, allow a slighly better form of
  control, though order still matters to a large degree. The biggest weakness of
  functional programming is it's strength too, since all non-trivial programs
  require a certain amount of essential state.

- Mosely and Marks recommend two strategies for dealing with complexity. Avoid
  it, accept only essential complexity, and if you can't avoid it, for reasons
  of ease of use, or performance, then seperate it out in order to better manage
  it.

@10_moseleymarks_2006

## Software evolvability

## Service-orientated architecture and Microservices

## Stream Processing

## Distributed Logs 

## CQRS

## Event Sourcing

## Asynchronous communication on the web

## CAP Theorem 

## Functional programming

## Clojure

## Datomic

## Communicating Sequential Processes

