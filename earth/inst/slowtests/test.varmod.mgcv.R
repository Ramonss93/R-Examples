# test.varmmod.mgcv.R
# mgcv has to be tested separately because of clashes between library(gam) and library(mgcv)
# Stephen Milborrow Apr 2015 Berea

library(earth)
options(warn=2)

printf <- function(format, ...) cat(sprintf(format, ...)) # like c printf

expect.err <- function(obj) # test that we got an error as expected from a try() call
{
    if(class(obj)[1] == "try-error")
        cat("Got error as expected\n")
    else
        stop("did not get expected error")
}
printh <- function(caption)
    cat("===", caption, "\n", sep="")

CAPTION <- NULL

multifigure <- function(caption, nrow=3, ncol=3)
{
    CAPTION <<- caption
    printh(caption)
    par(mfrow=c(nrow, ncol))
    par(cex = 0.8)
    par(mar = c(3, 3, 5, 0.5)) # small margins but space for right hand axis
    par(mgp = c(1.6, 0.6, 0))  # flatten axis elements
    oma <- par("oma") # make space for caption
    oma[3] <- 2
    par(oma=oma)
}
do.caption <- function() # must be called _after_ first plot on new page
    mtext(CAPTION, outer=TRUE, font=2, line=1, cex=1)
if(!interactive())
    postscript(paper="letter")
old.par <- par(no.readonly=TRUE)

library(mgcv)

for(varmod.method in c("gam", "x.gam")) {

    multifigure(sprintf("varmod.method=\"%s\"", varmod.method), 2, 3)
    par(mar = c(3, 3, 2, 3)) # space for right margin axis

    set.seed(6)
    earth.mod <- earth(Volume~Girth, data=trees, nfold=3, ncross=3,
                       varmod.method=varmod.method,
                       trace=if(varmod.method %in% c("const", "lm", "power")) .3 else 0)
    printh(sprintf("varmod.method %s: summary(earth.mod)", varmod.method))
    printh("summary(earth.mod)")
    print(summary(earth.mod))

    # summary(mgcv) prints environment as hex address which messes up the diffs
    printh("skipping summary(mgcv::gam) etc.\n")

    printh(sprintf("varmod.method %s: predict(earth.mod, interval=\"pint\")", varmod.method))
    pints <- predict(earth.mod, interval="pint")
    print(pints)

    plotmo(earth.mod$varmod, do.par=FALSE, col.response=2, clip=FALSE,
           main="plotmo residual model",
           xlab="x", ylab="varmod residuals")

    plotmo(earth.mod, level=.90, do.par=FALSE, col.response=1, clip=FALSE,
           main="main model plotmo Girth")
    do.caption()

    plot(earth.mod, which=3, do.par=FALSE, level=.95)

    # plot.varmod
    plot(earth.mod$varmod, do.par=FALSE, which=1:3, info=(varmod.method=="earth"))
}
par(old.par)

if(!interactive()) {
    dev.off()         # finish postscript plot
    q(runLast=FALSE)  # needed else R prints the time on exit (R2.5 and higher) which messes up the diffs
}
