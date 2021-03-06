lamcoefg <-
  function(lambdas,gamvec,family,Kmat,Jmats,yvar,Qmats,
           nknots,ndpts,alpha,yty,nbf,fweights,weights,
           maxit,intol,subsamp,dispersion,gcvtype){
    
    # initialize things
    lamgcv <- vector("numeric",length(lambdas))
    ssval <- vector("numeric",length(lambdas))
    trval <- vector("numeric",length(lambdas))
    isqrt <- vector("list",length(lambdas))
    fcoefs <- matrix(0,nknots+nbf,length(lambdas))
    nqmat <- matrix(0,nbf+nknots,nbf+nknots)
    thmat <- kronecker(gamvec,diag(nknots))
    if(family=="binomial" & length(weights)>1){gcvndpts <- sum(weights*fweights)} else {gcvndpts <- ndpts}
    nqmat[(nbf+1):(nknots+nbf),(nbf+1):(nknots+nbf)] <- gcvndpts*(Qmats%*%thmat)
    Jmat <- Jmats%*%thmat
    rm(Jmats,Qmats)
    nunewr <- length(yvar)
    if(nunewr>subsamp){idx <- sample.int(nunewr,subsamp)} else {idx <- 1:nunewr}
    
    # loop through different lambdas
    for(jj in 1:length(lambdas)){
      lamgcv[jj]=tryCatch({
        
        # get starting values
        if(family=="binomial"){
          mu0 <- (yvar+0.5)/(fweights*weights+1)
          eta0 <- log(mu0/(1-mu0))
          vwts <- as.numeric(mu0*(1-mu0)*weights)
          zvar <- eta0*fweights+(yvar-fweights*mu0*weights)/vwts
        } else if(family=="poisson"){
          mu0 <- (yvar+0.1)/fweights
          eta0 <- log(mu0)
          vwts <- as.numeric(mu0*weights)
          zvar <- eta0*fweights+(yvar-fweights*mu0)/vwts
        } else if(family=="Gamma"){
          mu0 <- (yvar+0.1)/fweights
          eta0 <- 1/mu0
          vwts <- as.numeric((mu0^2)*weights)
          zvar <- eta0*fweights-(yvar-fweights*mu0)/vwts
        } else if(family=="inverse.gaussian"){
          mu0 <- (yvar+0.1)/fweights
          eta0 <- 1/(2*(mu0^2))
          vwts <- as.numeric((mu0^3)*weights)
          zvar <- eta0*fweights-(yvar-fweights*mu0)/vwts
        } else if(family=="negbin"){
          mu0 <- (yvar+0.1)/fweights
          size <- 1/dispersion
          eta0 <- log(mu0)
          vwts <- as.numeric(((mu0*size)/(mu0+size))*weights)
          zvar <- eta0*fweights-1+yvar/(fweights*mu0)
        }
        
        # iterative reweighted least squares udpate
        fitchng <- 1
        iters <- 0L
        yold <- yty
        while(fitchng>intol & iters<maxit){
          
          # get crossproduct matrices
          KtJ <- crossprod(Kmat*(vwts*fweights),Jmat)
          KtK <- crossprod(Kmat*(vwts*fweights),Kmat)
          JtJ <- crossprod(Jmat*(vwts*fweights),Jmat)
          Kty <- crossprod(Kmat*vwts,zvar)
          Jty <- crossprod(Jmat*vwts,zvar)
          xty <- c(Kty,Jty)
          xtx <- rbind(cbind(KtK,KtJ),cbind(t(KtJ),JtJ))
          # update coefficients
          ceig <- eigen(xtx+lambdas[jj]*nqmat,symmetric=TRUE)
          nze <- sum(ceig$val>ceig$val[1]*.Machine$double.eps)
          isqrts <- ceig$vec[,1:nze]%*%diag(ceig$val[1:nze]^-0.5)
          chi <- tcrossprod(isqrts)
          bhat <- chi%*%xty
          yhat <- cbind(Kmat,Jmat)%*%bhat
          # check solution and update iteration
          if(family=="binomial"){
            mu0 <- exp(yhat)/(1+exp(yhat))
            mu0[mu0<=0] <- 10^-4
            mu0[mu0>=1] <- 1-10^-4
            vwts <- as.numeric(mu0*(1-mu0)*weights)
            zvar <- yhat*fweights+(yvar-fweights*mu0*weights)/vwts
          } else if(family=="poisson"){
            mu0 <- exp(yhat)
            mu0[mu0<=0] <- 10^-4
            vwts <- as.numeric(mu0*weights)
            zvar <- yhat*fweights+(yvar-fweights*mu0)/vwts
          } else if (family=="Gamma"){
            yhat[yhat<=0] <- 10^-4
            mu0 <- 1/yhat
            vwts <- as.numeric((mu0^2)*weights)
            zvar <- yhat*fweights-(yvar-fweights*mu0)/vwts
          } else if(family=="inverse.gaussian"){
            yhat[yhat<=0] <- 10^-4
            mu0 <- sqrt(1/(2*yhat))
            vwts <- as.numeric((mu0^3)*weights)
            zvar <- yhat*fweights-(yvar-fweights*mu0)/vwts
          } else if(family=="negbin"){
            mu0 <- exp(yhat)
            mu0[mu0<=0] <- 10^-4
            vwts <- as.numeric(((mu0*size)/(mu0+size))*weights)
            zvar <- yhat*fweights-1+yvar/(fweights*mu0)
          }
          fitchng <- crossprod(yold[idx]-yhat[idx])/crossprod(yold[idx])
          iters <- iters+1L
          yold <- yhat
          
        }
        
        # update solution (using direct ACV/GACV -- Gu and Xiang, 2001)
        isqrt[[jj]] <- isqrts
        fcoefs[,jj] <- bhat
        trval[jj] <- sum(diag(chi%*%xtx))
        if(family=="binomial"){
          cbeta <- sum(log(1+exp(yhat))*fweights*weights)
          p1gcv <- crossprod(yvar,yhat)-cbeta
          if(gcvtype=="acv"){
            smdiag <- rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*(vwts/weights)
            p2gcv <- smdiag/((1-smdiag)*(vwts/weights))
            p3gcv <- yvar*(1-mu0)
          } else if(gcvtype=="gacv"){
            p2gcv <- sum(rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*weights*fweights)/(gcvndpts-trval[jj])
            p3gcv <- yvar*(1-mu0)
          } else {
            p2gcv <- (trval[jj]/(gcvndpts-trval[jj]))*sum((weights^2/vwts)*fweights)/gcvndpts
            p3gcv <- yvar*(1-mu0)
          }
        } else if(family=="poisson"){
          cbeta <- sum(exp(yhat)*fweights)
          p1gcv <- crossprod(yvar,yhat)-cbeta
          if(gcvtype=="acv"){
            smdiag <- rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*vwts
            p2gcv <- smdiag/((1-smdiag)*vwts)
            p3gcv <- yty-yvar*mu0
          } else if(gcvtype=="gacv"){
            p2gcv <- sum(rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*fweights)/(ndpts-trval[jj])
            p3gcv <- yty-yvar*mu0
          } else {
            p2gcv <- (trval[jj]/(ndpts-trval[jj]))*sum((1/vwts)*fweights)/ndpts
            p3gcv <- yty-yvar*mu0
          }
        } else if(family=="Gamma"){
          cbeta <- sum(log(mu0)*fweights)
          p1gcv <- crossprod(yvar,-yhat)-cbeta
          if(gcvtype=="acv"){
            smdiag <- rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*vwts
            p2gcv <- smdiag/((1-smdiag)*vwts)
            p3gcv <- yty-yvar*mu0
          } else if(gcvtype=="gacv"){
            p2gcv <- sum(rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*fweights)/(ndpts-trval[jj])
            p3gcv <- yty-yvar*mu0
          } else {
            p2gcv <- (trval[jj]/(ndpts-trval[jj]))*sum((1/vwts)*fweights)/ndpts
            p3gcv <- yty-yvar*mu0
          }
          ssval[jj] <- sum(yty*(yhat^2))-2*crossprod(yvar,yhat)+ndpts
        } else if(family=="inverse.gaussian"){
          cbeta <- sum((1/mu0)*fweights)*(-1)
          p1gcv <- crossprod(yvar,-yhat)-cbeta
          if(gcvtype=="acv"){
            smdiag <- rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*vwts
            p2gcv <- smdiag/((1-smdiag)*vwts)
            p3gcv <- yty-yvar*mu0
          } else if(gcvtype=="gacv"){
            p2gcv <- sum(rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*fweights)/(ndpts-trval[jj])
            p3gcv <- yty-yvar*mu0
          } else {
            p2gcv <- (trval[jj]/(ndpts-trval[jj]))*sum((1/vwts)*fweights)/ndpts
            p3gcv <- yty-yvar*mu0
          }
          ssval[jj] <- sum(yty/(mu0^3))-2*crossprod(yvar,1/(mu0^2))+sum((1/mu0)*fweights)
          isqrt[[jj]] <- 2*isqrts
          fcoefs[,jj] <- 2*bhat
        } else if(family=="negbin"){
          cbeta <- sum(fweights*size*log(size/mu0))*(-1)
          p0 <- size/(size+mu0)
          p1gcv <- sum((yvar+fweights*size)*log(1-p0))-cbeta
          if(gcvtype=="acv"){
            smdiag <- rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*vwts
            p2gcv <- smdiag/((1-smdiag)*vwts)
            p3gcv <- (yty+yvar*size)*(p0^2)-yvar*size*p0
          } else if(gcvtype=="gacv"){
            p2gcv <- sum(rowSums((cbind(Kmat,Jmat)%*%isqrts)^2)*fweights)/(ndpts-trval[jj])
            p3gcv <- (yty+yvar*size)*(p0^2)-yvar*size*p0
          } else {
            p2gcv <- (trval[jj]/(ndpts-trval[jj]))*sum((1/vwts)*fweights)/ndpts
            p3gcv <- (yty+yvar*size)*(p0^2)-yvar*size*p0
          }
          ssval[jj] <- size
        }
        
        (1/gcvndpts)*(alpha*sum(p2gcv*p3gcv)-p1gcv)
        
      }, error = function(e) sum(yty))
    }
    
    opti <- which.min(lamgcv)
    fxinfo <- list(c(fcoefs[,opti],lamgcv[opti],trval[opti],opti,ssval[opti]),isqrt[[opti]])
  }
