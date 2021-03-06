# Wed Feb  8 11:11:22 PST 2017
#
# How much time does it take to fork()?
#
# Summary:
# Overhead for mcparallel() with collect() is 1.5 ms
# Starting R and doing a trivial eval in my terminal takes 150 - 200 ms
# Same with Python is around 20 - 50 ms.


library(microbenchmark)
library(parallel)


# This produces R's with different PID's every time, which means the
# forking happens with every call here.
a = mclapply(1:10, function(x) x)


# Timings
# All on my old Lenovo desktop
############################################################

# 6 microseconds. Fast, as expected.
microbenchmark(lapply(1:10, function(x) x))

# 3 ms.
microbenchmark(mclapply(1:10, function(x) x))

# 6 ms
microbenchmark(mclapply(1:1000, function(x) x))

# 12 ms
microbenchmark(mclapply(1:10000, function(x) x))

# Seeing logarithmic growth in run time.

# 4 - 33 ms
microbenchmark(lapply(1:10, function(...) 1:1e6L), times = 100L)

# Serialization and moving data is a much larger concern... similar to GPU
# programming.
# 65 - 177 ms
microbenchmark(mclapply(1:10, function(...) 1:1e6L), times = 50L)

# 1.5 ms
microbenchmark({
    mcparallel({a = 1})
    mccollect()
}, times = 50L)

# 9 ms
microbenchmark({
    mcparallel({a = 1:1e6L})
    mccollect()
}, times = 50L)


# This is different since the forked processes will persist on the machine.
cl = makeCluster(2L, "FORK")

a = 1
# 220 microseconds. An order of magnitude faster than forking
microbenchmark(clusterExport(cl, "a"))

# Sanity check
clusterEvalQ(cl, a)

a = 1:1e6L
# 5 - 40 ms. That's not terrible. Pretty variable though.
microbenchmark(clusterExport(cl, "a"))
