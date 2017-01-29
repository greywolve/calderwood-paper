# Conclusion

The overall conclusion is that the project was a success. All the project
objectives were met, noting the following:

- Since we use an immutable database, with a logical query language, and a fully
  event driven architecture, we are sure that data analysis will be far simpler
  on this system compared to traditional web applications. We gain an audit
  trail as a by-product of this.

- The system supports 320/ops on a single server, with modest hardware. This
  translates into 600-1200 concurrent users depending on how often users submit
  commands, if we assume each user takes 2-4 seconds between each command.

- The system is fully asynchronous and requests are decoupled from responses
  when submitting commands.

- The architecture is flexible, and key components, such as the *Query Service*,
  and *Command Processor*, can be separated and moved out into their own
  processes if need be.
  
- It is simple to add new functionality to the system, in the case of commands
  it only requires implementing three multimethods, and in the case of queries,
  two.

We would assume that a small to medium sized team could use and build on this
application template to build a real world production system that is architected
for data science.
