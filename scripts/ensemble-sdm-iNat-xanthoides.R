# Example of stacked SDM on S. melinus
# Jeffrey C. Oliver
# jcoliver@email.arizona.edu
# 2017-11-17

rm(list = ls())

################################################################################
# install.packages("gtools", "SSDM")
library("SSDM")
library("dismo")

################################################################################
# FIRST RUN MODELED FROM VIGNETTESS
# See https://cran.r-project.org/web/packages/SSDM/vignettes/SSDM.html
# Get environmental data (predictors)
# This step is pretty memory (RAM) intensive, perhaps because it loads in all 
# data. 
env.var <- load_var(path = "data/wc2-5",
                    format = ".bil")

# Get observation data
orig.data <- read.csv(file = "data/inaturalist/59125-iNaturalist.csv")
obs.data <- orig.data[, c("scientific_name", "longitude", "latitude")]
colnames(obs.data) <- c("SPECIES", "LONGITUDE", "LATITUDE")

# Runs modeling on ALL data in the env.var, need to crop
esdm <- ensemble_modelling(algorithms = c("CTA", "MARS"),
                           Occurrences = obs.data,
                           Env = env.var,
                           rep = 1,
                           Xcol = "LONGITUDE",
                           Ycol = "LATITUDE",
                           ensemble.thresh = c(0.6),
                           verbose = TRUE)

# pdf(file = "~/Desktop/esdm.pdf")
plot(esdm@projection, main = "L. xanthoides CTA & MARS")
# dev.off()

################################################################################
# SECOND RUN, RESTRICTED GEOGRAPHICALLY MODELED FROM VIGNETTE
source(file = "functions/SDMRaster.R")

# Read in the data, pull out only those columns we need
orig.data <- read.csv(file = "data/inaturalist/59125-iNaturalist.csv")
obs.data <- orig.data[, c("scientific_name", "longitude", "latitude")]

min.max <- MinMaxCoordinates(x = obs.data)
geographic.extent <- extent(x = min.max)

geographic.extent <- extent(c(-165, -52, 15, 75)) # North America

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- stack(crop(x = bioclim.data, y = geographic.extent))


# x Long: -165 to -52
# y Lat: 15 to 75

# Runs modeling
esdm <- ensemble_modelling(algorithms = c("CTA"),
                           Occurrences = obs.data,
                           Env = bioclim.data,
                           rep = 1,
                           Xcol = "longitude",
                           Ycol = "latitude",
                           ensemble.thresh = c(0.6),
                           verbose = TRUE)
plot(esdm@projection, main = "L. xanthoides CTA")

################################################################################
# THIRD RUN, 3 MODELS
source(file = "functions/SDMRaster.R")

# Read in the data, pull out only those columns we need
orig.data <- read.csv(file = "data/inaturalist/59125-iNaturalist.csv")
obs.data <- orig.data[, c("scientific_name", "longitude", "latitude")]

min.max <- MinMaxCoordinates(x = obs.data)
geographic.extent <- extent(x = min.max)

geographic.extent <- extent(c(-165, -52, 15, 75)) # North America

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- stack(crop(x = bioclim.data, y = geographic.extent))

# Runs modeling
esdm <- ensemble_modelling(algorithms = c("CTA", "GLM", "RF"),
                           Occurrences = obs.data,
                           Env = bioclim.data,
                           rep = 1,
                           Xcol = "longitude",
                           Ycol = "latitude",
                           ensemble.thresh = c(0.6),
                           verbose = TRUE)
plot(esdm@projection, main = "L. xanthoides CTA, GLM, & RF")

################################################################################
# FOURTH RUN, Single model (RF)
source(file = "functions/SDMRaster.R")

# Read in the data, pull out only those columns we need
orig.data <- read.csv(file = "data/inaturalist/59125-iNaturalist.csv")
obs.data <- orig.data[, c("scientific_name", "longitude", "latitude")]

min.max <- MinMaxCoordinates(x = obs.data)
geographic.extent <- extent(x = min.max)

geographic.extent <- extent(c(-165, -52, 15, 75)) # North America

# Get the biolim data
bioclim.data <- getData(name = "worldclim",
                        var = "bio",
                        res = 2.5, # Could try for better resolution, 0.5, but would then need to provide lat & long...
                        path = "data/")
bioclim.data <- stack(crop(x = bioclim.data, y = geographic.extent))

# Runs modeling
sdm.1 <- modelling(algorithm = "RF", 
                 Occurrences = obs.data, 
                 Env = bioclim.data,
                 Xcol = "longitude",
                 Ycol = "latitude")
sdm.2 <- modelling(algorithm = "RF", 
                   Occurrences = obs.data, 
                   Env = bioclim.data,
                   Xcol = "longitude",
                   Ycol = "latitude")


plot(sdm@binary, main = "SDM RF L. xanthoides")
