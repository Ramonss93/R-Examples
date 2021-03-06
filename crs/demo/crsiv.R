## This demo considers nonparametric instrumental regression in a
## setting with one endogenous regressor and one instrument.

require(crs)

## Turn off screen I/O for crs()

opts <- list("MAX_BB_EVAL"=10000,
             "EPSILON"=.Machine$double.eps,
             "INITIAL_MESH_SIZE"="r1.0e-01",
             "MIN_MESH_SIZE"=sqrt(.Machine$double.eps),
             "MIN_POLL_SIZE"=sqrt(.Machine$double.eps),
             "DISPLAY_DEGREE"=0)

## This illustration was made possible by Samuele Centorrino
## <samuele.centorrino@univ-tlse1.fr>

set.seed(42)

## Interactively request number of observations, the method, whether
## to do NOMAD or exhaustive search, and if NOMAD the number of
## multistarts

n <- as.numeric(readline(prompt="Input the number of observations desired: "))
method <- as.numeric(readline(prompt="Input the method (0=Landweber-Fridman, 1=Tikhonov): "))
method <- ifelse(method==0,"Landweber-Fridman","Tikhonov")
cv <- as.numeric(readline(prompt="Input the cv method (0=nomad, 1=exhaustive): "))
cv <- ifelse(cv==0,"nomad","exhaustive")
nmulti <- 1
if(cv=="nomad") nmulti <- as.numeric(readline(prompt="Input the number of multistarts desired (e.g. 10): "))

v  <- rnorm(n,mean=0,sd=.27)
eps <- rnorm(n,mean=0,sd=0.05)
u <- -0.5*v + eps
w <- rnorm(n,mean=0,sd=1)
z <- 0.2*w + v

## In Darolles et al (2011) there exist two DGPs. The first is
## phi(z)=z^2.

phi <- function(z) { z^2 }
eyz <- function(z) { z^2 -0.325*z }

y <- phi(z) + u

## In evaluation data sort z for plotting and hold x constant at its
## median

evaldata <- data.frame(z=sort(z))

model.iv <- crsiv(y=y,z=z,w=w,cv=cv,nmulti=nmulti,method=method)
phihat.iv <- predict(model.iv,newdata=evaldata)

## Now the non-iv regression spline estimator of E(y|z)

model.noniv <- crs(y~z,cv=cv,nmulti=nmulti,opts=opts)
crs.mean <- predict(model.noniv,newdata=evaldata)

## For the plots, restrict focal attention to the bulk of the data
## (i.e. for the plotting area trim out 1/4 of one percent from each
## tail of y and z)

trim <- 0.0025

if(method=="Tikhonov")  {

  subtext <- paste("Tikhonov alpha = ",
                   formatC(model.iv$alpha,digits=3,format="fg"),
                   ", n = ", n, sep="")

} else {

  subtext <- paste("Landweber-Fridman iterations = ",
                   model.iv$num.iterations,
                   ", n = ", n,sep="")

}

curve(phi,min(z),max(z),
      xlim=quantile(z,c(trim,1-trim)),
      ylim=quantile(y,c(trim,1-trim)),
      ylab="Y",
      xlab="Z",
      main="Nonparametric Instrumental Spline Regression",
      sub=subtext,
      lwd=1,lty=1)

points(z,y,type="p",cex=.25,col="grey")

lines(evaldata$z,eyz(evaldata$z),lwd=1,lty=1)

lines(evaldata$z,phihat.iv,col="blue",lwd=2,lty=2)

lines(evaldata$z,crs.mean,col="red",lwd=2,lty=4)

legend(x="top",inset=c(.01,.01),
       c(expression(paste(varphi(z),", E(y|z)",sep="")),
         expression(paste("Nonparametric ",hat(varphi)(z))),
         "Nonparametric E(y|z)"),
       lty=c(1,2,4),
       col=c("black","blue","red"),
       lwd=c(1,2,2),
       bty="n")
