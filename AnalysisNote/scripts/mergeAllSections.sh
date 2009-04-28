#!/bin/sh

OUTFILE=CMS_AN_2008_XXX.tex
TEXFILES="beginning.tex trig.tex elec.tex jet.tex eventSel.tex backgrnd_signal.tex signalExtraction.tex cmsPotential.tex end.tex bib.tex"

echo "Merging files: $TEXFILES"
echo "               into the output file $OUTFILE"

cat > $OUTFILE <<EOF
\documentclass[colclass=cmspaper]{combine}
\usepackage{lineno}
\begin{document}
\begin{linenumbers}
\pagestyle{combine}
EOF

cat $TEXFILES >> $OUTFILE

cat >> $OUTFILE <<EOF
\end{linenumbers}
\end{document}
EOF

