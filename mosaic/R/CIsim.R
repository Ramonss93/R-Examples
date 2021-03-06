#' Compute confidence intervals from (multiple) simulated data sets
#' 
#' This function automates the calculation of coverage rates for exploring
#' 	the robustness of confidence interval methods.
#' 
#' @param n size of each sample
#' @param samples number of samples to simulate
#' @param rdist function used to draw random samples
#' @param args arguments required by \code{rdist}
#' @param plot one of \code{"print"}, \code{"return"} or \code{"none"} describing
#' whether a plot should be printed, returned, or no generated at all.
#' @param estimand true value of the parameter being estimated
#' @param conf.level confidence level for intervals
#' @param method function used to compute intervals.  Standard functions that 
#' 	  produce an object of class \code{htest} can be used here.
#' @param method.args arguments required by \code{method}
#' @param interval a function that computes a confidence interval from data.  Function
#' 	  should return a vector of length 2.
#' @param estimate a function that computes an estimate from data
#' @param verbose print summary to screen?
#' 
#' 
#' @return A data frame with variables 
#' 	\code{lower},
#' 	\code{upper},
#' 	\code{estimate},
#' 	\code{cover} ('Yes' or 'No'),
#' 	and 
#' 	\code{sample}
#' 	is returned invisibly.  See the examples for a way to use this to display the intervals
#' 	graphically.
#'
#' 
#' @examples
#' # 1000 95% intervals using t.test; population is N(0,1)
#' CIsim(n=10, samples=1000)    
#' # this time population is Exp(1); fewer samples, so we get a plot 
#' CIsim(n=10, samples=100, rdist=rexp, estimand=1) 
#' # Binomial treats 1 like success, 0 like failure
#' CIsim(n=30, samples=100, rdist=rbinom, args=list(size=1, prob=.7), 
#'        estimand = .7, method = binom.test, method.args=list(ci = "Plus4"))  
#' 
#' @keywords inference 
#' @keywords simulation 
#' 
#' @export


# this is borrowed from fastR.  If it stays in mosaic, it should be removed from fastR

CIsim <-
  function (n, samples = 100, rdist = rnorm, args = list(), 
            plot = if (samples <= 200) "draw" else "none",
            estimand = 0, 
            conf.level = 0.95, method = t.test, method.args = list(),
            interval = function(x) {
              do.call(method, c(list(x, conf.level = conf.level), method.args))$conf.int
            }, estimate = function(x) {
              do.call(method, c(list(x, conf.level = conf.level), method.args))$estimate
            }, verbose = TRUE) 
{
    plot <- match.arg(plot, c("draw", "return", "none"))
    sampleData <- replicate(samples, do.call(rdist, c(list(n = n), 
        args)))
    lower <- apply(sampleData, 2, function(x) {
        interval(x)[1]
    })
    upper <- apply(sampleData, 2, function(x) {
        interval(x)[2]
    })
    estimate <- apply(sampleData, 2, function(x) {
        estimate(x)
    })
    cover <- as.integer(estimand >= lower & estimand <= upper)
    cover <- factor(cover, levels = c(0, 1), labels = c("No", 
        "Yes"))
    cis <- data.frame(lower = lower, upper = upper, estimate = estimate, 
        cover = cover, sample = 1:samples)
    if (verbose) {
        cat("Did the interval cover?")
        print(table(cis$cover)/samples)
    }
    
    plotG <- 
      ggplot(aes(x=sample, y=estimate, ymin=lower, ymax=upper), data = cis) + 
        geom_errorbar(aes(color=cover)) +
        geom_abline(slope=0, intercept=estimand, alpha=0.4) +
        scale_colour_discrete(drop = FALSE)
      
    switch(plot,
           return = return(plotG),
           draw = print(plotG),
           none = {}
           )
    return(invisible(cis))
}


