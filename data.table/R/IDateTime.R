
###################################################################
# IDate -- a simple wrapper class around Date using integer storage
###################################################################

as.IDate <- function(x, ...) UseMethod("as.IDate")

as.IDate.default <-
    function(x, ...) as.IDate(as.Date(x, ...))

as.IDate.Date <- function(x, ...) {
    structure(as.integer(x), class=c("IDate","Date"))
}    

as.IDate.IDate <- function(x, ...) x

as.Date.IDate <- function(x, ...) { 
    structure(as.numeric(x), class="Date")
}

mean.IDate <-
cut.IDate <-
seq.IDate <-
c.IDate <-
rep.IDate <-
split.IDate <-
unique.IDate <-
    function(x, ...) {
        as.IDate(NextMethod())
    }

# fix for #1315
as.list.IDate <- function(x, ...) NextMethod()

# rounding -- good for graphing / subsetting
## round.IDate <- function (x, digits, units=digits, ...) {
##     if (missing(digits)) digits <- units # workaround to provide a units argument to match the round generic and round.POSIXt
##     units <- match.arg(digits, c("weeks", "months", "quarters", "years"))
round.IDate <- function (x, digits=c("weeks", "months", "quarters", "years"), ...) {
    units <- match.arg(digits)
    as.IDate(switch(units,
                    weeks  = round(x, "year") + 7 * (yday(x) %/% 7),
                    months = ISOdate(year(x), month(x), 1),
                    quarters = ISOdate(year(x), 3 * (quarter(x)-1) + 1, 1),
                    years = ISOdate(year(x), 1, 1)))
}

###################################################################
# ITime -- Integer time-of-day class
#          Stored as seconds in the day
###################################################################

as.ITime <- function(x, ...) UseMethod("as.ITime")

as.ITime.default <- function(x, ...) {
    as.ITime(as.POSIXlt(x, ...))
}

as.ITime.character <- function(x, format, ...) {
    x <- unclass(x)
    if (!missing(format)) 
        return(as.ITime(strptime(x, format = format, ...)))
    y <- strptime(x, format = "%H:%M:%OS", ...)
    y.nas <- is.na(y)
    y[y.nas] <- strptime(x[y.nas], format = "%H:%M", ...)

    return(as.ITime(y))
}

as.ITime.POSIXlt <- function(x, ...) {
    structure(with(x, as.integer(sec) + min * 60L + hour * 3600L),
              class = "ITime")
}

as.character.ITime <- format.ITime <- function(x, ...) {
    # adapted from chron's format.times
    # Fix for #811. Thanks to @StefanFritsch for the code snippet
    neg <- x < 0L
    x  <- abs(unclass(x))
    hh <- x %/% 3600L
    mm <- (x - hh * 3600L) %/% 60L
    ss <- trunc(x - hh * 3600L - 60L * mm)
    res = paste(substring(paste("0", hh, sep = ""), nchar(paste(hh))), 
              substring(paste("0", mm, sep = ""), nchar(paste(mm))), 
              substring(paste("0", ss, sep = ""), nchar(paste(ss))), sep = ":")
    if (any(neg)) res[neg] = paste("-", res[neg], sep="")
    res
}

as.data.frame.ITime <- function(x, ...) {
    # This method is just for ggplot2, #1713
    # Avoids the error "cannot coerce class '"ITime"' into a data.frame", but for some reason
    # ggplot2 doesn't seem to call the print method to get axis labels, so still prints integers.
    # Tried converting to POSIXct but that gives the error below.
    # If user converts to POSIXct themselves, then it works for some reason.
    ans = list(x)
    # ans = list(as.POSIXct(x,tzone=""))  # ggplot2 gives "Error: Discrete value supplied to continuous scale"
    setattr(ans,"class","data.frame")
    setattr(ans,"row.names", .set_row_names(length(x)))
    setattr(ans,"names",NULL)
    ans
}

print.ITime <- function(x, ...) {
    print(format(x))
}

rep.ITime <- function (x, ...) 
{
    y <- rep(unclass(x), ...)
    structure(y, class = "ITime")
}

"[.ITime" <- function(x, ..., drop = TRUE)
{
    cl <- oldClass(x)
    class(x) <- NULL
    val <- NextMethod("[")
    class(val) <- cl
    val
}

unique.ITime <- function(x, ...) {
    ans = NextMethod()
    setattr(ans,"class","ITime")
    ans
}

# create a data.table with IDate and ITime columns
#   should work for most date/time formats like chron or POSIXct

IDateTime <- function(x, ...) UseMethod("IDateTime")
IDateTime.default <- function(x, ...) {
    data.table(idate = as.IDate(x), itime = as.ITime(x))
}

# POSIXt support

as.POSIXct.IDate <- function(x, tz = "UTC", time = 0, ...) {
    if (missing(time) && inherits(tz, "ITime")) {
        time <- tz # allows you to use time as the 2nd argument
        tz <- "UTC"
    }
    if (tz == "") tz <- "UTC"
    as.POSIXct(as.POSIXlt(x, ...), tz, ...) + time
}

as.POSIXct.ITime <- function(x, tz = "UTC", date = as.Date(Sys.time()), ...) {
    if (missing(date) && any(class(tz) %in% c("Date", "IDate", "POSIXt", "dates"))) {
        date <- tz # allows you to use date as the 2nd argument
        tz <- "UTC"
    }
    as.POSIXct(as.POSIXlt(date), tz = tz) + x
}

as.POSIXlt.ITime <- function(x, ...) {
    as.POSIXlt(as.POSIXct(x, ...))
}

# chron support

as.chron.IDate <- function(x, time = NULL, ...) {
    if (!is.null(time)) {
        chron(dates. = as.chron(as.Date(x)), times. = as.chron(time))
    } else {
        chron(dates. = as.chron(as.Date(x)))
    }    
}

as.chron.ITime <- function(x, date = NULL, ...) {
    if (!is.null(date)) {
        chron(dates. = as.chron(as.Date(date)), times. = as.chron(x))
    } else {
        chron(times. = as.character(x))
    }    
}

as.ITime.times <- function(x, ...) {
    x <- unclass(x)
    daypart <- x - floor(x)
    secs <- as.integer(round(daypart * 86400))
    structure(secs,
              class = "ITime")
}

###################################################################
# Date - time extraction functions
#   Adapted from Hadley Wickham's routines cited below to ensure
#   integer results.
#     http://gist.github.com/10238
#   See also Hadley's more advanced and complex lubridate package:
#     http://github.com/hadley/lubridate
#   lubridate routines do not return integer values.
###################################################################

hour    <- function(x) as.POSIXlt(x)$hour
yday    <- function(x) as.POSIXlt(x)$yday + 1L
wday    <- function(x) as.POSIXlt(x)$wday + 1L
mday    <- function(x) as.POSIXlt(x)$mday
week    <- function(x) yday(x) %/% 7L + 1L
month   <- function(x) as.POSIXlt(x)$mon + 1L
quarter <- function(x) as.POSIXlt(x)$mon %/% 3L + 1L
year    <- function(x) as.POSIXlt(x)$year + 1900L


