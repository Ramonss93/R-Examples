

bmaps.quadkey <- function(tilex, tiley, zoom) {
  nzoom <- 2^zoom
  if(tilex < 0 || tilex >= nzoom) stop("xtile out of range: ", tilex)
  if(tiley < 0 || tiley >= nzoom) stop("ytile out of range: ", tilex)
  out <- ""
  keymap <- matrix(0:3, byrow=TRUE, ncol=2)
  decx <- tilex/nzoom
  decy <- tiley/nzoom
  for(i in 1:zoom) {
    n <- 2^i
    x <- floor(decx*2^i) - floor(decx*2^(i-1))*2
    y <- floor(decy*2^i) - floor(decy*2^(i-1))*2
    out <- paste0(out, keymap[y+1,x+1])
  }
  out
}

bmaps.restquery <- function(bingtype, key=NULL) {
  #http://dev.virtualearth.net/REST/v1/Imagery/Metadata/Aerial?key=KEY
  #get a key at https://msdn.microsoft.com/en-us/library/ff428642.aspx
  if(is.null(key)) {
    key <- "Aut49nhp5_Twwf_5RHF6wSGk7sEzpcSA__niIXCHowQZLMeC-m8cdy7EmZd2r7Gs"
  }
  urlstring <- paste0("http://dev.virtualearth.net/REST/v1/Imagery/Metadata/", bingtype, "?key=", key)
  connect <- url(urlstring)
  lines <- try(readLines(connect, warn = FALSE), silent = TRUE)
  close(connect)

  if(class(lines) == "try-error") stop("  Bing REST query failed for type: ", bingtype)

  result <- rjson::fromJSON(paste(lines, collapse = ""))
  message(result$copyright)
  result$resourceSets[[1]]$resources[[1]]
}

bmaps.tileurlfromrest <- function(imageUrl, tilex, tiley, zoom) {
  gsub("{subdomain}", sample(c("t0", "t1", "t2", "t3"), 1),
       gsub("{quadkey}", bmaps.quadkey(tilex, tiley, zoom), imageUrl, fixed=TRUE), fixed=TRUE)
}

tile.url.bing <- function(typecode, ext, xtile, ytile, zoom) {
  #http://ecn.t2.tiles.virtualearth.net/tiles/a331.jpeg?g=587
  .bingtoken <- NULL ; rm(.bingtoken) #CMD check trick
  if(!exists(".bingtoken")) stop("use bmaps.plot() to plot Bing maps")
  if(is.null(.bingtoken)) stop("use bmaps.plot() to plot Bing maps")
  servers = c("t0", "t1", "t2", "t3")
  paste0("http://ecn.", sample(servers, 1), ".tiles.virtualearth.net/tiles/",
         typecode, bmaps.quadkey(xtile, ytile, zoom), ext, "?g=", .bingtoken)
}

tile.url.bing_Aerial <- function(xtile, ytile, zoom) {
  tile.url.bing("a", ".jpeg", xtile, ytile, zoom)
}

tile.url.bing_AerialWithLabels <- function(xtile, ytile, zoom) {
  tile.url.bing("h", ".jpeg", xtile, ytile, zoom)
}

tile.url.bing_Road <- function(xtile, ytile, zoom) {
  tile.url.bing("r", ".png", xtile, ytile, zoom)
}

#' List types of Bing Maps
#'
#'
#' @return A list of valid bing map types
#' @export
#'
#' @examples
#' bmaps.types()
#'
bmaps.types <- function() {
  c("Aerial", "AerialWithLabels", "Road")
}

#' Plot Bing Maps
#'
#' Identical syntax to \link{osm.plot}, but using Bing maps (\url{https://www.bing.com/maps/})
#' instead of Open Street Map.
#'
#' @param bbox A bounding box as generated by \code{sp::bbox()} or \code{prettymapr::searchbbox()}
#' @param type Use \code{Aerial}, \code{AerialWithLabels}, or \code{Road}.
#' @param key If plotting a large number of images, consider getting your own (free) key at
#' the \href{https://msdn.microsoft.com/en-us/library/ff428642.aspx}{Microsoft Website}.
#' @param ... Arguments passed on to \link{osm.plot}.
#'
#' @export
#'
#' @examples
#' \donttest{
#' library(prettymapr)
#' bmaps.plot(makebbox(47.2, -59.7, 43.3, -66.4))
#' bmaps.plot(makebbox(47.2, -59.7, 43.3, -66.4), type="Road")
#' }
#'
bmaps.plot <- function(bbox, type="Aerial", key=NULL, ...) {
  if(!(type %in% bmaps.types())) stop("type must be one of Aerial, AerialWithLabels, or Road")
  osmtype <- paste("bing", type, sep="_")

  .bingtoken <- NULL ; rm(.bingtoken) #CMD check trick

  rest <- bmaps.restquery(type, key)
  afterg <- strsplit(rest$imageUrl, "?g=", fixed=TRUE)[[1]][2]
  .bingtoken <<- strsplit(afterg, "&", fixed=TRUE)[[1]][1]
  osm.plot(bbox=bbox, type=osmtype, ...)
  .bingtoken <<- NULL
  extraargs <- list(...)
  bmaps.attribute(res=extraargs$res, cachedir=extraargs$cachedir)
}


bmaps.attribute <- function(padin=c(0.05,0.05), res=NULL, cachedir=NULL) {
  if(is.null(res)) {
    res <- 80
  }
  #http://dev.virtualearth.net/Branding/logo_powered_by.png
  bingfile <- file.path(tile.cachedir("bing"), "bing.png")
  if(!file.exists(bingfile)) {
    utils::download.file("http://dev.virtualearth.net/Branding/logo_powered_by.png",
                  bingfile, quiet=TRUE)
  }
  binglogo <- png::readPNG(bingfile)
  ext <- graphics::par("usr")
  rightin <- graphics::grconvertX(ext[2], from="user", to="inches")
  bottomin <- graphics::grconvertY(ext[3], from="user", to="inches")
  widthin <- dim(binglogo)[2]/res
  heightin <- dim(binglogo)[1]/res
  leftusr <- graphics::grconvertX(rightin-padin[1]-widthin, from="inches", to="user")
  bottomusr <- graphics::grconvertY(bottomin+padin[2], from="inches", to="user")
  topusr <- graphics::grconvertY(bottomin+padin[2]+heightin, from="inches", to="user")
  rightusr <- graphics::grconvertX(rightin-padin[1], from="inches", to="user")

  graphics::rasterImage(binglogo, leftusr, bottomusr, rightusr, topusr)
}
