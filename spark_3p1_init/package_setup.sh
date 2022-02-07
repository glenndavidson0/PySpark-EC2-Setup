#!/bin/sh
# Written by Glenn Davidson, Dec 2021
# glenntdavidson@gmail.com, glenndavidson@cmail.carleton.ca
# Script to package the current setup and place it in the scripts folder,
#                                     ready for transfer to new instances

OUTPUT_DIR="../scripts/data"

# compress entire folder's contents
tar -cf spark_3p1_init.tar.xz *

# make output directory if it does not exist
if [ ! -d "$OUTPUT_DIR" ]; then
    mkdir $OUTPUT_DIR
fi

# copy setup folder to output directory
mv spark_3p1_init.tar.xz $OUTPUT_DIR