lhc_process_netlogo_result <-
function(FILEPATH,LHCSAMPLE_RESULTFILENAME,SPARTAN_PARAMETER_FILE,NUMSAMPLES,MEASURES,LHC_ALL_SIM_RESULTS_FILE,TIMESTEP)
{
	# Not using this anymore, as we're using check.names=FALSE when reading CSV files
	# FIRST, WE MAY NEED TO CHANGE THE PARAMETER AND MEASURE STRINGS. WHEN R IMPORTS THE SPREADSHEET, ANY HYPHENS ARE CHANGED
	# TO DOTS, AND THIS NEEDS DETECTING
	#PARAMETERS<-table_header_check(PARAMETERS)
	#MEASURES<-table_header_check(MEASURES)

	# READ IN THE SPARTAN PARAMETER FILE
	LHCTABLE<-read.csv(paste(FILEPATH,"/",SPARTAN_PARAMETER_FILE,sep=""),header=TRUE,check.names=FALSE)

	# NOW ALL THE MEDIANS ARE HELD TOGETHER, ACCOMPANIED BY THEIR SIMULATION PARAMETERS BEING ANALYSED
	ALL_SIM_MEDIAN_RESULTS<-NULL

	for(SAMPLE in 1:NUMSAMPLES)
	{
		if(file.exists(paste(FILEPATH,"/",SAMPLE,"/",LHCSAMPLE_RESULTFILENAME,SAMPLE,".csv",sep="")))
		{
			print(paste("Processing LHC Results for Sample: ",SAMPLE,sep=""))

			# READ IN THE RESULT FILE
			# SKIP THE FIRST 6 LINES AS NONE OF THIS INFORMATION IS REQUIRED
			NL_RESULT<-read.csv(paste(FILEPATH,"/",SAMPLE,"/",LHCSAMPLE_RESULTFILENAME,SAMPLE,".csv",sep=""),sep=",",skip=6,check.names=FALSE)

			# ORDER IT BY RUN FOR EFFICIENCY LATER
			NL_RESULT_ORDERED<-NL_RESULT[order(NL_RESULT[,1]),]
	
			# REMOVE ALL THE OTHER TIMESTEPS AS NOT REQUIRED
			# THE TIMESTEP IS IN THE COLUMN HEADED X.step.
			# SET THIS TO NULL TO PLEASE CRAN SUBMISSION NOTE, THEN SUBSET
			#X.step.<-NULL
			#TIMESTEP_RESULTS<-subset(NL_RESULT_ORDERED,X.step.==TIMESTEP)
			# KA REMOVED APRIL 2015
			TIMESTEP_RESULTS<-subset(NL_RESULT_ORDERED,NL_RESULT_ORDERED["[step]"]==TIMESTEP)

			# NOW TO CREATE THE RESULTS FOR THIS SAMPLE SET
			# NETLOGO DOES GIVE THE OPTION OF RUNNING REPLICATES OF THE SAME EXPERIMENT
			# SO THERE MAY BE A FEW ROWS HERE. THE SUMMARY METHOD WILL TAKE CARE OF THESE REPLICATES
			# FIRST LETS SET UP THE NUMBER OF PARAMETER ROWS
			param_set<-LHCTABLE[SAMPLE,]

			# Make duplicates of the parameters to match the number of replicate runs	
			PARAMS<-NULL
			for(paramval in 1:ncol(param_set))
			{
				PARAMS<-cbind(PARAMS,param_set[[paramval]])
			}

			
			DUP_PARAMS<-NULL
			for(r in 1:nrow(TIMESTEP_RESULTS)-1)
			{
				DUP_PARAMS<-rbind(DUP_PARAMS,PARAMS)
			}

			# NOW WE CAN ADD THE RESULTS FOR EACH NETLOGO RUN
			for(RESPONSE in 1:length(MEASURES))
			{
				DUP_PARAMS<-cbind(DUP_PARAMS,TIMESTEP_RESULTS[MEASURES[RESPONSE]][,1])
			}

			ALL_SIM_MEDIAN_RESULTS<-rbind(ALL_SIM_MEDIAN_RESULTS,DUP_PARAMS)
			
		}
		else
		{
			print(paste("ERROR: Results for Sample ",SAMPLE," not found",sep=""))

		}
	}
	# NOW OUTPUT ALL THE MEDIAN RESULTS TO THE SPECIFIED FILEPATH
	colnames(ALL_SIM_MEDIAN_RESULTS)<-cbind(t(names(LHCTABLE)),t(MEASURES))

	# OUTPUT IF THE RESULTS ARE NOT BLANK
	if(!is.null(ALL_SIM_MEDIAN_RESULTS))
	{
		RESULTSFILE = paste(FILEPATH,"/",LHC_ALL_SIM_RESULTS_FILE,sep="")
		print(paste("Writing Median Results to CSV File: ",RESULTSFILE,sep=""))
		write.csv(ALL_SIM_MEDIAN_RESULTS,RESULTSFILE,quote = FALSE,row.names=FALSE)
	}
}
	

