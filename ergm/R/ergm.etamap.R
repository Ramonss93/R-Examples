#  File R/ergm.etamap.R in package ergm, part of the Statnet suite
#  of packages for network analysis, http://statnet.org .
#
#  This software is distributed under the GPL-3 license.  It is free,
#  open source, and has the attribution requirements (GPL Section 7) at
#  http://statnet.org/attribution
#
#  Copyright 2003-2015 Statnet Commons
#######################################################################
###########################################################################
# The <ergm.etamap> function takes a model object and creates a mapping
# from the model parameters, theta, to the canonical eta parameters;
# the mapping is carried out by <ergm.eta>
#
# --PARAMETERS--
#   model: a model object, as returned by <ergm.getmodel>
#
# --RETURNED--
#   etamap: the theta -> eta mapping given by a list of the following:
#     canonical  : a numeric vector whose ith entry specifies whether
#                  the ith component of theta is canonical (via non-
#                  negative integers) or curved (via zeroes)
#     offsetmap  : a logical vector whose ith entry tells whether the
#                  ith coefficient of the canonical parameterization
#                  was "offset", i.e fixed 
#     offset     : a logical vector whose ith entry tells whether the
#                  ith model term was offset/fixed
#     offsettheta: a logical vector whose ith entry tells whether the
#                  ith curved theta coeffient was offset/fixed;
#     curved     : a list with one component per curved EF term in the
#                  model containing
#         from    : the indices of the curved theta parameter that are
#                   to be mapped from
#         to      : the indices of the canonical eta parameters to be
#                   mapped to
#         map     : the map provided by <InitErgmTerm>
#         gradient: the gradient function provided by <InitErgmTerm> 
#         cov     : the eta covariance ??, possibly always NULL (no
#                   <Init> function creates such an item)
#     etalength  : the length of the eta vector
#
###############################################################################

ergm.etamap <- function(model) {
  etamap <- list(canonical = NULL, offsetmap=NULL, offset=model$offset,
                 offsettheta=NULL, curved=list(), etalength=0)
  from <- 1
  to <- 1
  a <- 1
  if (is.null(model$terms)) {
    return(etamap)
  }
  for (i in 1:length(model$terms)) {
    j <- model$terms[[i]]$inputs[2]
    if(model$offset[i]){
     etamap$offsetmap <- c(etamap$offsetmap, rep(TRUE,j))
    }else{
     etamap$offsetmap <- c(etamap$offsetmap, rep(FALSE,j))
    }
    mti <- model$terms[[i]]
    if (is.null(mti$params)) { # Not a curved parameter
      etamap$canonical <- c(etamap$canonical, to:(to+j-1))
      from <- from+j
      to <- to+j
      if(model$offset[i]){
       etamap$offsettheta <- c(etamap$offsettheta, rep(TRUE,j))
      }else{
       etamap$offsettheta <- c(etamap$offsettheta, rep(FALSE,j))
      }
    } else { # curved parameter
      k <- length(mti$params)
      etamap$canonical <- c(etamap$canonical, rep(0, k))
      etamap$curved[[a]] <- list(from=from:(from+k-1),
                                 to=to:(to+j-1),
                                 map=mti$map, gradient=mti$gradient,
                                 cov=mti$eta.cov)  #Added by CTB 1/28/06
      from <- from+k
      to <- to+j
      a <- a+1
      if(model$offset[i]){
       etamap$offsettheta <- c(etamap$offsettheta, rep(TRUE,k))
      }else{
       etamap$offsettheta <- c(etamap$offsettheta, rep(FALSE,k))
      }
    }
  }
  etamap$etalength <- to-1
  etamap
} 

