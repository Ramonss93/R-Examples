# TODO: Add comment
# 
# Author: ecor
###############################################################################


NULL
#'
#' It calculates dry/wet spell duration. 
#' 
#' 
#' @param data data frame R object containing daily precipitation time series for several gauges (one gauge time series per column). 
#' @param valmin threshold precipitation value [mm] for wet/dry day indicator.
#' @param origin character string \code{"yyyy-mm-dd"} indicated the date of the first row of \code{"data"}. 
#' @param extract string charecter referred to the state to be extracted, eg. \code{"dry"} or \code{"wet"}
#' @param month integer vectors containing the considered months. Default is \code{1:12} (all the year). 
#' @export
#'
#' 
#' @return Function returns a list of data frames containing the spell length expressed in days
#' 
#' @examples  
#' library(RMRAINGEN)
#' 
#' 
#' data(trentino)
#' 
#' year_min <- 1961
#' year_max <- 1990
#' 
#' period <- PRECIPITATION$year>=year_min & PRECIPITATION$year<=year_max
#' station <- names(PRECIPITATION)[!(names(PRECIPITATION) %in% c("day","month","year"))]
#' prec_mes <- PRECIPITATION[period,station]  
#' 
#' ## removing nonworking stations (e.g. time series with NA)
#' accepted <- array(TRUE,length(names(prec_mes)))
#' names(accepted) <- names(prec_mes)
#' for (it in names(prec_mes)) {
#' 		 accepted[it]  <- (length(which(!is.na(prec_mes[,it])))==length(prec_mes[,it]))
#' }
#'
#' prec_mes <- prec_mes[,accepted]
#' ## the dateset is reduced!!! 
#' prec_mes <- prec_mes[,1:3]
#' 
#' origin <- paste(year_min,1,1,sep="-")
#' dw.spell <- dw.spell(prec_mes,origin=origin)
#' dw.spell.dry <- dw.spell(prec_mes,origin=origin,extract="dry")
#' 
#' hist(dw.spell.dry$T0001$spell_length)
#' 
#' 


dw.spell <- function(data,valmin=0.5,origin="1961-1-1",extract=NULL,month=1:12) {
	
	
	out <- list()
	
	data <- adddate(data,origin=origin)
	ignore.date <- !(names(data) %in% c("year","month","day"))
	###data <- data[,!(names(data) %in% c("year","month","day"))]
	
	for (c in 1:ncol(data[,ignore.date])){
		
		val <- as.vector(data[,ignore.date][,c])
		
		spell_state <- array("dry",length(val))
		
		spell_length <- array(1,length(val))
	###	spellstart <- array(FALSE,length(val))
		spell_end <- array(FALSE,length(val))
		spell_state[which(is.na(val))] <- "na"
		spell_state[which(val>valmin)] <- "wet"
	
		
		spell_end[1] <- TRUE
		
		for (i in 2:length(spell_state)) {
			
			if (spell_state[i]==spell_state[i-1]) {
				
				spell_end[i] <- TRUE 
				spell_end[i-1] <- FALSE
				spell_length[i] <- spell_length[i]+spell_length[i-1]
			} else{ 
			
				spell_end[i] <- TRUE 
				spell_length[i] <- 1 
			
			}
			
			
		}
	
		spell_length <- spell_length[which(spell_end)]
		spell_state <- spell_state[which(spell_end)]
		
		temp <- data[which(spell_end),!ignore.date]
		
		temp$spell_length <- spell_length
		temp$spell_state <- spell_state
		
		
		out[[c]] <- temp 
		
	}
	
	names(out) <- names(data[,ignore.date])
	
	if (!is.null(extract)) {
		
	
		
		out <- lapply(X=out,FUN=function(x,extract) {x[which(x$spell_state %in% extract),]},extract=extract)
		out <- lapply(X=out,FUN=function(x,month) {x[which(x$month %in% month),]},month=month)
	}
	
	
	
	return(out)
}