MMPC.temporal = function(target , reps, group, dataset , max_k = 3 , threshold = 0.05 , test = NULL , user_test = NULL, hash=FALSE, hashObject=NULL, slopes = FALSE, ncores = 1)
{
 #get the log threshold
  threshold = log(threshold)
      
  ##############################
  # initialization part of SES #
  ##############################

  faster = 0;
  #assign("gRbaseON",0,envir = .GlobalEnv)
  options(warn=-1)
  if(requireNamespace("gRbase", quietly = TRUE, warn.conflicts = FALSE) == TRUE)
  {
    #assign("gRbaseON",1,envir = .GlobalEnv)
    faster = 1;
  }
  options(warn=0);

  equal_case = 3;
  stat_hash = NULL;
  pvalue_hash = NULL;
  
  if(hash == TRUE)
  {
    if(requireNamespace("hash"))
    {
      if(is.null(hashObject))
      {
        stat_hash = hash();
        pvalue_hash = hash();
      }else if(class(hashObject) == "list"){
        stat_hash = hashObject$stat_hash;
        pvalue_hash = hashObject$pvalue_hash;
      }else{
        stop('hashObject must be a list of two hash objects (stat_hash, pvalue_hash)')
      }
    }else{
      cat('The hash version of SES requires the hash package');
      return(NULL);
    }
  }
  
  dataInfo = NULL;
  
  ###################################
  # dataset checking and initialize #
  ###################################
  
  if(!is.null(dataset))
  {
    #check if dataset is an ExpressionSet object of Biobase package
    if(class(dataset) == "ExpressionSet")
    {
      #get the elements (numeric matrix) of the current ExpressionSet object.
      dataset = Biobase::exprs(dataset);
      dataset = t(dataset); #take the features as columns and the samples as rows
    } else if ( class(dataset) == "matrix" | class(dataset) == "data.frame" ){
      target = target 
    } else {
      stop('Invalid dataset class. It must be either a matrix, a dataframe or an ExpressionSet');
    }
  }
    if(is.null(dataset) || is.null(target) )
    {
      stop('invalid dataset or target (class feature) arguments.');
    }else{
      target = target;
    }
  
  #check for NA values in the dataset and replace them with the variable mean
  if(any(is.na(dataset)) == TRUE)
  {
    dataset = as.matrix(dataset);
    warning("The dataset contains missing values and they were replaced automatically by the variable (column) mean.")
    dataset = apply(dataset, 2, function(x){ x[which(is.na(x))] = mean(x,na.rm = TRUE) ; return(x) });
  }
  
  ##################################
  # target checking and initialize #
  ##################################
  
  targetID = -1;
  
  #check if the target is a string
  if (is.character(target) && length(target) == 1){
    findingTarget <- target == colnames(dataset);#findingTarget <- target %in% colnames(dataset);
    if(!sum(findingTarget)==1){
      warning('Target name not in colnames or it appears multiple times');
      return(NULL);
    }
    targetID <- which(findingTarget);
    target <- dataset[ , targetID];
  }
  
  #checking if target is a single number
  if (is.numeric(target) && length(target) == 1){
    if(target > dim(dataset)[2]){
      warning('Target index larger than the number of variables');
      return(NULL);
    }
    targetID <- target;
    target <- dataset[ , targetID];
  }
  
  ################################
  # test checking and initialize #
  ################################
  
  if(typeof(user_test) == "closure")
  {
    test = user_test;
  }else{
    #auto detect independence test in case of not defined by the user and the test is null or auto
    if(is.null(test) || test == "auto")
    {
      #if target is a factor then use the Logistic test
      if("factor" %in% class(target))
      {
        test = "testIndGLMM";
        if(is.ordered(target) == TRUE)
        {
          dataInfo$target_type = "binary";
          
          cat('\nTarget variable type: Binary')
        }else{
          if(length(unique(target)) == 2)
          {
            dataInfo$target_type = "binary"
            cat('\nTarget variable type: Binomial')
          }else{
            dataInfo$target_type = "nominal"
            cat('\nTarget variable type: Nominal')
          }
        }
      }else if(class(target) == "numeric" || class(target) == "matrix"){
        if(class(target) == "matrix")
        {
          if(dim(target)[2]!=1)
          {
            stop('Target can not be a matrix')
          }
        }
        
        if(identical(floor(target),target) == TRUE)
        {
          if(length(unique(target)) == 2)
          {
            dataInfo$target_type = "binary";
            cat('\nTarget variable type: Binary')
            test = "testIndGLMM";
          }else{
            test = "testIndGLMM";
            dataInfo$target_type = "discrete";
            cat('\nTarget variable type: Discrete')
          }
        }else{
          dataInfo$target_type = "normal";
          cat('\nTarget variable type: Normal')
          test = "testIndGLMM";  
        }
      }else{
        stop('Target must be a factor, vector, matrix with one column or a Surv object');
      }
    }
    
    if(test == "testIndGLMM")
    {

       if(identical(floor(target),target) == TRUE)
        {
          if(length(unique(target)) == 2)
          {
            dataInfo$target_type = "binary";
            cat('\nTarget variable type: Binary')
            test = "testIndGLMM";
          }else{
            test = "testIndGLMM";
            dataInfo$target_type = "discrete";
            cat('\nTarget variable type: Discrete')
          }
        }else{
          dataInfo$target_type = "normal";
          cat('\nTarget variable type: Normal')
          test = "testIndGLMM";  
        }
      
      if(is.ordered(target) == TRUE)
      {
        dataInfo$target_type = "binary";
        #cat('\nTarget variable type: Binary')
        
        if(requireNamespace("lme4", quietly = TRUE, warn.conflicts = FALSE)==FALSE)
        {
          cat("The testIndGLMM test requires the lme4 package for the glmm. Please install it.");
          return(NULL);
        }
        
      }else{
        if(identical(floor(target),target) == TRUE)
        {
          if(length(unique(target)) == 2)
          {
            dataInfo$target_type = "binary";
            cat('\nTarget variable type: Binary')
            test = "testIndGLMM";
          }else{
            test = "testIndGLMM";
            dataInfo$target_type = "discrete";
            cat('\nTarget variable type: Discrete')
          }
        }else{
          dataInfo$target_type = "normal";
          cat('\nTarget variable type: Normal')
          test = "testIndGLMM";  
        }
        
        if(requireNamespace("lme4", quietly = TRUE, warn.conflicts = FALSE)==FALSE)
        {
          cat("The testIndGLMM test requires the lme4 package for the glmm. Please install it.");
          return(NULL);
        }
        
      }
    }
    
    cat("\nConditional independence test used: ");cat(test);cat("\n");
    
    #available conditional independence tests
    av_tests = c("testIndGLMM", "auto" ,  NULL);
    
    ci_test = test
    if(length(test) == 1) #avoid vectors, matrices etc
    {
      test = match.arg(test , av_tests ,TRUE);
      #convert to closure type
      if(test == "testIndGLMM")
      {
        #an einai posostiaio target
         if ( all(target > 0 & target < 1) ){
         target = log( target/(1 - target) ) ## logistic normal 
         }
        
        test = testIndGLMM;
      }
      
    }else{
      stop('invalid test option');
    }
  }
  
  ###################################
  # options checking and initialize #
  ###################################
  
  #extracting the parameters
  max_k = floor(max_k);
  varsize = dim(dataset)[[2]];
  
  #option checking
  if((typeof(max_k)!="double") || max_k < 1)
  {
    stop('invalid max_k option');
  }
  if(max_k > varsize)
  {
    max_k = varsize;
  }
  if((typeof(threshold)!="double") || exp(threshold) <= 0 || exp(threshold) > 1)
  {
    stop('invalid threshold option');
  }
  if(typeof(equal_case)!="double")
  {
    stop('invalid equal_case option');
  }
  
  #######################################################################################

  if(!is.null(user_test))
  {
    ci_test = "user_test";
  }

  #call the main MMPC.temporal function after the checks and the initializations
  results = InternalMMPC.temporal(target, reps, group, dataset, max_k, threshold , test, user_test, dataInfo, hash, varsize, stat_hash, pvalue_hash, targetID, faster, slopes = slopes, ncores = ncores);
  
  MMPC.temporaloutput <-new("MMPC.temporaloutput", selectedVars = results$selectedVars, selectedVarsOrder=results$selectedVarsOrder, hashObject=results$hashObject, pvalues=results$pvalues, stats=results$stats, max_k=results$max_k, threshold = results$threshold, runtime=results$runtime, test=ci_test, slope = slopes);
  
  return(MMPC.temporaloutput);
  
}

#########################################################################################################

InternalMMPC.temporal = function(target , reps, group, dataset , max_k, threshold , test = NULL , user_test = NULL , dataInfo = NULL , hash=FALSE, varsize, stat_hash, pvalue_hash, targetID, faster, slopes = slopes, ncores = ncores)
{
  #get the current time
  runtime = proc.time();
  
  #######################################################################################
  
  rows = length(target)
  cols = ncol(dataset)
  
  #univariate feature selection test
  
  univariateModels = univariateScore.temporal(target , reps, group, dataset , test, hash=hash, dataInfo, stat_hash=stat_hash, pvalue_hash=pvalue_hash, targetID, slopes = slopes, ncores = ncores);
  
  
  pvalues = univariateModels$pvalue;
  stats = univariateModels$stat;
  flags = univariateModels$flag;
  stat_hash = univariateModels$stat_hash;
  pvalue_hash = univariateModels$pvalue_hash;
  #if we dont have any associations , return
  if(min(pvalues , na.rm=TRUE) > threshold) #or min(pvalues, na.rm=TRUE)
  {
    cat('No associations!');
    
    results = NULL;
    results$selectedVars = c();
    class(results$selectedVars) = "numeric";
    results$selectedVarsOrder = c();
    class(results$selectedVarsOrder) = "numeric";
    results$hashObject = NULL;
    class(results$hashObject) = 'list';
    
    results$pvalues = exp(pvalues);
    results$stats = stats;
    results$max_k = max_k;
    results$threshold = exp(threshold);
    runtime = proc.time() - runtime;
    results$runtime = runtime;
    results$slope = slopes
    
    return(results);
  }
  
  
  #Initialize the data structs
  selectedVars = numeric(varsize);
  selectedVarsOrder = numeric(varsize);
  
  #select the variable with the highest association
  selectedVar = which(flags == 1 & stats == stats[[which.max(stats)]]);
  selectedVars[selectedVar] = 1;
  selectedVarsOrder[selectedVar] = 1; #CHANGE
  
  #lets check the first selected var
  #cat('First selected var: %d, p-value: %.6f\n', selectedVar, pvalues[selectedVar]);
  
  #remaining variables to be considered
  remainingVars = numeric(varsize) + 1;
  remainingVars[selectedVar] = 0;
  remainingVars[pvalues > threshold] = 0;
  if (targetID > 0){
    remainingVars[targetID] = 0;
  }
  
  ################ main MMPC.temporal loop ################
  
  #main MMPC.temporal loop
  #loop until there are not remaining vars
  loop = any(as.logical(remainingVars));
  
  while(loop)
  {
    #lets find the variable with the max min association
    max_min_results = max_min_assoc.temporal(target, reps, group, dataset , test , threshold , max_k , selectedVars , pvalues , stats , remainingVars , univariateModels, selectedVarsOrder, hash=hash, dataInfo, stat_hash=stat_hash, pvalue_hash=pvalue_hash, faster, slopes = slopes);
    selectedVar = max_min_results$selected_var;
    selectedPvalue = max_min_results$selected_pvalue;
    remainingVars = max_min_results$remainingVars;
    pvalues = max_min_results$pvalues;
    stats = max_min_results$stats;
    stat_hash=max_min_results$stat_hash;
    pvalue_hash=max_min_results$pvalue_hash;
    
    #if the selected variable is associated with target , add it to the selected variables
    if(selectedPvalue <= threshold)
    {
      selectedVars[selectedVar] = 1;
      selectedVarsOrder[selectedVar] = max(selectedVarsOrder) + 1;
      remainingVars[selectedVar] = 0;
    }
    
    loop = any(as.logical(remainingVars));
  }
  
  selectedVarsOrder[which(!selectedVars)] = varsize;#
  numberofSelectedVars = sum(selectedVars);#
  selectedVarsOrder = sort(selectedVarsOrder);#
  #   selectedVars = selectedVarsOrder[1:numberofSelectedVars];
  
  #adjusting the results
  if(targetID > 0)
  {
    toAdjust <- which(selectedVars > targetID);
    selectedVars[toAdjust] = selectedVars[toAdjust] + 1;
  }
  
  results = NULL;
  results$selectedVars = which(selectedVars == 1);
  
  svorder = sort(pvalues[results$selectedVars] , index.return = TRUE);
  svorder = results$selectedVars[svorder$ix];
  results$selectedVarsOrder = svorder;
  
  hashObject = NULL;
  hashObject$stat_hash = stat_hash;
  hashObject$pvalue_hash = pvalue_hash;
  results$hashObject = hashObject;
  class(results$hashObject) = 'list';
  
  results$pvalues = exp(pvalues);
  results$stats = stats;
  results$max_k = max_k;
  results$threshold = exp(threshold);
  
  runtime = proc.time() - runtime;
  results$runtime = runtime;
  results$slope = slopes
  
  
  return(results);
}

#univariate feature selection ( uncoditional independence )

# univariateScore.temporal = function(target , reps, group, dataset , test, hash, dataInfo, stat_hash=stat_hash, pvalue_hash=pvalue_hash, targetID, slopes, ncores)
# {
#   #how many tests
#   nTests = ncol(dataset);
#   
#   #data structure to be returned
#   univariateModels = NULL;
#   univariateModels$pvalue = numeric(nTests) 
#   univariateModels$stat = numeric(nTests)
#   univariateModels$flag = numeric(nTests) 
#   #univariateModels$uniModelFit = rep(NA,nTests);
#   
#   test_results = NULL;
#   #for way to initialize the univariateModel
#   #FOR LOOP IS FASTER THAN VAPPLY IN THIS CASE (try apply withm margin 2)
#   if ( ncores == 1 | is.null(ncores) | ncores <= 0 ) {
#     for(i in 1:nTests)
#     {
#       #arguments order for any CI test are fixed
#       if (i != targetID){
#         test_results = test(target, reps, group, dataset, i, 0, dataInfo = dataInfo, hash = hash, stat_hash = stat_hash, pvalue_hash = pvalue_hash, slopes)
#         univariateModels$pvalue[[i]] = test_results$pvalue;
#         univariateModels$stat[[i]] = test_results$stat;
#         univariateModels$flag[[i]] = test_results$flag;
#         univariateModels$stat_hash = test_results$stat_hash
#         univariateModels$pvalue_hash = test_results$pvalue_hash      
#       }else{
#         univariateModels$pvalue[[i]] = 1;
#         univariateModels$stat[[i]] = 0;
#         univariateModels$flag[[i]] = 1;
#       }
#     }
#     return(univariateModels);
#   } else {
#    # require(doParallel, quietly = TRUE, warn.conflicts = FALSE)  
#     cl <- makePSOCKcluster(ncores)
#     registerDoParallel(cl)
#     test = test
#     mod <- foreach(i = 1:nTests, .combine = rbind) %dopar% {
#     ## arguments order for any CI test are fixed
#       if (i != targetID) {
#         test_results = test(target, reps, group, dataset, i, 0, dataInfo = dataInfo, hash = hash, stat_hash = stat_hash, pvalue_hash = pvalue_hash, slopes)
#         return( c(test_results$pvalue, test_results$stat, test_results$flag, test_results$stat_hash, test_results$pvalue_hash) )
#       } else{
#         return( c(1, 0, 1, test_results$stat_hash, test_results$pvalue_hash) )
#       }
#     }
#     stopCluster(cl)
#     univariateModels$pvalue = as.vector( mod[, 1] )
#     univariateModels$stat = as.vector( mod[, 2] )
#     univariateModels$flag = as.vector( mod[, 3] )
#     if ( ncol(mod) == 3 ) { 
#       univariateModels$stat_hash = NULL
#       univariateModels$pvalue_hash = NULL   
#     } 
#   }
#     return(univariateModels);
# }

#########################################################################################################
# 
# #just like matlab's nchoosek but with transposed result
# #Its a slightly different from combn() 
# #(ex. (nchoosekm(4,2) != nchoosekm(1:4,2) like nchoosek in matlab , combn(4,2) == combn(1:4,2)))
# nchoosekm = function(cs , k, faster) #i can also pass the compFun arg for selecting
# { 
#   if(length(cs) == 1) #if not vector
#   {
#     res = choose(cs , k); #or nchoosek
#   }else{
#     if(faster == 1)
#     {
#       res = gRbase::combnPrim(cs,k); #combs(as.vector(cs),k); #combnPrim
#     }else
#     {
#       res = combn(cs,k);
#     }
# 
#   }
#   return(res);
# }
# 
# #########################################################################################################
# 
# compare_p_values = function(pval, pval2, stat, stat2)
# {
#   if(length(pval) == 0 | length(pval2) == 0 | length(stat) == 0 | length(stat2) ==0)
#   {
#     return(FALSE);
#   }else{
#     if(is.na(pval2)==TRUE | is.na(stat2)==TRUE | is.na(pval)==TRUE | is.na(stat)==TRUE)
#     {
#       pval2 = 0.0;
#       return(FALSE);#(pval < pval2);
#     }else{
# #       if (pval <= 2e-16 | pval2 <= 2e-16){
# #         return(stat > stat2);
# #       }else{
#         return(pval < pval2);
#       # }
#     }
#   }
# }
# 
# #########################################################################################################
# 
# max_min_assoc.temporal = function(target, reps, group, dataset , test , threshold , max_k , selectedVars , pvalues , stats , remainingVars , univariateModels, selectedVarsOrder, hash, dataInfo, stat_hash, pvalue_hash, faster, slopes = slopes)
# {
#   #Initialize
#   selected_var = -1;
#   selected_pvalue = 2;
#   selected_stat = 0;
#   
#   varsToIterate = which(remainingVars==1);
#   for(cvar in varsToIterate)
#   {
#     mma_res = min_assoc.temporal(target, reps, group, dataset , test , max_k , cvar , selectedVars , pvalues , stats , univariateModels , selectedVarsOrder, hash, dataInfo, stat_hash, pvalue_hash, faster, slopes = slopes);
#     pvalues = mma_res$pvalues;
#     stats = mma_res$stats;
#     stat_hash = mma_res$stat_hash;
#     pvalue_hash = mma_res$pvalue_hash;
#     
#     
#     if(mma_res$pvalue > threshold)
#     {
#       remainingVars[[cvar]] = 0;
#     }
#     
#     if(compare_p_values(mma_res$pvalue , selected_pvalue , mma_res$stat , selected_stat))
#     {
#       selected_var = cvar;
#       selected_pvalue = mma_res$pvalue;
#       selected_stat = mma_res$stat;
#     }
#   }
#   results <- list(selected_var = selected_var , selected_pvalue = selected_pvalue , remainingVars = remainingVars , pvalues = pvalues , stats = stats, stat_hash=stat_hash, pvalue_hash = pvalue_hash, slope = slopes);
#   return(results); 
# }
# 
# #########################################################################################################
# 
# min_assoc.temporal = function(target , reps, group, dataset , test ,  max_k , cvar , selectedVars , pvalues , stats , univariateModels , selectedVarsOrder, hash, dataInfo, stat_hash, pvalue_hash, faster, slopes = slopes)
# {
#   #initialization
#   #baseline values
#   #   ma_pvalue = univariateModels$pvalue[[cvar]];
#   #   ma_stat = univariateModels$stat[[cvar]];
#   ma_pvalue = pvalues[[cvar]]; #CHANGE
#   ma_stat = stats[[cvar]]; #CHANGE
#   
#   selectedVars = which(selectedVars==1);
#   #max size of the condiotioning test
#   k = min(c(max_k , length(selectedVars)));
#   
#   ck = 1;
#   while(ck<=k)
#   {
#     #lastvar = unique(which(selectedVarsOrder == max(selectedVarsOrder)));
#     lastvar = which(selectedVarsOrder == max(selectedVarsOrder))[1]; #CHANGE
#     
#     tempCS = setdiff(selectedVars, lastvar) #CHANGE
#     if(ck == 1) #CHANGE
#     {
#       subsetcsk = as.matrix(lastvar); #CHANGE
#     }else{
#       subsetcsk = as.matrix(nchoosekm(tempCS,ck-1,faster)); #CHANGE
#       numSubsets = dim(subsetcsk)[2]; #CHANGE
#       subsetcsk = rbind(subsetcsk, lastvar*rep(1,numSubsets)); #CHANGE
#     }
#     
#     #or combs or nchoosekm
#     #subsetcsk = as.matrix(nchoosekm(1:length(selectedVars),ck));
#     
#     #subsetcsk = t(subsetcsk);
#     for(i in 1:ncol(subsetcsk))
#     {
#       s = subsetcsk[,i];
#       s = t(t(s));
#       
#       cur_results = test(target , reps, group, dataset , cvar, s , dataInfo=dataInfo, univariateModels, hash = hash, stat_hash, pvalue_hash, slopes = slopes);
#       stat_hash = cur_results$stat_hash;
#       pvalue_hash = cur_results$pvalue_hash;
#       
#       #check if the pvalues and stats should be updated
#       if(cur_results$flag == 1 & !compare_p_values(cur_results$pvalue, ma_pvalue, cur_results$stat , ma_stat))
#       {
#         ma_pvalue = cur_results$pvalue;
#         pvalues[[cvar]] = cur_results$pvalue;
#         
#         ma_stat = cur_results$stat;
#         stats[[cvar]] = cur_results$stat;
#       }
#     }
#     ck = ck+1;
#   }
#   results <- list(pvalue = ma_pvalue , stat = ma_stat , pvalues = pvalues , stats = stats, stat_hash=stat_hash, pvalue_hash  = pvalue_hash, slope = slopes);
#   return(results);
# }
# 
# # .onAttach <- function(libname, pkgname){
# #   # do whatever needs to be done when the package is loaded
# #   packageStartupMessage( "Loading MXM package version 0.2, thanks for downloading." )
# #   #load the dll files from the fortran code for the package
# #   #library.dynam("MXM", pkgname, libname)
# # }
