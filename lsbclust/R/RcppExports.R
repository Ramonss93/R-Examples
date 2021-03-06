# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' @rdname ClustMeans
#' @title C++ Function for Cluster Means
#' @name ClustMeans
#' @description This function calculates the cluster means in vectorized form based on the current
#' value of the clustering vector.
#' @param nclust The number of clusters.
#' @param start The current clustering vector.
#' @param data The concatenated data, with J * K rows and N columns
#' @return A numeric matrix with \code{nclust} rows and \code{J*K} columns.
ClustMeans <- function(nclust, start, data) {
    .Call('lsbclust_ClustMeans', PACKAGE = 'lsbclust', nclust, start, data)
}

#' @title C++ Function for Weighted K-Means
#' @name KMeansW
#' @description This function does a weighted K-means clustering.
#' @param nclust The number of clusters.
#' @param start The current cluster membership vector.
#' @param weight The vector of length \code{nrows(data)} with weights with nonnegative elements.
#' @param data The concatenated data, with N rows and M columns. Currently, the columns are clustered.
#' @param eps Numerical absolute convergence criteria for the K-means.
#' @param IterMax Integer giving the maximum number of iterations allowed for the K-means.
#' @param cm Numeric vector of class indicators.
#' @param M Matrix of cluster means.
#' @return A list with the folowing values.
#' \item{centers}{the \code{nclust} by M matrix \code{centers} of cluster means.} 
#' \item{cluster}{vector of length N with cluster memberships.} 
#' \item{loss}{vector of length \code{IterMax} with the first entries containing the loss.} 
#' \item{iterations}{the number of iterations used (corresponding to the number 
#' of nonzero entries in \code{loss})} 
#' @examples 
#' set.seed(1)
#' clustmem <- sample.int(n = 10, size = 100, replace = TRUE)
#' mat <- rbind(matrix(rnorm(30*4, mean = 3), nrow = 30), 
#'              matrix(rnorm(30*4, mean = -2), nrow = 30), 
#'              matrix(rnorm(40*4, mean = 0), nrow = 40))
#' wt <- runif(100)
#' testMeans <- lsbclust:::ComputeMeans(cm = clustmem, data = mat, weight = wt, nclust = 3)
#' testK <- lsbclust:::KMeansW(start = clustmem, data = mat, weight = wt, nclust = 3)
ComputeMeans <- function(cm, data, weight, nclust) {
    .Call('lsbclust_ComputeMeans', PACKAGE = 'lsbclust', cm, data, weight, nclust)
}

#' @rdname KMeansW
AssignCluster <- function(data, weight, M, nclust) {
    .Call('lsbclust_AssignCluster', PACKAGE = 'lsbclust', data, weight, M, nclust)
}

#' @rdname KMeansW
KMeansW <- function(nclust, start, data, weight, eps = 1e-8, IterMax = 100L) {
    .Call('lsbclust_KMeansW', PACKAGE = 'lsbclust', nclust, start, data, weight, eps, IterMax)
}

#' @rdname LossMat
#' @title C++ Function for Interaction Loss Function
#' @name LossMat
#' @description This function calculates the loss function for the interaction clustering
#' for all data slices and clusters means. The inputs are numeric matrices.
#' @param x The data matrix, with the N slices strung out as vectors in the columns.
#' @param y The matrix of cluster means, with each mean represented by a row.
#' @return A numeric matrix with \code{nclust} rows and \code{N} columns.
NULL

LossMat <- function(x, y) {
    .Call('lsbclust_LossMat', PACKAGE = 'lsbclust', x, y)
}

