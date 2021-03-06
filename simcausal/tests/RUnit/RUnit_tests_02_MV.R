`%+%` <- function(a, b) paste0(a, b)
as.numeric.factor <- function(x) {as.numeric(levels(x))[x]}
allNA = function(x) all(is.na(x))

# Adding test for latent vars
test.MV <- function() {
  D <- DAG.empty()
  mvName <- c("X1", "X2", "X3")
  # multivar node with no t:
  test.node_not <- node(mvName, distr = "rconst", const = 1)
  # multivar node with with t:
  test.node_wt <- node(mvName, t = 0:20, distr = "rconst", const = 1)

  require("mvtnorm")
  D <- DAG.empty()
  # 3 dimensional normal (uncorrelated) using rmvnorm function from rmvnorm package:
  D <- D + node(c("X1","X2","X3"), distr = "rmvnorm", mean = c(0,1,2))
  # Bivariate normal using same function (correlation coef 0.75):
  D <- D + node(c("Y1","Y2"), distr = "rmvnorm", mean = c(0,1), sigma = matrix(c(1,0.75,0.75,1), ncol=2))
  D <- D + node("A", distr = "rconst", const = 1-X1)
  Dset1 <- set.DAG(D, verbose = TRUE)
  plotDAG(Dset1)
  dat1 <- sim(Dset1, n = 200)

  # Bivariate uniform copula using rCopula function from rCopula package (correlation coef 0.75):
  require("copula")
  D <- DAG.empty()
  D <- D + node(c("Y1","Y2"), distr = "rCopula", copula = normalCopula(0.75, dim = 2))
  Dset2 <- set.DAG(D)
  dat2 <- sim(Dset2, n = 200)

  # Bivariate binomial from previous copula, with same correlation:
  vecfun.add("qbinom")
  D <- D + node("A.Bin1", distr = "rconst", const = qbinom(Y1, 10, 0.5))
  D <- D + node("A.Bin2", distr = "rconst", const = qbinom(Y2, 15, 0.7))
  Dset3 <- set.DAG(D)
  dat3 <- sim(Dset3, n = 200)
  plotDAG(Dset3)

  # Same as "A.Bin1" and "A.Bin2", but directly using rmvbin function in bindata package:
  require("bindata")
  D <- DAG.empty()
  D <- D + node(c("B.Bin1","B.Bin2"), distr = "rmvbin", margprob = c(0.5, 0.5), bincorr = matrix(c(1,0.75,0.75,1), ncol=2))
  Dset4 <- set.DAG(D)
  dat4 <- sim(Dset4, n = 200)
  plotDAG(Dset4)

  # time-varying multivar node (3 time-points, 3 dimensional normal):
  D <- DAG.empty()
  D <- D + node(c("X1", "X2", "X3"), t = 0:2, distr = "rmvnorm", mean = c(0,1,2), sigma = matrix(rep(0.75,9), ncol=3))
  Dset5 <- set.DAG(D)
  dat5 <- sim(Dset5, n = 200)
}

