context("XLSX raster generation")
library(grid)
library(xml2)

test_that("raster is generated", {

  file <- tempfile()
  uid <- basename( tempfile( ))
  dml_xlsx( file = file, raster_prefix = uid, bg = "transparent" )
  pushViewport(viewport(width=0.8, height=0.5, name="vp1"))
  grid.rect( )
  pushViewport(viewport(width=0.8, height=0.5, name="vp2",angle=10))
  redGradient <- matrix(hcl(0, 80, seq(50, 80, 10)), nrow=4, ncol=5)
  grid.raster(redGradient )
  dev.off()

  raster_files <- list.files(pattern = paste0("^", uid, "(.*)\\.png$"), full.names = TRUE )
  expect_equal(length(raster_files), expected = 1)
})


test_that("pic tag can be found", {

  file <- tempfile()

  dml_xlsx( file = file, bg = "transparent" )
  pushViewport(viewport(width=0.8, height=0.5, name="vp1"))
  grid.rect( )
  pushViewport(viewport(width=0.8, height=0.5, name="vp2",angle=10))
  redGradient <- matrix(hcl(0, 80, seq(50, 80, 10)), nrow=4, ncol=5)
  grid.raster(redGradient )
  dev.off()


  doc <- read_xml(file)
  pic_node <- try( xml_find_one(doc, ".//xdr:pic", ns = xml_ns( doc )), silent = TRUE )
  expect_false( inherits(pic_node, "try-error") )

  blip_node <- try( xml_find_one(pic_node, ".//a:blip", ns = xml_ns( doc )), silent = TRUE )
  expect_false( inherits(blip_node, "try-error") )
})

unlink(list.files(pattern = "\\.png"), force = TRUE)
