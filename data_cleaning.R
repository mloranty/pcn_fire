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
                pattern = ".csv", full.names = TRUE)[-14]

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
## Buma
# read without 17th column, which is redundant to the gt_prob column
f3 <- read.csv(f[3], header = TRUE)[,-17]

# fix thaw/active column, which was read as logical
f3$thaw_active <- read.csv(f[3], header = TRUE, colClasses = "character")[,20]

# fix site_id for aggregating (see Note below from Buma)
f3$site_id <- paste(f3$site_id, sapply(strsplit(f3$plot,"_"),"[[",2), sep="_" )

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
## Veraverbeke
f14 <- read.csv(f[14], header = TRUE)

# fix incorrect logical columns
f14$thaw_active <- read.csv(f[14], header = TRUE, colClasses = "character")[,19]

f14 %>% distinct(plot_id,year,month,day,fire_id,burn_unburn)

#### concatenate and clean up all of the raw data -----
all.td <- rbind(f1,f3,f4,f5,f6,f7[,-23],f8[,-23],f9, f10, f11, f12[,-23], f13[,-23],f14)

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
all.td$tsf[which(all.td$burn_unburn=="unburned")] <- 200


all.td$thaw_active[which(all.td$thaw_active=="TRUE")] <- "T"
########### Files submitted pre-aggregated to the site level ----
## Breen 
f2 <- read.csv(f[2], header = TRUE)

# fix thaw/active column, which was read as logical
f2$thaw_active <- read.csv(f[2], header = TRUE, colClasses = "character")[,24]


### AGU Analyses ----
#------------------------------------------------------------------------------------------#
# remove all rows without coords
all.td2 <- all.td[-which(is.na(all.td$long)),]

aggregate(cbind(thaw_depth,tsf)~boreal_tundra+burn_unburn, all.td, FUN = mean)
aggregate(cbind(thaw_depth,tsf)~boreal_tundra+burn_unburn+thaw_active, all.td, FUN = mean)

site.td <- aggregate(cbind(thaw_depth,tsf)~last_name+site_id+year+month+burn_unburn+,all.td, FUN=mean)






t.sf <- st_as_sf(x = all.td2, coords = c("long", "lat"), crs = 4326)
                
ggplot() +
  geom_map(
    data = world, map = world,
    aes(long, lat, map_id = region),
    color = "black", fill = "lightgray", size = 0.1
  ) +
  geom_sf(data = t.sf, col = "red")


