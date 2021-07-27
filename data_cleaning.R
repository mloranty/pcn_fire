####################################
# script to clean thaw depth data
# submitted to PCN Fire synthesis
# led by M. Loranty & A. Talucci
#
# MML 07/27/21
####################################

### organize work space----
# clear environment
rm(list=ls())

# load packages

# set working directory
setwd("G:/My Drive/Documents/research/PCN/fire/pcn_fire_synthesis/")


### read and preprocess data----

# vector of data files
f <- list.files(path = "pcn_fire_synthesis_data/csv/",
                pattern = ".csv", full.names = TRUE)


#### CLEAN UP INDIVIDUAL FILES ####

## Baillargeon
f1 <- read.csv(f[1], header = TRUE) 

# change organic depth range to numeric
f1$organic_depth <- 25

# get rid of non-numeric thaw probe measurements
f1$thaw_depth <- as.numeric(sub("100+", "100", f1$thaw_depth, fixed = TRUE))

# get rid of non-numeric fire year entries
f1$fire_year <- as.numeric(sub("unburned", NA, f1$fire_year, fixed = TRUE))

# fix slope, which was read as logical
f1$slope <- read.csv(f[1], header = TRUE, colClasses = "character")[,20]


## Breen 
f2 <- read.csv(f[2], header = TRUE)

# fix thaw/active column, which was read as logical
f2$thaw_active <- read.csv(f[2], header = TRUE, colClasses = "character")[,24]

## Buma
# read without 17th column, which is redundant to the gt_prob column
f3 <- read.csv(f[3], header = TRUE)[,-17]

# fix thaw/active column, which was read as logical
f3$thaw_active <- read.csv(f[3], header = TRUE, colClasses = "character")[,20]

## Dielman
f4 <- read.csv(f[4], header = TRUE)

# fix incorrect logical columns
f4[,c(11,18,20,21)] <- read.csv(f[4], header = TRUE, colClasses = "character")[,c(11,18,20,21)]


## Douglas
f5 <- read.csv(f[5], header = TRUE, na.strings = "N/A")[,-23]

f5$slope <- read.csv(f[5], header = TRUE, colClasses = "character")[,20]

## Frost -- 
f6 <- read.csv(f[6], header = TRUE, na.strings = "-999")
