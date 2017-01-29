# Future Work and Recommendations

There are a number of areas which can be explored in future work, these include:

- Allowing for synchronous commands in some instances, instead of being purely
  asynchronous.
- Dealing with event versioning.
- Moving the *Command Processor* to it's own node, and connecting it to the rest
  of the system via a distributed queue such as Apache Kafka.
- Exploration of in memory aggregates instead of Datomic.
  
As for existing recommendations, it would be good to explore means of making the
current implementation more performant, perhaps by using Records more instead of
Maps, and finding other ways to optimize, this would require profiling the code
in order to find bottlenecks.

# References
