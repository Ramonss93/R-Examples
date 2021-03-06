#' Installs & Loads Packages 
#' 
#' Installs a package provided the package is a CRAN package.
#' 
#' @rdname p_install
#' @param package Name of package(s).
#' @param character.only logical.  If \code{TRUE} \code{\dots} is treated a 
#' character string.
#' @param \ldots Additional parameters to pass to \code{install.packages}.
#' @param path The path to the directory that contains the package.  It is 
#' convenient to set \code{download_path} in .Rprofile options to the downloads 
#' directory.
#' @keywords install package
#' @seealso \code{\link[utils]{install.packages}}
#' @export
#' @examples
#' \dontrun{p_install(pacman)}
p_install <-
function(package, character.only = FALSE, path = getOption("download_path"), ...){

    if(!character.only){
        package <- as.character(substitute(package))
    }

    ## Detect if package ends in zip/tar.gz
    if (grepl("\\.tar\\.gz|\\.zip", package)) {

        if (file.exists(package)) {
            tar_path <- package
        } else {
            if (file.exists(file.path(path, package))) {
                tar_path <- file.path(path, package)
            } else {
                message("Package not found. Please select file...")
                tar_path <- file.choose()
            }      
        }
        utils::install.packages(tar_path, repos = NULL, type = "source", ...)
    } else {
      
        p_set_cranrepo()

        if (p_loaded(char = package)) {
            p_unload(char = package)
        }

        ## Handling if no package supplied
        if (length(package) == 1 && package == "") {
            package <- NULL 
        } 

        response <- tryCatch(
            utils::install.packages(package, ...),
            warning = function(w) {   
                ## for users with bioconductor on installed, check to see if
                ## package is available in the bioconductor repos
                if (!p_isinstalled('BiocInstaller')) {
                    source("http://bioconductor.org/biocLite.R")
                }           
                suppressMessages(suppressWarnings(
                    eval(parse(
                        text=sprintf("BiocInstaller::biocLite('%s', suppressUpdates=TRUE)", 
                            package)
                    ))
                ))
            
            }
        )
    }
    
    ## check if package was installed & success notification.
    pack <- ifelse(is.null(package), "Your package", package)

    if (pack %in% p_lib() | is.null(package)) {
        message(sprintf("\n%s installed", pack))
        return(invisible(TRUE))
    } else {
        # If unable to install, raise warning and continue
        warning(response)
        return(invisible(FALSE))
    }
}


#' @rdname p_install
#' @export
p_get <- p_install
