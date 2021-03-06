# This file was generated by Rcpp::compileAttributes
# Generator token: 10BE3573-1514-4C36-9D1C-5A225CD40393

#' Example RNG Draws with sitmo
#' 
#' Shows a basic setup and use case for sitmo. 
#' 
#' @param n A \code{unsigned int} is a .
#' @return A \code{vec} with random sequences. 
#' @export
#' @examples
#' n = 10
#' a = sitmo_draws(n)
sitmo_draws <- function(n) {
    .Call('sitmo_sitmo_draws', PACKAGE = 'sitmo', n)
}

#' Example Seed Set and RNG Draws with sitmo
#' 
#' Shows how to set a seed in sitmo. 
#' 
#' @param n    An \code{unsigned int} that dictates how many realizations occur.
#' @param seed An \code{unsigned int} that controls the rng seed. 
#' @return A \code{vector} with random sequences. 
#' @export
#' @examples
#' n = 10
#' a = sitmo_engine_seed(n, 1337)
#' b = sitmo_engine_seed(n, 1337)
#' c = sitmo_engine_seed(n, 1338)
#' 
#' isTRUE(all.equal(a,b))
#' isTRUE(all.equal(a,c))
sitmo_engine_seed <- function(n, seed) {
    .Call('sitmo_sitmo_engine_seed', PACKAGE = 'sitmo', n, seed)
}

#' Example Seed Set and RNG Draws with sitmo
#' 
#' Shows how to set a seed in sitmo. 
#' 
#' @param n    An \code{unsigned int} that dictates how many realizations occur.
#' @param seed An \code{unsigned int} that controls the rng seed. 
#' @return A \code{matrix} with random sequences. 
#' @export
#' @examples
#' n = 10
#' a = sitmo_engine_reset(n, 1337)
#' 
#' isTRUE(all.equal(a[,1],a[,2]))
sitmo_engine_reset <- function(n, seed) {
    .Call('sitmo_sitmo_engine_reset', PACKAGE = 'sitmo', n, seed)
}

#' Two RNG engines running side-by-side
#' 
#' Shows how to create two separate RNGs and increase them together. 
#' 
#' @param n     An \code{unsigned int} that dictates how many realizations occur.
#' @param seeds A \code{vec} containing two integers greater than 0. 
#' @return A \code{matrix} with random sequences. 
#' @export
#' @examples
#' n = 10
#' a = sitmo_two_seeds(n, c(1337,1338))
#' 
#' b = sitmo_two_seeds(n, c(1337,1337))
#' 
#' isTRUE(all.equal(a[,1],a[,2]))
#' 
#' isTRUE(all.equal(b[,1],b[,2]))
#' 
#' isTRUE(all.equal(a[,1],b[,1]))
sitmo_two_seeds <- function(n, seeds) {
    .Call('sitmo_sitmo_two_seeds', PACKAGE = 'sitmo', n, seeds)
}

#' Test Generation using sitmo and C++11
#' 
#' The function provides an implementation of creating realizations from the default engine.
#' 
#' @param n An \code{unsigned integer} denoting the number of realizations to generate.
#' @param seeds A \code{vec} containing a list of seeds. Each seed is run on its own core.
#' @return A \code{vec} containing the realizations.
#' @details
#' The following function's true power is only accessible on platforms that support OpenMP (e.g. Windows and Linux).
#' However, it does provide a very good example as to how to make ones code applicable across multiple platforms.
#' 
#' With this being said, how we determine how many cores to split the generation to is governed by the number of seeds supplied.
#' In the event that one is using OS X, only the first seed supplied is used. 
#' 
#' @export
#' @examples
#' a = sitmo_parallel(10, c(1))
#' 
#' b = sitmo_parallel(10, c(1,2))
#' 
#' c = sitmo_parallel(10, c(1,2))
#' 
#' # True on only OS X or systems without openmp
#' isTRUE(all.equal(a,b))
#' 
#' isTRUE(all.equal(b,c))
sitmo_parallel <- function(n, seeds) {
    .Call('sitmo_sitmo_parallel', PACKAGE = 'sitmo', n, seeds)
}

#' Random Uniform Number Generator with sitmo
#' 
#' The function provides an implementation of sampling from a random uniform distribution
#' 
#' @param n    An \code{unsigned integer} denoting the number of realizations to generate.
#' @param min  A \code{double} indicating the minimum \eqn{a} value 
#'               in the uniform's interval \eqn{\left[a,b\right]}
#' @param max  A \code{double} indicating the maximum \eqn{b} value 
#'               in the uniform's interval \eqn{\left[a,b\right]}
#' @param seed A special \code{unsigned integer} containing a single seed.
#' @return A \code{vec} containing the realizations.
#' @export
#' @examples
#' a = runif_sitmo(10)
runif_sitmo <- function(n, min = 0.0, max = 1.0, seed = 1L) {
    .Call('sitmo_runif_sitmo', PACKAGE = 'sitmo', n, min, max, seed)
}

#' Random Uniform Number Generator using base R
#' 
#' The function provides an alternative implementation of random uniform distribution
#' sampling using R's rng scope. 
#' @param n    An \code{unsigned integer} denoting the number of realizations to generate.
#' @param min  A \code{double} indicating the minimum \eqn{a} value 
#'               in the uniform's interval \eqn{\left[a,b\right]}
#' @param max  A \code{double} indicating the maximum \eqn{b} value 
#'               in the uniform's interval \eqn{\left[a,b\right]}
#' @export
#' @examples
#' set.seed(134)
#' b = runif_r(10)
runif_r <- function(n, min = 0.0, max = 1.0) {
    .Call('sitmo_runif_r', PACKAGE = 'sitmo', n, min, max)
}

