# Getting the number of species presence records along with their geolocation
# Loading camtrapR package as we use this package to get shapefile and records
library(camtrapR)
# writing shapefiles requires packages rgdal and sp
 library(rgdal)
 library(sp)


# Loading the camera trap file
camtraps <- read.csv("Camtrap.csv")

# Loading the recordtable that has already been created
Rtable <- read.csv("recordtable.csv")
All_species <- unique(Rtable$Species)

# Target species
species <- c("Leopard", "Yellow Throated Marten", "Barking Deer", "Langur", "Leopard Cat", "Assamese Macaque", "Red Panda")

## ------------------------------------------------------------------------
 # define shapefile name
 shapefileProjection <- "+proj=utm +zone=50 +ellps=WGS84 +datum=WGS84 +units=m +no_defs"

## Look for more elegant way to do this if you can
(directory <- paste(getwd(),"/Layer"))
(directory <- gsub(" /Layer", "/Layer", directory))


## Creating a loop to go through all the indicator species
for(i in 1:length(species)){
 shapefileName <- paste(species[i], "_TMJ") # giving it name with reference to the species
 shapefileName <- gsub(" ", "", shapefileName) # getting rid of the space in the filename
## ------------------------------------------------------------------------
 # subset to all individual species at a time
Rtable_sp <- Rtable[Rtable$Species == species[i],]
Maps <- detectionMaps(CTtable            = camtraps,
                          recordTable         = Rtable_sp,
                          Xcol                = "WGS_x",
                          Ycol                = "WGS_y",
                          stationCol          = "Station",
                          speciesCol          = "Species",
                          richnessPlot        = FALSE,         # no richness plot
                          speciesPlots        = FALSE,         # no species plots
                          writeShapefile      = TRUE,          # but shaepfile creation
                          shapefileName       = shapefileName,
                          shapefileDirectory  = directory,     # since I want my files created in the working directory  
                          shapefileProjection = shapefileProjection
)
fileName <- paste(species[i], "_TMJ",".csv")
fileName <- gsub(" ", "", fileName)
Maps_clean <- Maps[!is.na(Maps$n_species), ]
Maps_clean$Species <- species[i]
write.csv(Maps_clean, file = fileName) 
}