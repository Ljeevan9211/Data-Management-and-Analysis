# Codes modified from https://www.azavea.com/blog/2018/10/09/preparing-data-for-maxent-species-distribution-modeling-using-r/
# Installl necessary packages and libraries
library(sf)
library(raster)
library(rgdal)
library(tidyverse)
library(rgeos)
library(scales)
library(fasterize)

# Setup projection parameter for use throughout script
projection <- "+proj=longlat +ellps=WGS84 +datum=WGS84 +no_defs"

# Setup extent parameter for use throughout script
ext <- extent(78, 90, 25, 32) #first two values are longitude and the later two are latitude

#########################################################################
# Process for Environmental Variable 1 - Population density  #### RASTER
#########################################################################
# Read in raster data
assign(paste0("pop_", "raw"), raster("gpw_v4_population_density_adjusted_to_2015_unwpp_country_totals_rev11_2015_30_sec_3.asc"))
pop_raw
# Reproject to our shared parameter
assign(paste0("pop_", "projected"),
projectRaster(pop_raw, crs = projection))

# Create variable equal to final raster
assign(paste0("pop_final"), (pop_projected))

# Extend pop_final to the desired extent with NA values
pop_extended <- extend(pop_final, ext, value = NA)

#####################################################################
####### Process for Environmental Variable 2 - Elevation  #### RASTER
#####################################################################
# Read in raster data
assign(paste0("elev_", "raw"), raster("Raster/merged_SRTM.tif"))

# Reproject to our shared parameter
assign(paste0("elev_", "projected"),
projectRaster(elev_raw, crs = projection))

# Create variable equal to final raster
assign(paste0("elev_final"), elev_projected)

# Extend elev_final to the desired extent with NA values
elev_extended <- extend(elev_final, ext, value = NA)

###############################################################
# Process for Environmental Variable 3 - Forest  #### RASTER
###############################################################
# Read in raster data
assign(paste0("forest_", "raw"), raster("Raster/merge.tif"))

# Reproject to our shared parameter
assign(paste0("forest_", "projected"),
projectRaster(forest_raw, crs = projection))

# Create variable equal to final raster
assign(paste0("forest_final"), forest_projected)

# Extend elev_final to the desired extent with NA values
forest_extended <- extend(forest_final, ext, value = NA)

########################################################################
# Process for Environmental Variable 6 - Protected area ### VECTOR
########################################################################
# read in spatial data
assign(paste0("PA", "_raw"),
sf::st_read(dsn="Layers", layer = "WDPA_Jul2019_NPL-shapefile-polygons"))

# Convert new spatial vector data to raster
require(raster)
hold.raster <- raster()
extent(hold.raster) <- extent(elev_raw)
res(hold.raster) <- res(elev_raw)
assign(paste0("PA", "_rasterized"),
fasterize(PA_raw, hold.raster, 'PA_DEF'))

# Reproject to our shared parameter
assign(paste0("PA_", "projected"),
projectRaster(PA_rasterized, crs = projection))

# Create variable equal to final raster
assign(paste0("PA_final"), PA_projected)

PA_final_re <- resample(PA_final, elev_final)
PA_tend <- extend(PA_final_re, ext, value = NA)
writeRaster(PA_tend, filename = "PA_output.asc", format = 'ascii', overwrite = TRUE)
### Resampling the layers to share same resolutions 
# Pick variable with the smallest pixels if you have time and the space for larger file sizes
# For quick processing and small files, pick the varaible with the largest pixels

## Here, we use elev_final to resample
# landcover_final_re <- resample(landcover_final, elev_final) #repeat this for each variables
forest_final_re <- resample(forest_extended, elev_final) #repeat this for each variables
pop_final_re <- resample(pop_extended, elev_final) #repeat this for each variables
elev_final_re <- resample(elev_extended, elev_final) #repeat this for each variables

# Re-extend the datasets to make sure that their shared extent was not influenced by the resampling
# landcover_tend <- extend(landcover_final_re, ext, value = NA)
forest_tend <- extend(forest_final_re, ext, value = NA)
pop_tend <- extend(pop_final_re, ext, value = NA)
elev_tend <- extend(elev_final_re, ext, value = NA)

# Write these datasets into .asc format for Maxent GUI
# writeRaster(landcover_tend, filename = "landcover_output.asc", format = 'ascii', overwrite = TRUE)
writeRaster(forest_tend, filename = "forest_output.asc", format = 'ascii', overwrite = TRUE)
writeRaster(pop_tend, filename = "pop_output.asc", format = 'ascii', overwrite = TRUE)
writeRaster(elev_tend, filename = "elev_output.asc", format = 'ascii', overwrite = TRUE)


assign(paste0("pop_", "raw"), raster("pop_output.asc"))
pop_raw[is.na(pop_raw)] <- 0
writeRaster(pop_raw, filename = "pop_output.asc", format = 'ascii', overwrite = TRUE)
