#' Generate Random Vector of Dates
#'
#' Generate a random vector of dates.
#'
#' @param n The number elements to generate.  This can be globally set within
#' the environment of \code{r_data_frame} or \code{r_list}.
#' @param random logical.  If \code{TRUE} the dates are randomized, otherwise the
#' dates are sequential.
#' @param x A vector of elements to chose from.  This may be \code{NULL} if
#' arguments are supplied to \code{start}, \code{k}, and \code{by}.  The
#' \code{x} argument takes precedence over the other three if \code{!is.null}.
#' Note that \code{start}, \code{k}, and \code{by} work together to make a
#' vector of dates to sample from.  See \code{\link[base]{seq.Date}} for
#' additional information.
#' @param start A date to start the sequence at.
#' @param k The length of the sequence (number of the elements) so build out from
#' \code{start}.
#' @param by The interval to use in building the sequence.
#' @param prob A vector of probabilities to chose from.
#' @param name The name to assign to the output vector's \code{varname}
#' attribute.  This is used to auto assign names to the column/vector name when
#' used inside of \code{r_data_frame} or \code{r_list}.
#' @return Returns a random factor vector of date elements.
#' @keywords date
#' @export
#' @seealso \code{\link[base]{seq.Date}}
#' @family variable functions
#' @examples
#' date_stamp(10)
#' pie(table(date_stamp(2000, prob = probs(12))))
#'
#' ## Supply dates to `x` to sample from
#' date_stamp(10, x = seq(as.Date("1980-11-16"), length = 30, by = "1 years"))
date_stamp <- function(n, random = FALSE, x = NULL, start = Sys.Date(), k = 12,
    by = "-1 months", prob = NULL, name = "Date"){

    if (is.null(x)){
        x <- seq(start, length = k, by = by)
    }

    if (!inherits(x, c("Date", "POSIXct", "POSIXt"))) warning("`x`may not a date vector")

    out <- sample(x = x, size = n, replace = TRUE, prob = prob)
    if (!random) out <- sort(out)
    varname(out, name)
}






