snntsmarginallatitude <- function(data,cpars=1,M=c(0,0)){

    auxcond<-sum(data>pi)+sum(data<0)
    if (auxcond>0)
	return("Latitude data must have values between 0 and pi")

    A <- matrix(0,nrow=M[2]+1,ncol=M[2]+1)

    for (k2 in 0:M[2]){
    	for (m2 in 0:M[2]){
        	if (abs(k2 - m2) != 1){
            		A[k2+1,m2+1] <- (2*pi)*((1 + cos((k2-m2)*pi))/(1 - ((k2-m2)^2)));
 		}
	}
    }

    Ac<-chol(A)
    Acinv <- solve(Ac)
    cparsauxa <- cpars

    for (k1 in 0:M[1]){
	cpars[(k1*(M[2]+1)+1):((k1+1)*(M[2]+1))] <- Acinv %*% cparsauxa[(k1*(M[2]+1)+1):((k1+1)*(M[2]+1))]
    }

    cparsaux<-matrix(cpars,nrow=M[1]+1,ncol=M[2]+1,byrow=TRUE)

    y<-rep(0,length(data))

    for (j in 1:length(data)){
	    for (k1 in 0:M[1]){
		    for (k2 in 0:M[2]){
			    for (m2 in 0:M[2]){
				    y[j] <- y[j] + (2*pi)*sin(data[j])*cparsaux[k1+1,k2+1]*Conj(cparsaux[k1+1,m2+1])*(exp(1i*(k2-m2)*data[j]))
			    }
		    }
	    }
    }					
    return(Re(y))
}