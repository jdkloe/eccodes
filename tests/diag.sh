#!/bin/sh
# Copyright 2005-2019 ECMWF.
#
# This software is licensed under the terms of the Apache Licence Version 2.0
# which can be obtained at http://www.apache.org/licenses/LICENSE-2.0.
# 
# In applying this licence, ECMWF does not waive the privileges and immunities granted to it by
# virtue of its status as an intergovernmental organisation nor does it submit to any jurisdiction.
#

# Tests for Pseudo-GRIB format "DIAG"

. ./include.sh
label="pseudo-diag-test"
tempOut=temp.${label}.out
tempTxt=temp.${label}.txt
tempRef=temp.${label}.ref

REDIRECT=/dev/null

sample=$ECCODES_SAMPLES_PATH/diag.tmpl

# Basic grib commands should not fail
# ------------------------------------
${tools_dir}/grib_ls $sample > $REDIRECT
${tools_dir}/grib_dump $sample > $REDIRECT

# Check setting keys
# -------------------
echo 'set numberOfIntegers=3; set integerValues={55, 44, 66}; write;' | ${tools_dir}/grib_filter -o $tempOut - $sample
${tools_dir}/grib_dump -p numberOfFloats,numberOfIntegers,floatValues,integerValues $tempOut | sed 1d > $tempTxt
cat > $tempRef <<EOF
  numberOfFloats = 2;
  numberOfIntegers = 3;
  floatValues(2) =  {
  3.32, 1.21
  } 
  integerValues(3) =  {
  55, 44, 66
  } 
EOF
diff $tempRef $tempTxt


echo 'set numberOfFloats=3; set floatValues={8.8, 9.9, 10.10}; write;' | ${tools_dir}/grib_filter -o $tempOut - $sample
${tools_dir}/grib_dump -p numberOfFloats,numberOfIntegers,floatValues,integerValues $tempOut | sed 1d > $tempTxt
cat > $tempRef <<EOF
  numberOfFloats = 3;
  numberOfIntegers = 1;
  floatValues(3) =  {
  8.8, 9.9, 10.1
  } 
  integerValues = 66;
EOF
diff $tempRef $tempTxt


echo 'set numberOfIntegers=4; set integerValues={33, 55, -44, 66}; set numberOfFloats=3; set floatValues={-8.8, 9.9, 10.10}; write;' | ${tools_dir}/grib_filter -o $tempOut - $sample
${tools_dir}/grib_dump -p numberOfFloats,numberOfIntegers,floatValues,integerValues $tempOut | sed 1d > $tempTxt
cat > $tempRef <<EOF
  numberOfFloats = 3;
  numberOfIntegers = 4;
  floatValues(3) =  {
  -8.8, 9.9, 10.1
  } 
  integerValues(4) =  {
  33, 55, -44, 66
  } 
EOF
diff $tempRef $tempTxt


# Clean up
rm -f $tempOut $tempRef
