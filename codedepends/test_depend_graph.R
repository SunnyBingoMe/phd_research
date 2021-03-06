library(testthat)


source("depend_graph.R")


# Could define Ops to get ==, but this is sufficient
expect_samegraph = function(g1, g2)
{
    expect_true(isomorphic(g1, g2))
}


test_that("Degenerate cases, 0 or 1 nodes", {

    s0 = readScript(txt = "
    ")
    g0 = make_empty_graph()
    gd0 = depend_graph(s0)
    expect_samegraph(g0, gd0)

    s1 = readScript(txt = "
    x = 1
    ")
    g1 = make_graph(numeric(), n = 1)
    gd1 = depend_graph(s1)

    expect_samegraph(g1, gd1)

})


test_that("User defined functions are dependencies", {

    s = readScript(txt = "
    f2 = function() 2
    x = f2()
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Self referring node does not appear", {

    s = readScript(txt = "
    x = 1
    x = x + 2
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Assignment order respected", {

    s = readScript(txt = "
    x = 1
    x = 2
    y = 2 * x
    ")

    desired = make_graph(c(1, 2, 2, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Chains not too long", {

    s = readScript(txt = "
    x = 1:10
    plot(x)
    y = 2 * x
    ")

    desired = make_graph(c(1, 2, 1, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Updates count as dependencies", {

    s = readScript(txt = "
    x = list()
    x$a = 1
    x$b = 2
    ")

    desired = make_graph(c(1, 2, 2, 3))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Can add source node", {

    s = readScript(txt = "
    x = 1
    plot(1:10)
    ")

    desired = make_graph(c(1, 2, 1, 3))
    actual = depend_graph(s, add_source = TRUE)

    expect_samegraph(desired, actual)

})


test_that("$ evaluates LHS", {

    s = readScript(txt = "
    f = function(x) 100
    optimize(f, c(0, 1))$minimum
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Precedence for user defined variables over base", {

    s = readScript(txt = "
    c = 100
    print(c)
    ")

    desired = make_graph(c(1, 2))
    actual = depend_graph(s)

    expect_samegraph(desired, actual)

})


test_that("Longest path", {

    g = make_graph(c(1, 2, 1, 3, 2, 3))

    expect_equal(longest_path(g), 3)

})
