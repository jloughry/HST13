target = loughry_HST13_paper

source = $(target).tex
latex_cmd = pdflatex
editor = vi
counter_file = build_counter.txt
pdf_file = $(target).pdf
bibtex_file = consolidated_bibtex_file.bib
bibtex_source = ../bibtex/consolidated_bibtex_source.bib
abstract = abstract.tex
sources = $(source) $(bibtex_file) $(abstract)

temporary_files = *.log *.aux *.out *.idx *.ilg *.bbl *.blg .pdf

all: $(pdf_file)

$(bibtex_file): $(bibtex_source)
	cp $(bibtex_source) $(bibtex_file)

graphics = 

$(pdf_file): $(sources) $(graphics) Makefile
	@echo $$(($$(cat $(counter_file)) + 1)) > $(counter_file)
	$(latex_cmd) $(source)
	bibtex $(target)
	if (grep "Warning" $(target).blg > /dev/null ) then false ; fi
	while ( \
		$(latex_cmd) $(target) ; \
		grep "Rerun to get" $(target).log > /dev/null \
	) do true ; done
	@echo "Build `cat $(counter_file)`"
	chmod a-x,a+r $(pdf_file)

abstract:
	$(editor) $(abstract)

vi:
	$(editor) $(source)

edit:
	$(editor) $(source)

spell:
	aspell --lang=EN_GB check $(abstract)
	aspell --lang=EN_GB check $(source)

wc:
	wc -w $(abstract)

clean:
	rm -f $(temporary_files)

allclean: clean
	rm -f $(pdf_file)

# Convenience targets

notes:
	(cd ../notes/ && make notes)

quotes:
	(cd ../notes/ && make quotes)

cv:
	(cd ../CV/ && make vi)

bibtex:
	(cd ../bibtex && make vi)

