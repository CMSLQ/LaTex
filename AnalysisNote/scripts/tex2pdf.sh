#! /bin/sh

if [ $# -lt 1 ] 
then
   echo "usage: tex2pdf.sh <filename without .tex>"
   exit -1
fi

FILENAME=${1}

#pdflatex ${FILENAME}.tex

latex ${FILENAME}.tex
dvipdf ${FILENAME}.dvi ${FILENAME}.pdf
