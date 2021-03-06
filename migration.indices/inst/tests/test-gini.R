data(migration.hyp)

context('Gini indices')

test_that('results match values from articles', {
    expect_equal(migration.gini.total(migration.hyp, F), 0.22222222)
    expect_equal(migration.gini.total(migration.hyp2, F), 0.1875)
    expect_equal(migration.gini.row(migration.hyp), 0)
    expect_equal(migration.gini.row(migration.hyp2), 0.0208333333)
    expect_equal(migration.gini.row.standardized(migration.hyp), 0)
    expect_equal(migration.gini.row.standardized(migration.hyp2), 11.111111)
    expect_equal(migration.gini.col(migration.hyp), 0.055555555)
    expect_equal(migration.gini.col(migration.hyp2), 0.0416666666)
    expect_equal(migration.gini.col.standardized(migration.hyp), 25)
    expect_equal(migration.gini.col.standardized(migration.hyp2), 22.222222)
    expect_equal(migration.gini.exchange.standardized(migration.hyp), 25)
    expect_equal(migration.gini.exchange.standardized(migration.hyp2), 22.222222)
    expect_equal(migration.gini.out(migration.hyp), rep(0, 3))
    expect_equal(migration.gini.out(migration.hyp2), c(0, 0.25, 0))
    expect_equal(migration.gini.out(migration.hyp, FALSE), rep(0, 3))
    expect_equal(migration.gini.out(migration.hyp2, FALSE), c(0, 0.125, 0))
    expect_equal(migration.weighted.gini.out(migration.hyp), 0)
    expect_equal(migration.weighted.gini.out(migration.hyp2), 0.0208333333333333)
    expect_equal(migration.gini.in(migration.hyp), c(0.2, 0.5, 0.333333333333333))
    expect_equal(migration.gini.in(migration.hyp2), c(0.2, 0, 0.428571428571429))
    expect_equal(migration.gini.in(migration.hyp, FALSE), c(0.1, 0.25, 0.16666666666))
    expect_equal(migration.gini.in(migration.hyp2, FALSE), c(0.1, 0, 0.214285714285714))
    expect_equal(migration.weighted.gini.in(migration.hyp), 0.122222222222222)
    expect_equal(migration.weighted.gini.in(migration.hyp2), 0.0523809523809524)
    expect_equal(migration.weighted.gini.mean(migration.hyp), 0.0611111111111111)
    expect_equal(migration.weighted.gini.mean(migration.hyp2), 0.0366071428571429)
})

test_that('scale-independent results', {
    expect_equal(migration.gini.total(2*migration.hyp, F), 0.22222222)
    expect_equal(migration.gini.total(6*migration.hyp2, F), 0.1875)
    expect_equal(migration.gini.row(7*migration.hyp), 0)
    expect_equal(migration.gini.row(5*migration.hyp2), 0.0208333333)
    expect_equal(migration.gini.row.standardized(3*migration.hyp), 0)
    expect_equal(migration.gini.row.standardized(21*migration.hyp2), 11.111111)
    expect_equal(migration.gini.col(534*migration.hyp), 0.055555555)
    expect_equal(migration.gini.col(324*migration.hyp2), 0.0416666666)
    expect_equal(migration.gini.col.standardized(4356*migration.hyp), 25)
    expect_equal(migration.gini.col.standardized(43*migration.hyp2), 22.222222)
    expect_equal(migration.gini.exchange.standardized(324*migration.hyp), 25)
    expect_equal(migration.gini.exchange.standardized(43*migration.hyp2), 22.222222)
    expect_equal(migration.gini.out(345*migration.hyp), rep(0, 3))
    expect_equal(migration.gini.out(22455*migration.hyp2), c(0, 0.25, 0))
    expect_equal(migration.weighted.gini.out(23*migration.hyp), 0)
    expect_equal(migration.weighted.gini.out(7*migration.hyp2), 0.0208333333333333)
    expect_equal(migration.gini.in(435*migration.hyp), c(0.2, 0.5, 0.333333333333333))
    expect_equal(migration.gini.in(43*migration.hyp2), c(0.2, 0, 0.428571428571429))
    expect_equal(migration.weighted.gini.in(324*migration.hyp), 0.122222222222222)
    expect_equal(migration.weighted.gini.in(324*migration.hyp2), 0.0523809523809524)
    expect_equal(migration.weighted.gini.mean(325*migration.hyp), 0.0611111111111111)
    expect_equal(migration.weighted.gini.mean(6*migration.hyp2), 0.0366071428571429)
})
