#!/bin/bash

raw_data_file=$1
analysis_filename=$2
histogram_filename=$3
selector=$4

# source root & grsisort 
source /software/root/bin/thisroot.sh
source /software/GRSISort/thisgrsi.sh

# run ntuple
echo /software/NTuple2EventTree/NTuple2EventTree -sf /softwares/NTuple2EventTree/Settings.dat -if $raw_data_file

if [[ ! -f analysis00000_000.root ]]; then 
    echo "Analysis file not found, exiting"
    exit 1
fi

# sort data into histograms

# mv analysis00000_000.root $analysis_filename
# grsiproof $analysis_filename $selector --max-workers=1

exit 0
