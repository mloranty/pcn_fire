####################################
# script to analyze thaw depth data
# submitted to PCN Fire synthesis
# led by M. Loranty & A. Talucci
#
# MML 07/22/21
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

# vector of what the columns classes should be
c()
# read first file to set up data frame
d <- read.csv(f[1], header = TRUE)

# read in all data files
for(i in 2:length(f))
{
  x <- read.csv(f[i], header = TRUE)
  d <- merge(d,x)
}

