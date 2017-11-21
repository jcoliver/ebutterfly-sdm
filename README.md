# README for species distribution modeling

## Overview
Code and sample data for running species distribution models from data 
harvested from [iNaturalist](http://www.inaturalist.org). Future implementations 
would also use data from the [eButterfly](http://www.e-butterfly.org) project.

## Dependancies
Seven additional R packages are required:

+ rgdal
+ raster
+ sp
+ dismo
+ maptools
+ gtools
+ SSDM

## Structure
+ data
  + inaturalist: data harvested from [iNaturalist](http://www.inaturalist.org)
    + 50931-iNaturalist.txt: Gray Hairstreak, _Strymon melinus_
    + 509627-iNaturalist.txt: Western Giant Swallowtail, _Papilio rumiko_
    + 59125-iNaturalist.txt: Great Copper, _Lycaena xanthoides_
  + wc2-5: climate data at 2.5 minute resolution from [WorldClim](http://www.worldclim.org)
  + gbif: data harvested from GBIF for iNaturalist taxon_id values; most files
  _not_ under version control (> 2GB each);
    + taxon-ids.txt: tab-delimited text files of unique species-level taxon_id
    values for records from Canada, Mexico, and United States; incluedes two
    columns: `taxonID` and `scientificName`
+ output (not included in repository, but this structure is assumed on local)
  + images
  + rasters
+ scripts
  + ensemble-sdm-iNat-xanthoides.R: Development script for ensemble SDMs
  + gbif-butterflies.sh: First pass of processing GBIF data dump to get taxon_ids
  for iNaturalist data; see also get-taxon-id-from-gbif.py
  + get-observation-data.R: Harvest data from iNaturalist using their API; 
  called from command line terminal
    + Usage: `Rscript --vanilla get-observation-data.R <taxon_id>`
    + Example: `Rscript --vanilla get-observation-data.R 60606`
  + get-taxon-id-from-gbif.py: Extract relevant taxon_id values from GBIF data 
  dump; see also gbif-butterflies.sh. Produces data/gbif/taxon-ids.txt
  + run-sdm.R: Run species distribution model and create map and raster output; 
  called from command line terminal
    + Usage: `Rscript --vanilla run-sdm.R <path/to/data/file> <output-file-prefix> <path/to/output/directory/> <number of background replicates>[optional] <threshold for occurrance>[optional]`
    + Example: `Rscript --vanilla run-sdm.R data/inaturalist/60606-iNaturalist.csv 60606 output/ 50 0.5`
  + run-sdm-algo.R: Run species distribution model, choosing among three algorithms (CTA, RF, or GLM)
  and create map and raster output; called from command line terminal
    + Usage: `Rscript --vanilla run-sdm-algo.R <path/to/data/file> <output-file-prefix> <path/to/output/directory/> <algorithm string: CTA, GLM, or RF>[optional] <number of background replicates>[optional] <threshold for occurrance>[optional]`
    + Example: `Rscript --vanilla run-sdm-algo.R data/inaturalist/60606-iNaturalist.csv 60606 output/ CTA 10 0.7`
  + sdm-for-ACIC-lecture.R: Script to create map graphic used in ACIC lecture
  + sdm-iNat-melinus.R: Pilot species distribution modeling for _Strymon melinus_
  + sdm-iNat-xanthoides.R: Pilot species distribution modeling for _Lycaena xanthoides_
  + stack-sdms.R: Stack multiple SDMs from multiple species into species richness map
    + Usage: `Usage: Rscript --vanilla stack-sdms.R <path/to/raster/files> <output-file-prefix> <path/to/output/directory/>`
    + Example: `Usage: Rscript --vanilla stack-sdms.R output richness output/`

## General initial approach:

1. Retrieve historical climate data [http://www.worldclim.org](http://www.worldclim.org)
2. Get a list of all species in databases (eButterfly & iNaturalist)
3. Get lat/long data for one species from databases
4. Extract data for one month
5. Perform quality check (minimum # observations, appropriate latitude & longitude format)
6. Run SDM
7. Create graphic with standardized name for use on [eButterfly](http://www.e-butterfly.org)

Repeat steps 4-7 for remaining months  
Repeat steps 3-7 for remaining species

### Species Identifiers
**Challenge**: To perform analyses on all North American species of butterflies, 
we will need the taxon_id for all species we are interested in. There is not an 
easy way to do this using the iNaturalist API (see the [discussion](#inaturalist)
in the Resources section below). However, we can download an iNaturalist database 
dump from GBIF at [https://www.google.com/url?q=https%3A%2F%2Fwww.gbif.org%2Fdataset%2F50c9509d-22c7-4a22-a47d-8c48425ef4a7&sa=D&sntz=1&usg=AFQjCNEzY1KC-xcJO1vgk6fhrSW-1_FoCA](https://www.google.com/url?q=https%3A%2F%2Fwww.gbif.org%2Fdataset%2F50c9509d-22c7-4a22-a47d-8c48425ef4a7&sa=D&sntz=1&usg=AFQjCNEzY1KC-xcJO1vgk6fhrSW-1_FoCA).
The flat csv file does not contain enough information; namely it lack the taxon_id
field. However, the Darwin Core archive _does_ include files with the necessary 
information. The files occurrence.txt and verbatim.txt have the fields we need; the 
latter is a smaller file, so we'll use that one (the column headers appear identical
in both files, but some curation was performed to produce the occurrence.txt file).
Among other fields, the ones we will be interested in are:

+ countryCode: We want US, CA, and MX records only
+ taxonID: This field has values to use in the taxon_id field in the iNaturalist API
+ scientificName: The name of the organism

**Update**: the file data/gbif/taxon-ids.txt has the taxonID and scientificName 
field values. However, the data are for observations of _species_ rank; that is, 
subspecies taxon IDs were not recorded. Will need to see if the API will return 
observations for a species-level taxon ID if an identification has been made at 
the subspecies level.

## Resources
### Species distribution models in R
+ [Vignette for `dismo` package](https://cran.r-project.org/web/packages/dismo/vignettes/sdm.pdf)
+ [Fast and flexible Bayesian species distribution modelling using Gaussian processes](http://onlinelibrary.wiley.com/doi/10.1111/2041-210X.12523/pdf)
+ [Species distribution models in R](http://www.molecularecologist.com/2013/04/species-distribution-models-in-r/)
+ [Run a range of species distribution models](https://rdrr.io/cran/biomod2/man/BIOMOD_Modeling.html)
+ [SDM polygons on a Google map](https://rdrr.io/rforge/dismo/man/gmap.html)
+ [R package 'maxnet' for functionality of Java maxent package](https://cran.r-project.org/web/packages/maxnet/maxnet.pdf)

### Tests of spatial overlap
+ [http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0056568](http://journals.plos.org/plosone/article?id=10.1371/journal.pone.0056568)
+ [http://onlinelibrary.wiley.com/doi/10.1111/geb.12455/pdf](http://onlinelibrary.wiley.com/doi/10.1111/geb.12455/pdf)

### iNaturalist
+ [API documentation](https://www.inaturalist.org/pages/api+reference)
+ Google groups [discussion](https://groups.google.com/d/topic/inaturalist/gDpfMWXNxvE/discussion) about taxon_id