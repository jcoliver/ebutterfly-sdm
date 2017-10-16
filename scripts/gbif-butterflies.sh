#!/bin/bash

# Extract butterfly records from GBIF Darwin Core Archive verbatim.txt file from:
# https://www.google.com/url?q=https%3A%2F%2Fwww.gbif.org%2Fdataset%2F50c9509d-22c7-4a22-a47d-8c48425ef4a7&sa=D&sntz=1&usg=AFQjCNEzY1KC-xcJO1vgk6fhrSW-1_FoCA
# The verbatim.txt file is tab-delimited text of some 2e6 records from
# iNaturalist. This script is pulling out a subset of the records (those
# with lines matching one of the butterfly family names) for subsequent
# processing to extract taxon_id values

INFILE="../data/gbif/verbatim.txt"
TMP="verbatim-temp.txt"
OUTFILE="../data/gbif/verbatim-butterflies.txt"

# Get header row for our output file
head -n1 $INFILE > $TMP

# Iterate over all families and copy those lines to output file
FAMILIES=("Hesperiidae" "Papilionidae" "Pieridae" "Nymphalidae" "Lycaenidae" "Riodinidae")
for FAMILY in "${FAMILIES[@]}";
do
  echo "Processing $FAMILY"
  # grep $FAMILY $INFILE | wc -l
  grep $FAMILY $INFILE >> $TMP
done

# Fix one broken line; one record has an unmatched double quotation mark:
# "2014-04-10 10:30:00
sed 's/\"2014-04-10 10:30:00/\"2014-04-10 10:30:00\"/g' $TMP > $OUTFILE
rm $TMP