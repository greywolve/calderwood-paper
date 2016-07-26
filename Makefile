all:
			pandoc --template=template/nonumtemplate.tex \
             --toc \
             --number-sections \
             --filter pandoc-crossref \
             --filter pandoc-citeproc \
             --csl=bibliography/ieee-with-url.csl \
             --bibliography=bibliography/bibliography.bib \
		         src/* -o report.pdf

clean:
			rm report.pdf

