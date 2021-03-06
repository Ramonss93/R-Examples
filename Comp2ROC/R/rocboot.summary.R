rocboot.summary <-
function(result,mod1,mod2) {
  cat("\n")
  cat("------------------------------------------------\n")
  cat(mod1,"\n")
  cat("------------------------------------------------\n")
  cat("Area:                               ",result$Area1,"\n")
  cat("Standard Error:                     ",result$SE1,"\n")
  cat("Area through Trapezoidal Method:    ",result$TrapArea1,"\n")
  cat("CI Upper bound (Percentil Method):  ",result$ICUB1,"\n")
  cat("CI Lower bound (Percentil Method):  ",result$ICLB1,"\n")
  cat("------------------------------------------------\n")
  cat("\n")
  cat("------------------------------------------------\n")
  cat(mod2,"\n")
  cat("------------------------------------------------\n")
  cat("Area:                               ",result$Area2,"\n")
  cat("Standard Error:                     ",result$SE2,"\n")
  cat("Area through Trapezoidal Method:    ",result$TrapArea2,"\n")
  cat("CI Upper bound (Percentil Method):  ",result$ICUB2,"\n")
  cat("CI Lower bound (Percentil Method):  ",result$ICLB2,"\n")
  cat("------------------------------------------------\n")
  cat("\n")
  cat("Correlation Coefficient between areas:  ", result$CorrCoef,"\n")
  cat("\n")
  cat("TEST OF DIFFERENCES\n")
  cat("Z stats:  ", result$zstats,"\n")
  cat("p-value:  ", result$pvalue1,"\n")
  cat("\n")
  cat("Sum of Global Areas Differences (TS):  ", result$diff,"\n")
  cat("CI Upper bound (Percentil Method):  ",result$ICUBDiff,"\n")
  cat("CI Lower bound (Percentil Method):  ",result$ICLBDiff,"\n")
  cat("\n")
  cat("Number of Crossings:  ", result$nCross,"\n")
}
