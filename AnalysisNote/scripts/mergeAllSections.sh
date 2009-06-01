#!/bin/sh

OUTFILE=CMS_AN_2008_070
TEXFILES="beginning.tex monteCarloSamples.tex trig.tex elec.tex jet.tex eventSel.tex backgrnd_signal.tex Systematics.tex cmsPotential.tex end.tex acknow.tex bib.tex"

echo "Merging files: $TEXFILES"
echo "               into the output file $OUTFILE"

cat > ${OUTFILE}.tex <<EOF
\documentclass[colclass=cmspaper]{combine}
\usepackage{lineno}
\usepackage{amsfonts,amsmath,amssymb}
\usepackage[dvips]{graphicx}
\usepackage{bm}
\begin{document}
\begin{linenumbers}
\pagestyle{combine}
EOF

cat $TEXFILES >> ${OUTFILE}.tex

cat >> ${OUTFILE}.tex <<EOF
\end{linenumbers}
\end{document}
EOF

latex ${OUTFILE}.tex
bibtex ${OUTFILE}.aux
latex ${OUTFILE}.tex
latex ${OUTFILE}.tex
dvipdf ${OUTFILE}.dvi ${OUTFILE}.pdf
