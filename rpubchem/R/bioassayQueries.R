.queryString <- "<PCT-Data>
  <PCT-Data_input>
    <PCT-InputData>
      <PCT-InputData_query>
        <PCT-Query>
          <PCT-Query_type>
            <PCT-QueryType>
              <PCT-QueryType_qas>
                <PCT-QueryActivitySummary>
                  <PCT-QueryActivitySummary_output value='summary-table'>0</PCT-QueryActivitySummary_output>
                  <PCT-QueryActivitySummary_type value='assay-central'>0</PCT-QueryActivitySummary_type>
                  <PCT-QueryActivitySummary_scids>
                    <PCT-QueryUids>
                      <PCT-QueryUids_ids>
                        <PCT-ID-List>
                          <PCT-ID-List_db>pccompound</PCT-ID-List_db>
                          <PCT-ID-List_uids>
                            <PCT-ID-List_uids_E>%s</PCT-ID-List_uids_E>
                          </PCT-ID-List_uids>
                        </PCT-ID-List>
                      </PCT-QueryUids_ids>
                    </PCT-QueryUids>
                  </PCT-QueryActivitySummary_scids>
                </PCT-QueryActivitySummary>
              </PCT-QueryType_qas>
            </PCT-QueryType>
          </PCT-Query_type>
        </PCT-Query>
      </PCT-InputData_query>
    </PCT-InputData>
  </PCT-Data_input>
</PCT-Data>"

.pollString <- '<PCT-Data>
  <PCT-Data_input>
    <PCT-InputData>
      <PCT-InputData_request>
        <PCT-Request>
          <PCT-Request_reqid>%s</PCT-Request_reqid>
          <PCT-Request_type value="status"/>
        </PCT-Request>
      </PCT-InputData_request>
    </PCT-InputData>
  </PCT-Data_input>
</PCT-Data>'

get.aid.by.cid <- function(cid, type='raw', quiet=TRUE) {

  if (!(type %in% c('tested','active','inactive','discrepant','raw')))
      stop("Invalid type specified")
      
  url <- "http://pubchem.ncbi.nlm.nih.gov/pug/pug.cgi"

  ## perform query
  qstring <- gsub("\\n", "", sprintf(.queryString, cid))
  h = basicTextGatherer()
  curlPerform(url = 'http://pubchem.ncbi.nlm.nih.gov/pug/pug.cgi',
              postfields = qstring,
              writefunction = h$update)

  ## extract query id
  xml <- xmlTreeParse(h$value(), asText=TRUE, asTree=TRUE)
  root <- xmlRoot(xml)
  reqid <- xmlElementsByTagName(root, 'PCT-Waiting_reqid', recursive=TRUE)
  if (length(reqid) != 1) {
    if (!quiet) warning("Malformed request id document")
    return(NULL)
  }
  reqid <- xmlValue(reqid[[1]])

  ## start polling
  pstring <- gsub("\\n", "", sprintf(.pollString, reqid))
  reqid <- NA
  while(TRUE) {
    h = basicTextGatherer()
    curlPerform(url = 'http://pubchem.ncbi.nlm.nih.gov/pug/pug.cgi',
                postfields = pstring,
                writefunction = h$update)
    ## see if we got a waiting response
    root <- xmlRoot(xmlTreeParse(h$value(), asText=TRUE, asTree=TRUE))
    reqid <- xmlElementsByTagName(root, 'PCT-Waiting', recursive=TRUE)
    if (length(reqid) != 0) next
    break
  }

  ## OK, got the link to our result
  link <- xmlElementsByTagName(root, 'PCT-Download-URL_url', recursive=TRUE)
  if (length(link) != 1) {
    if (!quiet) warning("Polling finished but no download URL")
    return(NULL)
  }
  link <- xmlValue(link[[1]])

  ## OK, get data file
  tmpdest <- tempfile(pattern = 'abyc')
  tmpdest <- paste(tmpdest, '.gz', sep='', collapse='')
  status <- try(download.file(link,
                              destfile=tmpdest,
                              method='internal',
                              mode='wb', quiet=TRUE),
                silent=TRUE)
  if (class(status) == 'try-error') {
    if (!quiet) warning(status)
    return(NULL)
  }

  ## OK, load the data
  csvfile <- strsplit(tmpdest, '\\.')[[1]][1]
  .gunzip(tmpdest, csvfile)
  dat <- read.csv(csvfile,header=TRUE,fill=TRUE,
                  quote='', row.names=NULL)
  unlink(tmpdest)

  valid.rows <- grep("^[[:digit:]]*$", dat[,1])
  dat <- dat[valid.rows,1:5]
  row.names(dat) <- 1:nrow(dat)
  for (i in 1:5) dat[,i] <- as.numeric(as.character(dat[,i]))
  names(dat) <- c('aid', 'active', 'inactive', 'descrepant', 'tested')
  ret <- dat

  type <- type[1]
  switch(type,
         active = dat[dat$active == 1,1],
         inactive = dat[dat$inactive == 1,1],
         discrepant = dat[dat$discrepant == 1,1],
         tested = dat[,1],
         raw = ret[,-5])
}
