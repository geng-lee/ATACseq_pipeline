#!/bin/bash

#$ -N intrSamp
#$ -P jknight.prjc -q short.qc
#$ -o stdout_intrsctSamps -e sterr_intrsctSamps.log -j y
#$ -cwd -V

### Find Overlapping Peaks Between Two Consensus BED Files
## JHendry, 2016/12/20
##
## Idea is to two consensus BED files, generated by run_intrsctNPFs.sh, and
## find the intersection of the consensus peaks. A new file is generated
## named by concatenating both file names and deposited in the ./comparisons folder.
##
## Run:
##  qsub run_intrSamps.sh <dir-with-bed-file-1> <dir-with-bed-file-2> <intrsct/median/union>
##    Note that the third command line argument specifies whether to use
##    intersect, median, or union consensus peaks files when looking
##    for overlap between two samples.
## Output includes:
##  - <file-1-name>-<file-2-name>.<intrsct/median/union>.intrsct

echo "**********************************************************************"
echo "Run on host: "`hostname`
echo "Operating system: "`uname -s`
echo "Username: "`whoami`
echo "Started at: "`date`
echo "**********************************************************************"

### Define directory of two samples and consensus type
samp1Dir=$1
samp2Dir=$2
intrsctType=$3

### Construct names of sample .bed files
samp1=$(echo $samp1Dir"/"$samp1Dir"."$intrsctType".bed")
samp2=$(echo $samp2Dir"/"$samp2Dir"."$intrsctType".bed")

echo "Sample 1:" $samp1Dir
echo "Sample 2:" $samp2Dir
echo "Intersection Type:" $intrsctType
echo ""
echo "Peaks in Sample 1":`cat $samp1 | wc -l`
echo "Peaks in Sample 2":`cat $samp2 | wc -l`

### Intersect consensus .bed files of the two samples
bedtools intersect \
-a $samp1 \
-b $samp2 \
> samp1-samp2.temp.intrsct

echo "Intersections between Sample 1 & 2":`cat samp1-samp2.temp.intrsct | wc -l`

bedtools intersect -wb \
-a samp1-samp2.temp.intrsct \
-b $samp1 $samp2 \
-names samp1 samp2 \
> samp-all.temp.intrsct

### Retrieve original consensus peaks causing overlaps
cat samp-all.temp.intrsct | awk '$4 == "samp1"' | awk '{print $4 "\t" $5 "\t" $6 "\t" $7}' > samp1-all.temp.intrsct
cat samp-all.temp.intrsct | awk '$4 == "samp2"' | awk '{print $4 "\t" $5 "\t" $6 "\t" $7}' > samp2-all.temp.intrsct

echo "Sample 1 Peaks in Intersections":`cat samp1-all.temp.intrsct | wc -l`
echo "Sample 2 Peaks in Intersections":`cat samp2-all.temp.intrsct | wc -l`

### Write out to ./comparisons folder
paste samp1-samp2.temp.intrsct samp1-all.temp.intrsct samp2-all.temp.intrsct \
 > `echo "comparisons/"$samp1Dir"-"$samp2Dir"."$intrsctType".intrsct"`

### Remove temporary files
rm *.temp.*

echo "**********************************************************************"
echo "Finished at: "`date`
echo "**********************************************************************"
echo ""
echo ""

