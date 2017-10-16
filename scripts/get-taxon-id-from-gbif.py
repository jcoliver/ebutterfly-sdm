
# Extract iNaturalist taxon ids from GBIF records
# Jeff Oliver
# jcoliver@email.arizona.edu
# 2017-10-16

# Input file is a a preprocessed version of the verbatim.txt file from a Darwin
# Core Archive from GBIF. See ../scripts/gbif-butterflies.sh.

# Note a significant discrepancy exists between the number of lines in the
# input file (184180) and the number of rows in the dataframe (183770).

import io
import os
import pandas as pd

infile = "../data/gbif/verbatim-butterflies.txt"

def read_file(filename, delimiter = "\t"):
    if os.path.exists(infile):
        # Skipping troublesome lines; should not be a huge issue...one one
        #  malformed line of a Danaus plexippus record
        file_data = pd.read_csv(infile, sep = delimiter, error_bad_lines=False)
        return(file_data)
    else:
        return(None)

butterflies_df = read_file(infile)

print(len(butterflies_df))
