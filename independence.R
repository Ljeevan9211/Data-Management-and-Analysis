# loading the recordTable
RTable <- read.csv("RTable.csv", stringsAsFactors=FALSE)
##  save(RTable, file = "RTable.Rdata")
## load("RTable.Rdata")
head(RTable)

## Getting the required numbers for subsetting
sites <- unique(RTable$Station) # total number of sites for the camera traps
sps <- unique(RTable$Species)	# total number of unique species caught in the camera trap
nul <- RTable[0,]  # deleting all the rows of the RTable but retaining the columns

########## Going for the order of the RTable ##########
for(i in 1:length(sites)){
sub <- subset(RTable,  RTable$Station== sites[i]) # getting the subset of a single stations first
species <- unique(sub$Species)
for(j in 1:length(species)){ # getting the subset of species in that single station
sub.sps <- subset(sub, sub$Species == species[j]) # getting all the species detection from that station
sub.sps$DateTimeOriginal <- as.POSIXct(sub.sps$DateTimeOriginal,
							tz ="Asia/Katmandu")  
# converting the datetime time with correct timezone
sub.sps <- sub.sps[do.call(order,sub.sps),]  #ordering the datetime with order of the time
nul <- rbind(nul, sub.sps)
}
}

## making sure that the order worked
View(nul)
str(nul)

## now we are moving to get the independent images. Generating TRUE in the Independence columns
RT <- RTable[0,] 
RT <- cbind(RT, RT$Independence)
for(i in 1:length(sites)){
sub <- subset(nul,  nul$Station == sites[i])
species <- unique(sub$Species)
for(j in 1:length(species)){
sub.sps <- subset(sub, sub$Species == species[j])
for(k in 1:length(sub.sps$Species)){
sub.sps$delta.time.mins[k] <- difftime(sub.sps$DateTimeOriginal[k], sub.sps$DateTimeOriginal[1],  units = "mins")
sub.sps$delta.time.secs[k] <- difftime(sub.sps$DateTimeOriginal[k], sub.sps$DateTimeOriginal[1],  units = "secs")
sub.sps$delta.time.hours[k] <- difftime(sub.sps$DateTimeOriginal[k], sub.sps$DateTimeOriginal[1],  units = "hours")
sub.sps$delta.time.days[k] <- difftime(sub.sps$DateTimeOriginal[k], sub.sps$DateTimeOriginal[1],  units = "days")
if (k > 1) {
	ind <- sub.sps$delta.time.mins[k] -  ind_pic
} else {
	ind <- 61
	ind_pic <- sub.sps$delta.time.mins[1]
 	sub.sps$Independence[1] <- TRUE
}
if(ind > 60){
 	ind_pic <- sub.sps$delta.time.mins[k]
	sub.sps$Independence[k] <- TRUE
} 
}
RT <- rbind(RT, sub.sps)
}
}
View(RT)

#getting rid of all the non-independent images
clean <- RT[!is.na(RT$Independence), ]
View(clean)

# Saving the file as .csv
write.csv(clean, "clean.csv")
save(clean, file = "clean.Rdata")
