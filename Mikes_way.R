## Calling the packages
library(raster)
library(maptools)
library(rgdal)
library(SpaDES)

# Setup projection parameter for use throughout script
projection <- "+proj=longlat +ellps=WGS84 +dtaum=WGS84 +no_defs"

# Setup extent parameter for use throughout script
ext <- extent(78, 90, 25, 32) #first two values are longitude and the later two are latitude

## Read the base rater for resolution ############
assign(paste0("Elev_", "raw"), raster("elev_output.asc"))

############# Environmental variable-4 Road ############
roads.v <- readOGR(dsn = "Layers", layer = "Road")
# plot(roads.v)

# plot(Elev_raw)
# lines(roads.v)

r <- Elev_raw  # this will be the template
r[] <- NA  # assigns all values as NA
summary(r) # shows you what you have: all NA's
 roads.r <- rasterize(roads.v, r, field=1)
summary(roads.r)          # pixels crossed by a road have "1"
plot(roads.r, add=TRUE)

Split <- splitRaster(roads.r, 5, 2, c(10, 10))
number <- length(Split)

for(i in 1:number){
road_dist <- Split[[i]]
# buff <- buffer(Split[[i]], width=50000)
roaddist.r <- distance(road_dist)
name <-paste("road_",as.character(i),".tiff")
name <- gsub(" ","",name)
writeRaster(roaddist.r, name, "GTiff")
# writeOGR(roaddist.r, dsn="split" ,layer=name,driver="ESRI Shapefile")
}
plot(roads.r)
roaddist.r <- distance(road_dist)
roaddist.r <- distance(roads.r)
class(roaddist.r)
# Check:
plot(roaddist.r)
lines(roads.v) 
writeRaster(roaddist.r, "DistFromRoad.tiff", "GTiff")



