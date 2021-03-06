# functions for partial correlations by H. Joe

# specific partial correlation from a covariance or correlation matrix
# 'given' is vector indices for the given variables
# j,k are indices for the conditioning variables

partcor <- function(S, given, j, k) {
    S11 <- S[given, given]
    jk <- c(j, k)
    S12 <- S[given, jk]
    S21 <- S[jk, given]
    S22 <- S[jk, jk]
    if (length(given) > 1) {
        tem <- solve(S11, S12)
        Om212 <- S21 %*% tem
    } else {
        tem <- S12/S11
        Om212 <- outer(S21, tem)
    }
    om11 <- 1 - Om212[1, 1]
    om22 <- 1 - Om212[2, 2]
    om12 <- S[j, k] - Om212[1, 2]
    om12/sqrt(om11 * om22)
}

#============================================================

# correlations to partial correlations and vice
# versa for general R-vine with RVineMatrix

# param: cor, correlation matrix
# param: RVM, RVineMatrix defining the strucutre of the RVine

RVineCor2pcor <- function(RVM, corMat) {
    d <- nrow(corMat)
    stopifnot(d == nrow(RVM$Matrix))
    stopifnot(d > 1)
    stopifnot(is(RVM, "RVineMatrix"))
    stopifnot(all(RVM$family %in% c(0, 1, 2)))
    
    if (d == 2) {
        RVM$par <- matrix(c(0, corMat[2, 1], 0, 0), 2, 2)
        return(RVM)
    }
    pp <- matrix(0, d, d)
    
    oldRVM <- RVM
    oldOrder <- diag(RVM$Matrix)
    if (any(oldOrder != length(oldOrder):1)) {
        RVM <- normalizeRVineMatrix(RVM)
        corMat <- corMat[rev(oldOrder), rev(oldOrder)]
    }
    
    if (!is.null(oldRVM$names)) {
        if (any(!(oldRVM$names %in% paste("V", 1:d, sep = "")))) {
            if (!is.null(rownames(corMat))) {
                nameOrder <- rev(pmatch(rownames(corMat), oldRVM$names))
                if (any(nameOrder != 1:length(oldRVM$names))) {
                    corMat <- corMat[nameOrder, nameOrder]
                }
            } else {
                warning(
                    "RVM$names are not default and the correlation matrix is unnamed. Make sure that
the correlation matrix has the same ordering of variables as the RVM.")
            }
        } else {
            nameOrder <- order(as.numeric(sub("V", "", oldRVM$names)))
            if (any(nameOrder != 1:length(oldRVM$names))) {
                corMat <- corMat[nameOrder, nameOrder]
            }
        }
    }
    
    # rotate towards notation in Kurowicka and Joe (2011), p. 9
    A <- RVM$Matrix[d:1, d:1]
    
    # following algorithm is credited to Harry Joe j <- 2
    for (j in 2:d) {
        pp[1, j] <- corMat[A[1, j], j]
    }
    
    # tree 2
    for (j in 3:d) {
        a1 <- A[1, j]
        a2 <- A[2, j]
        pp[2, j] <- (corMat[j, a2] - corMat[j, a1] * corMat[a1, a2])/sqrt((1 - corMat[j, a1]^2) * (1 - corMat[a1, a2]^2))
    }
    
    # remaining trees
    for (ell in 3:(d - 1)) {
        if (ell < d) {
            for (j in (ell + 1):d) {
                given <- A[1:(ell - 1), j]
                pp[ell, j] <- partcor(corMat, given, A[ell, j], j)  # assuming A[j,j]=j
            }
        }
    }
    
    # re-rotate towards VineCopula notation
    pc <- pp[d:1, d:1]
    
    oldRVM$par <- pc
    return(oldRVM)
}


# generate correlation matrix based on partial correlations of R-vine
# with vine array A that has 1:d on diagonal;

RVinePcor2cor <- function(RVM) {
    d <- nrow(RVM$Matrix)
    ## sanity checks
    stopifnot(d > 1)
    stopifnot(is(RVM, "RVineMatrix"))
    stopifnot(all(RVM$family %in% c(0, 1, 2)))
    if (is.null(RVM$names))
        RVM$names <- paste("V", 1:d, sep = "")
    
    ## store variable names and set to V1:d if any non-default name occurs
    oldNames <- RVM$names
    if (!all(oldNames %in% paste("V", 1:d, sep = "")))
        RVM$names <- paste("V", 1:d, sep = "")
    
    ## normalize RVM object to make the algorithm work properly
    RVM <- normalizeRVineMatrix(RVM)
    
    ## store normalized object and extract order
    oldRVM <- RVM
    oldOrder <- diag(RVM$Matrix)
    
    ## rotate towards notation in Kurowicka and Joe (2011), p. 9
    A <- RVM$Matrix[d:1, d:1]
    pc <- RVM$par[d:1, d:1]
    
    ## if d=2 there is nothing to compute
    if (d == 2) {
        corMat <- matrix(c(1, rep(RVM$par[2, 1], 2), 1),
                         nrow = 2, ncol = 2)
        return(corMat)
    }
    
    ## initialize correlation matrix with correlation parameters of the model
    corMat <- matrix(0, d, d)
    diag(corMat) <- 1
    for (j in 2:d) {
        a1 <- A[1, j]
        corMat[a1, j] <- pc[1, j]
        corMat[j, a1] <- pc[1, j]
    }
    
    ## calculations for second tree
    for (j in 3:d) {
        a1 <- A[1, j]
        a2 <- A[2, j]
        corMat[j, a2] <- corMat[j, a1] * corMat[a1, a2] + pc[2, j] * sqrt((1 - corMat[j, a1]^2) * (1 - corMat[a1, a2]^2))
        corMat[a2, j] <- corMat[j, a2]
    }
    
    ## remaining trees
    if (d > 3) {
        for (ell in 3:(d - 1)) {
            for (j in (ell + 1):d) {
                given <- A[1:(ell - 1), j]
                S11 <- corMat[given, given]
                anew <- A[ell, j]
                jk <- c(anew, j)
                S12 <- corMat[given, jk]
                S21 <- corMat[jk, given]
                S22 <- corMat[jk, jk]
                tem <- solve(S11, S12)
                Om212 <- S21 %*% tem
                om11 <- 1 - Om212[1, 1]
                om22 <- 1 - Om212[2, 2]
                tem12 <- pc[ell, j] * sqrt(om11 * om22)
                corMat[anew, j] <- tem12 + Om212[1, 2]
                corMat[j, anew] <- corMat[anew, j]
            }
        }
    }
    
    ## revert matrix to appropriate order
    corMat <- corMat[rev(oldOrder), rev(oldOrder)]
    nameOrder <- order(as.numeric(sub("V", "", oldRVM$names)))
    corMat <- corMat[nameOrder, nameOrder]
    
    ## warn about matrix ordering if non-default names were provided
    if (!is.null(oldNames)) {
        if (any(!(oldNames %in% paste("V", 1:d, sep = "")))) {
            warning("Some RVM$names are not default (such as ''V5'') and their initial ordering cannot be checked. 
Make sure to interpret the correlation matrix as indicated by the row and column names.")    
            rownames(corMat) <- colnames(corMat) <- oldNames
        } else {
            rownames(corMat) <- colnames(corMat) <- paste("V", 1:d, sep = "")
        }
    }
    
    ## return results
    corMat
}


#######################################
# for immeddeate testing run as well ##
#######################################

# normalizeRVineMatrix = function(RVM){
#   
#   oldOrder = diag(RVM$Matrix)
#   Matrix = reorderRVineMatrix(RVM$Matrix)
#   
#   names <- RVM$names
#   if(is.null(names))
#     names <- paste("V",1:nrow(RVM$Matrix),sep="")
#   
#   return(RVineMatrix(Matrix, RVM$family, RVM$par, RVM$par2, names = rev(names[oldOrder])))
# }
# 
# reorderRVineMatrix = function(Matrix){
#   oldOrder = diag(Matrix)
#   
#   O = apply(t(1:nrow(Matrix)),2,"==", Matrix)
#   
#   for(i in 1:nrow(Matrix)){
#     Matrix[O[,oldOrder[i]]] = nrow(Matrix)-i+1
#   }
#   
#   return(Matrix)
# }
# 
# # examples/test cases
# ######################
# 
# corMat <- matrix(c(1.00, 0.17, 0.15, 0.14, 0.13,
#                    0.17, 1.00, 0.30, 0.28, 0.05,
#                    0.15, 0.30, 1.00, 0.17, 0.05,
#                    0.14, 0.28, 0.17, 1.00, 0.04,
#                    0.13, 0.05, 0.05, 0.04, 1.00),5,5)
# 
# Matrix = matrix(c(5,2,3,1,4,
#                   0,2,3,4,1,
#                   0,0,3,4,1,
#                   0,0,0,4,1,
#                   0,0,0,0,1),5,5)
# family = matrix(1,5,5)
# 
# par = matrix(c(0,0.2,0.9,0.5,0.8,
#                0,  0,0.1,0.6,0.9,
#                0,  0,  0,0.7,0.5,
#                0,  0,  0,  0,0.8,
#                0,  0,  0,  0,  0),5,5)
# 
# # define RVineMatrix object
# RVM = RVineMatrix(Matrix,family,par)
# 
# # adjust the un-ordered RVine
# newRVM <- RVineCor2pcor(RVM, corMat)
# round(cor(qnorm(RVineSim(100000, newRVM)))-corMat, 2)
# 
# # normalise the RVine
# normRVM <- normalizeRVineMatrix(RVM)
# 
# # adjust the normalised RVine
# newNormRVM <- RVineCor2pcor(normRVM, corMat)
# 
# # newRVM and newNormRVM are the same vine using only different naming:
# newNormRVM$par - newRVM$par
# 
# # the variable now do have a different ordering in the correlation matrix
# newNormCor <- cor(qnorm(RVineSim(100000, newNormRVM)))
# round(newNormCor,2)
# 
# # permuted, they meet the initial correlation matrix up to +/- 0.01
# round(newNormCor[c(1,4,3,2,5),c(1,4,3,2,5)]-corMat, 2)
# 
# # re-order names of the normalised RVine generating a new RVine
# normRVM2 <- normRVM
# normRVM2$names <- c("V1", "V2", "V3", "V4", "V5")
# 
# # adjust the normalised RVine
# newNormRVM2 <- RVineCor2pcor(normRVM2, corMat)
# # check whether the parameters are different beyond permutation (that's why 
# # permutation does not work)
# newNormRVM2$par
# newRVM$par
# 
# # adjust the normalised RVine
# newNormRVM2 <- RVineCor2pcor(normRVM2, corMat[c(1,4,3,2,5),c(1,4,3,2,5)])
# # check whether the parameters are now identical
# round(newNormRVM2$par - newRVM$par,2)
# 
# # back and forth
# RVinePcor2cor(RVineCor2pcor(RVM, corMat))-corMat
# RVinePcor2cor(RVineCor2pcor(normRVM, corMat))-corMat
# RVinePcor2cor(RVineCor2pcor(normRVM2, corMat))-corMat
