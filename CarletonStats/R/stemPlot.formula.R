stemPlot.formula <-
function(formula, data = parent.frame(), subset,...)
{
  
    if (missing(formula) || (length(formula) != 3L) || (length(attr(terms(formula[-2L]), 
       "term.labels")) != 1L)) 
       stop("'formula' missing or incorrect")
  
    m <- match.call(expand.dots = FALSE)
    if (is.matrix(eval(m$data, parent.frame()))) 
        m$data <- as.data.frame(data)
    m[[1L]] <- as.name("model.frame")
    m$... <- NULL
    mf <- eval(m, parent.frame())
    
    nmiss <- length(attr(mf, "na.action"))
    if (nmiss > 0)
      cat("\n ", nmiss, "observation(s) removed due to missing values.\n")
      
    varnames <- names(mf)
    names(mf) <- NULL
    
    response <- attr(attr(mf, "terms"), "response")
    y <- mf[[response]]
    g <- mf[[-response]]  
    yname <- varnames[1]
    gname <- varnames[2]   
        
    y <- do.call("stemPlot", c(list(y, g, varname = yname, grpvarname = gname),...))


}
