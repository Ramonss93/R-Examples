#(size c.three way mixed ab in c. model 5 b)
# Section 3.4.3.4 test factor B 

# Three way mixed classification. (AxB)>C, Model V
# Factor A, B are fixed. C is random. Determining c, n=1
# a and b are given. Testing hypothesis about factor B
size_c.three_way_mixed_ab_in_c.model_5_b <-  function(alpha, beta, delta, a, b, n, cases)
{
	c <- 5    
	c.new <- 1000
	while (abs(c -c.new)>1e-6)
	{
		c <- c.new
		dfn <- b-1
		dfd <- a*b*(c-1)
		lambda <- ncp(dfn,dfd,alpha,beta)
		if (cases == "maximin")
		{
			c.new <- 2*lambda/(a*n*delta*delta)
		}
		else if (cases == "minimin")
		{
			c.new <- 4*lambda/(a*b*n*delta*delta)
		}
	}  
	return(ceiling(c.new))
}


# example 
# size.3_4_3_4.test_factor_B(0.05, 0.1, 0.5, 6, 5, 1, "maximin")
# size.3_4_3_4.test_factor_B(0.05, 0.1, 0.5, 6, 5, 1, "minimin")



