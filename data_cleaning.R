####################################
# script to clean thaw depth data
# submitted to PCN Fire synthesis
# led by M. Loranty & A. Talucci
#
# MML 07/27/21
####################################

### organize work space----
#load packages
library(sf)
library(ggplot2)
library(dplyr)
library(tidyverse)
library(maps)
library(mapdata)
library(tmap)
library(tmaptools)

# clear environment
rm(list=ls())


# set working directory specific to computer
pc <- "G:/My Drive/Documents/research/PCN/fire/pcn_fire_synthesis/"
mac <- "/Volumes/GoogleDrive/My Drive/Documents/research/PCN/fire/pcn_fire_synthesis/"

ifelse(Sys.info()['sysname']=="Darwin",
       setwd(mac),setwd(pc)) 

rm(mac,pc)


# vector of data files
f <- list.files(path = "pcn_fire_synthesis_data/csv/",
                pattern = ".csv", full.names = TRUE)

## define functions

# get the mode of a vector (works for character)
getmode <- function(x){
  uv <- unique(x)
  uv[which.max(tabulate(match(x, uv)))]
}

# calculate standard error of the mean
se <- function(x){
  sd(x, na.rm = T)/sqrt(length(na.omit(x)))
}

#### CLEAN UP AND CONCATENATE INDIVIDUAL FILES ----
##############
## Baillargeon
f1 <- read.csv(f[1], header = TRUE) 

# change organic depth range to numeric
f1$organic_depth <- 25

# indicate measurements that exceed probe length
f1$gt_probe[which(f1$thaw_depth == "100+")] <- "y"

# get rid of non-numeric thaw probe measurements
f1$thaw_depth <- as.numeric(sub("100+", "100", f1$thaw_depth, fixed = TRUE))

# get rid of non-numeric fire year entries
f1$fire_year <- as.numeric(sub("unburned", NA, f1$fire_year, fixed = TRUE))

# fix slope, which was read as logical
f1$slope <- read.csv(f[1], header = TRUE, colClasses = "character")[,20]

# fix thaw_active - these are TD measurements, not ALD
f1$thaw_active <- "T"

# examine unique combinations of identify information for aggregatation
f1 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

f1a <- f1 %>% group_by(site_id,fire_id,burn_unburn,year) %>%
              summarise(td = mean(thaw_depth, na.rm = T),se = se(thaw_depth), 
                        fire_year = mean(fire_year),
                        lat = mean(lat), long = mean(long),
                        biome = getmode(boreal_tundra),veg = getmode(veg_cover_class), 
                        thaw_active = getmode(thaw_active))

pivot_wider(f1a,
            names_from = c(burn_unburn),
            values_from = c(td,se))


##############
## Breen
#f2 <- read.csv(f[2], header = TRUE)

##############
## Buma
# read without 17th column, which is redundant to the gt_prob column
f3 <- read.csv(f[3], header = TRUE)[,-17]

# fix thaw/active column, which was read as logical
f3$thaw_active <- read.csv(f[3], header = TRUE, colClasses = "character")[,20]

# fix site_id for aggregating (see Note below from Buma)
f3$site_id <- paste(f3$site_id, sapply(strsplit(f3$plot,"_"),"[[",2), sep="_" )

# fix positive longitude values, which are in the wrong hemisphere
f3$long <- ifelse(f3$long > 0, -f3$long,f3$long)

# The Dalton and the Steese are larger "sites," each of which has a lot of plots in them.  But those plots do vary, so don't aggregate.  At the Dalton, there are sites with 0 (unburned), 1 (one fire, which would be 2004/2005 era), 2 fires (which would be 1970's era AND 2004 or 2005), or 3 fires (which would be 1950's, 1970's, and 2004 or 2005.  So if aggregating, what you'd want to do would be to aggregate by those treatments (0, 1, 2, or 3 fires) within the Dalton or Steese "sites."  So, sounds like you'd want to aggregate all the unburned plots at the Dalton, all the 1 burn plots at the Dalton, etc.  I would not aggregate Dalton and Steese plots together, they are functionally different sites (uplands vs. low lands, respectively).

f3 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)
##############
## Dielman
f4 <- read.csv(f[4], header = TRUE)

# fix incorrect logical columns
f4[,c(11,18,20,21)] <- read.csv(f[4], header = TRUE, colClasses = "character")[,c(11,18,20,21)]

f4 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)
## Douglas
f5 <- read.csv(f[5], header = TRUE, na.strings = "N/A")[,-23]

# fix incorrect logical columns
f5$slope <- read.csv(f[5], header = TRUE, colClasses = "character")[,20]

# aggregate by site_id and year
f4 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## Frost -- 
f6 <- read.csv(f[6], header = TRUE, na.strings = "-999")

# fix thaw/active column, which was read as logical
f6$thaw_active <- read.csv(f[6], header = TRUE, colClasses = "character")[,19]

# aggregation unclear

## Galgiotti
f7 <- read.csv(f[7], header = TRUE)

# set gt_probe
f7$gt_probe <- "n"

# organic depth is missing, but set to NA
f7$organic_depth <- as.numeric(f7$organic_depth)

# aggregate by plot_id
f7 %>% distinct(plot_id,year,month,day,fire_id,burn_unburn)

## Manies
f8 <- read.csv(f[8], header = TRUE)

# fix incorrect columns
f8$slope <- read.csv(f[8], header = TRUE, colClasses = "character")[,20]

f8$organic_depth <- read.csv(f[8], header = TRUE, na.strings = "unk")[,15]

# aggregate by site & date
f8 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## Natali
f9 <- read.csv(f[9], header = TRUE)

# organic depth is missing, but set to NA
f9$organic_depth <- as.numeric(f9$organic_depth)

# fix incorrect logical columns
f9[,c(20:22)] <- read.csv(f[9], header = TRUE, colClasses = "character")[,c(20:22)]

# remove characters from thaw depth and convert to numeric
f9$thaw_depth <- gsub("+", "", f9$thaw_depth, fixed = TRUE)
f9$thaw_depth <- as.numeric(gsub(">", "", f9$thaw_depth, fixed = TRUE))

# aggregate by site & month
f9 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## O'Donnell
f10 <- read.csv(f[10], header = TRUE)

# remove non-numeric characters from numeric vars
# note we're loosing info on where Organic Layer Thickness is in excess of the entered value
f10$organic_depth <- as.numeric(gsub(">", "",f10$organic_depth))

f10$thaw_depth <- as.numeric(gsub(">", "",f10$thaw_depth))

f10 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## Gibson/Olefeldt
f11 <- read.csv(f[11], header = TRUE)

# fix incorrect logical columns
f11$slope <- read.csv(f[11], header = TRUE, colClasses = "character")[,20]

# remove non-numeric characters from numeric vars
# note we're loosing info on where Organic Layer Thickness is in excess of the entered value
f11$organic_depth <- as.numeric(gsub(">", "",f11$organic_depth))

f11 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## Paulson
f12 <- read.csv(f[12], header = TRUE)

# fix incorrect logical columns
f12$thaw_active <- read.csv(f[12], header = TRUE, colClasses = "character")[,19]

f12 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

## Rocha
f13 <- read.csv(f[13], header = TRUE)

# fix incorrect logical columns
f13$slope <- read.csv(f[13], header = TRUE, colClasses = "character")[,20]

# organic depth is missing, but set to NA
f13$organic_depth <- as.numeric(f13$organic_depth)

# convert thaw depth to numeric - blank cells have a period, and will be converted to NA
f13$thaw_depth <- as.numeric(f13$thaw_depth)

f13 %>% distinct(site_id,year,month,day,fire_id,burn_unburn)

##Sizov
f14 <- read.csv(f[14], header = TRUE)[,-23]

## Veraverbeke
f15 <- read.csv(f[15], header = TRUE)

# fix incorrect logical columns
f15$thaw_active <- read.csv(f[15], header = TRUE, colClasses = "character")[,19]

f15 %>% distinct(plot_id,year,month,day,fire_id,burn_unburn)

#### concatenate and clean up all of the raw data -----
all.td <- rbind(f1,f3,f4,f5,f6,f7[,-23],f8[,-23],f9, f10, f11, f12[,-23], f13[,-23],f15)

### fix inconsistent spelling/capitalization for burned/unburned
all.td$burn_unburn[grep("unb", all.td$burn_unburn, ignore.case = TRUE)] <- "unburned"
all.td$burn_unburn[grep("unb", all.td$burn_unburn, ignore.case = TRUE, invert = TRUE)] <- "burned"

### fix inconsistent spelling/capitalization for boreal/tundra
all.td$boreal_tundra <- sub("B", "boreal", all.td$boreal_tundra)
all.td$boreal_tundra <- sub("T", "tundra", all.td$boreal_tundra)

# convert day  & long to numeric
all.td$day <- as.numeric(all.td$day)
all.td$long <- as.numeric(all.td$long)

# calculate time since fire
all.td$tsf <- all.td$year-all.td$fire_year

# set time since fire to 200 for unburned 
#all.td$tsf[which(all.td$burn_unburn=="unburned")] <- 200


#all.td$thaw_active[which(all.td$thaw_active=="TRUE")] <- "T"

all.td$thaw_depth[which(all.td$thaw_depth > 500)] <- NA

all.td$thaw_depth[which(all.td$thaw_depth < 0)] <- NA
########### Files submitted pre-aggregated to the site level ----
## Breen 
f2 <- read.csv(f[2], header = TRUE)

# fix thaw/active column, which was read as logical
f2$thaw_active <- read.csv(f[2], header = TRUE, colClasses = "character")[,24]


### AGU Analyses/Figures ----
#------------------------------------------------------------------------------------------#
# remove all rows without coords
all.td2 <- all.td[-which(is.na(all.td$long)),]

# aggregate to site level, and write csv file
site.td <- aggregate(cbind(thaw_depth,tsf,lat,long)~last_name+site_id+country_code+year+month+burn_unburn+boreal_tundra+thaw_active,all.td2, FUN=mean)

write.csv(site.td, file = "aggregated_site_level_data_AGU.csv", col.names = T, row.names = F)

bs.td <- site.td[which(site.td$boreal_tundra=="boreal"),]

aggregate(cbind(thaw_depth,tsf)~boreal_tundra+burn_unburn, all.td2, FUN = mean)
aggregate(cbind(thaw_depth,tsf)~boreal_tundra+burn_unburn+thaw_active, all.td2, FUN = mean)
aggregate(cbind(thaw_depth,tsf)~burn_unburn+country_code, bs.td, FUN = mean)
aggregate(cbind(thaw_depth,tsf)~burn_unburn+country_code+thaw_active, bs.td, FUN = mean)

## boxplot of all data, grouped by biome and burned/unburned
png("biome_thaw_all.png",
    width = 8,
    height = 8, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)
boxplot(-thaw_depth~burn_unburn+boreal_tundra, data = all.td2, range = 1,
        outline = T,
        ylim = c(-200,0), 
        xlab="",ylab = "Permafrost Table Depth (cm)",
        col = rep(c("blue","yellow"), each=2), angle = c(90,0),
        names = c("Boreal burned", "Boreal unburned", "Tundra burned", "Tundra unburned"))
dev.off()

## thaw probe measurements by biome, using aggregated site level data
png("biome_thaw_site.png",
    width = 8,
    height = 8, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)
boxplot(-thaw_depth~burn_unburn+boreal_tundra, data = site.td, range = 1,
        outline = T, notch = T,
        ylim = c(-200,0), 
        xlab="",ylab = "Permafrost Table Depth (cm)",
        col = rep(c("blue","yellow"), each=2), angle = c(90,0),
        names = c("Burned", "Unburned", "Burned", "Unburned"))
dev.off()

## thaw probe measurements by region for boreal only
png("boreal_region.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)
boxplot(-thaw_depth~burn_unburn+country_code, data = bs.td, range = 1,
        outline = T, notch = T,
        ylim = c(-200,0), 
        xlab="",ylab = "Permafrost Table Depth (cm)",
        main = "Boreal Forest by Region",
        col = "blue",
        names = c("CA burned", "CA unburned", "RU burned", "RU unburned", "US burned", "US unburned"))
dev.off()

## plot thaw depth vs. time since fire
png("time_since_fire.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)

plot(site.td$tsf, -site.td$thaw_depth,
     ylim = c(-200,0),
     bg = ifelse(site.td$boreal_tundra =="boreal","blue","yellow"),
     pch = ifelse(site.td$thaw_active == "A",21,24),
     xlab = "Years Since Fire",
     ylab = "Permafrost Table Depth (cm)",
     main = "Post-fire Thaw Depth by Biome")

legend("topright", c("ALT","TD"),
       bty = "n",inset = 0.05,
       pch = c(16,17))

legend(10,-150, c("Boreal", "Tundra"),
       fill = c("Blue","Yellow"),bty = "n")

dev.off()

## plot thaw depth vs. latitude by biome
png("latitudinal_thaw_biome.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)

plot(site.td$lat, -site.td$thaw_depth,
     ylim = c(-200,0),
     bg = ifelse(site.td$boreal_tundra =="boreal","blue","yellow"),
     pch = ifelse(site.td$thaw_active == "A",21,24),
     xlab = "Latitude",
     ylab = "Permafrost Table Depth (cm)",
     main = "Thaw Depth by Latitude and Biome")

legend("bottomright", c("ALT","TD"),
       bty = "n",inset = 0.05,
       pch = c(16,17))

dev.off()

## plot thaw depth vs. latitude by burn
png("latitudinal_thaw_burn.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)

plot(site.td$lat, -site.td$thaw_depth,
     ylim = c(-240,0),
     bg = ifelse(site.td$burn_unburn =="burned","red","black"),
     pch = ifelse(site.td$thaw_active == "A",21,24),
     xlab = "Latitude",
     ylab = "Permafrost Table Depth (cm)",
     main = "Thaw Depth by Latitude and Burn Status")

legend("bottomright", c("ALT","TD"),
       bty = "n",inset = 0.05,
       pch = c(16,17))
legend("bottom", c("Unburned","Burned"),
       fill = c("black","red"),
       ncol = 2,bty = "n")
dev.off()

## plot thaw depth vs. time since fire for boreal

#make a vector of colors
cl <- ifelse(bs.td$country_code=="RU","red",
             ifelse(bs.td$country_code=="US","gray","black"))

png("time_since_fire_boreal.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)

plot(bs.td$tsf, -bs.td$thaw_depth,
     ylim = c(-240,0),
     bg = cl,
     pch = ifelse(bs.td$thaw_active == "A",21,24),
     xlab = "Years Since Fire",
     ylab = "Permafrost Table Depth (cm)",
     main = "Post-fire Thaw Depth by Boreal Region")

legend("topright", c("ALT","TD"),
       bty = "n",inset = 0.05,
       pch = c(16,17))

legend("bottom", c("CA","RU","US"),
       fill = c("black","red","gray"),
       ncol = 3,bty = "n")
dev.off()

## plot thawdepth vs latitude for boreal

# create vector of unburned data
bu <- which(bs.td$burn_unburn == "unburned")

png("latitudinal_thaw_boreal.png",
    width = 8,
    height = 6, 
    units="in", 
    res = 300)
par(las = 1, cex = 1.5)

plot(bs.td$lat[bu], -bs.td$thaw_depth[bu],
     ylim = c(-240,0),
     bg = cl[bu],
     pch = ifelse(bs.td$thaw_active[bu] == "A",21,24),
     xlab = "Latitude",
     ylab = "Permafrost Table Depth (cm)",
     main = "Unburned Thaw Depth by Boreal Region")

legend("bottomright", c("ALT","TD"),
       bty = "n",inset = 0.05,
       pch = c(16,17))

legend("bottom", c("CA","RU","US"),
       fill = c("black","red","gray"),
       ncol = 3,bty = "n")
dev.off()


# make a map of the study sites
t.sf <- st_as_sf(x = all.td2, coords = c("long", "lat"), crs = 4326)

s.sf <- st_as_sf(x = site.td, coords = c("long", "lat"), crs = 4326)

prj <- "+proj=stere +lat_0=90 +lat_ts=70 +lon_0=-45 +k=1 +x_0=0 +y_0=0 +datum=WGS84 +units=m +no_defs "

World.st <- st_transform(World, prj)

tm_shape(World) +
  tm_fill() +
  tm_borders() +
tm_shape(s.sf)   

  tm_dots()


ggplot() +
  geom_map(
    data = world, map = world,
    aes(long, lat, map_id = region),
    color = "black", fill = "lightgray", size = 0.1
  ) +
  geom_sf(data = s.sf, col = "red")


