#!/bin/bash
#
# Rose Caller to detect both Enhancers and Super-Enhancers
#
# Version 1 11/16/2019
# Version 1.2 

##############################################################
# ##### Please replace PATHTO with your own directory ###### #
##############################################################
PATHTO=/projects/academic/mjbuck/Collaborators/Sinha_Core_File_Deposit/Akinsola/Software/ROSE
PYTHONPATH=$PATHTO/lib
export PYTHONPATH
export PATH=$PATH:$PATHTO/bin

if [ $# -lt 5 ]; then
  echo ""
  echo 1>&2 Usage: $0 ["narrowPeak/GFF_file"] ["INPUT BAM file"] ["TEST BAM file"] ["OutputDir"] ["species"]
  echo ""
  exit 1
fi

#================================================================================
#Parameters for running


# GTF files
GFF_FILE=$1

# Input BAM file
INPUT_BAMFILE=$2

# Test BAM file
TEST_BAMFILE=$3

# Output Directory
OUTPUTDIR=$4
OUTPUTDIR=${OUTPUTDIR:=ROSE_out}

# Species
SPECIES=$5



# Transcription Start Size Window
TSS=${TSS:=2000}

# Maximum linking distance for stitching
STITCH=${STITCH:=12500}


#Permanent fix to age-long narrowPeak to GFF scare!

if [ $(echo $GFF_FILE | cut -d "." -f 2) = "narrowPeak" ]; then
  awk '{OFS="\t"; print $1, $4, "", $2, $3, "",".","", $4}' $GFF_FILE > ${GFF_FILE%narrowPeak}gff
  GFF_FILE=${GFF_FILE%narrowPeak}gff

else
  GFF_FILE=$GFF_FILE
 
fi

echo "Loading Python 2 ..."
module load python/anaconda
echo "done"

echo "starting ROSE Algorithm"


echo "#############################################"
echo "######             ROSE v1             ######"
echo "#############################################"

echo "Input file: $INPUT_BAMFILE"
echo "Test file: $TEST_BAMFILE"
echo "Output directory: $OUTPUTDIR"
echo "Species: $SPECIES"
echo "Max. Stitch Distance: ${STITCH}kb"
echo "TSS buffer: ${TSS}kb"
echo "GFF file: $GFF_FILE"
#===============================================================================




# Generating UCSC RefSeq GFF File
#
mkdir -p annotation
rsync $PATHTO/annotations/${SPECIES,,}"_refseq.ucsc" ./annotation/

#
# ROSE CALLER
#
ROSE_main.py -s $STITCH -t $TSS -g $SPECIES -i $GFF_FILE -r $TEST_BAMFILE -c $INPUT_BAMFILE -o $OUTPUTDIR

echo "Done!"
