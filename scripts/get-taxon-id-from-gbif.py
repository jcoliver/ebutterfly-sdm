# Extract iNaturalist taxon ids from GBIF records
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-10-16

# Input file is a a preprocessed version of the verbatim.txt file from a Darwin
# Core Archive from GBIF. See ../scripts/gbif-butterflies.sh.

# Note a significant discrepancy exists between the number of lines in the
# input file (184180) and the number of rows in the dataframe (183770).

# Will ultimately want unique taxonID and scientificName fields for butterflies
# from Canada, Mexico, and USA

import io
import os
import pandas as pd

def read_file(filename, delimiter = "\t"):
    if os.path.exists(infile):
        # Skipping troublesome lines; should not be a huge issue...one one
        #  malformed line of a Danaus plexippus record
        file_data = pd.read_csv(infile, sep = delimiter, error_bad_lines=False)
        return(file_data)
    else:
        return(None)
# end read_file

def families():
    family_list = ["Hesperiidae",
    "Papilionidae",
    "Pieridae",
    "Nymphalidae",
    "Lycaenidae",
    "Riodinidae"]
    return(family_list)
# end families

def countries():
    country_list = ["CA", "MX", "US"]
    return(country_list)
# end countries


infile = "../data/gbif/verbatim-butterflies.txt"
outfile = "../data/gbif/taxon-ids.txt"

# Read the file in; report size
butterflies_df = read_file(infile)
print("Read in: " + str(len(butterflies_df)) + " records")

# Select only those records that are actually in buttefly families; report size
butterflies_df = butterflies_df[butterflies_df['family'].isin(families())]
print("Keeping " + str(len(butterflies_df)) + " butterfly family records")

# Select only those records that are in countries of interest; report size
butterflies_df = butterflies_df[butterflies_df['countryCode'].isin(countries())]
print("Keeping " + str(len(butterflies_df)) + " records from North America")

# Keep only those records of species rank; report size
butterflies_df = butterflies_df[butterflies_df['taxonRank'] == "species"]
print("Keeping " + str(len(butterflies_df)) + " species rank records")

# Keep only unique taxonID records; report size
butterflies_df = butterflies_df.drop_duplicates('taxonID')
print("Keeping " + str(len(butterflies_df)) + " unique taxonID records")

export_df = butterflies_df[['taxonID', 'scientificName']]
export_df.to_csv(path_or_buf = outfile, sep = "\t", index = False, encoding = "utf-8")
