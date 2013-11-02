target = Loughry_HST13

paper_target = $(target)_paper
slides_target = $(target)_slides

paper_source = $(paper_target).tex
slides_source = $(slides_target).tex
latex_cmd = pdflatex
dvi_options = --output-format dvi
editor = vi

paper_counter_file = paper_build_counter.txt
slides_counter_file = slides_build_counter.txt

paper_pdf_file = $(paper_target).pdf
paper_dvi_file = $(paper_target).dvi
slides_pdf_file = $(slides_target).pdf

bibtex_file = consolidated_bibtex_file.bib
bibtex_source = ../bibtex/consolidated_bibtex_source.bib
abstract = abstract.tex

paper_sources = $(paper_source) $(bibtex_file) $(abstract)
slides_sources = $(slides_source)

temporary_files = *.log *.aux *.out *.idx *.ilg *.bbl *.blg .pdf *.nav *.snm *.toc

#
# Note: make requires that we set the value of a variable OUTSIDE any rules.
#
timestamp = `date +%Y%m%d.%H%M`

# all: $(slides_pdf_file) $(paper_dvi_file)
all: $(slides_pdf_file)

commit:
	make clean
	git add .
	git commit -am "commit from Makefile $(timestamp)"

sync:
	git pull --rebase
	git push

$(bibtex_file): $(bibtex_source)
	cp $(bibtex_source) $(bibtex_file)

graphics_for_paper = network_grounded_theory_scaled_100.eps venn_diagrams_for_paper-corrected.eps

graphics_for_slides = ISO-9-layer-model-smaller.pdf \
	venn_diagrams_for_paper-corrected.pdf \
	network_grounded_theory_scaled_100.pdf

paper_tarfile = send_this_file_to_IEEE_PDF_Express.tar
compressed_tarfile = $(paper_tarfile).gz

$(paper_dvi_file): $(paper_sources) $(graphics_for_paper) Makefile
	@echo $$(($$(cat $(paper_counter_file)) + 1)) > $(paper_counter_file)
	$(latex_cmd) $(dvi_options) $(paper_source)
	bibtex $(paper_target)
	if (grep "Warning" $(paper_target).blg > /dev/null ) then false; fi
	while ( \
		$(latex_cmd) $(dvi_options) $(paper_target) ; \
		grep "Rerun to get" $(paper_target).log > /dev/null \
	) do true ; done
	@echo "Build `cat $(paper_counter_file)`"
	rm -f $(paper_tarfile) $(compressed_tarfile)
	tar cf $(paper_tarfile) $(paper_dvi_file) $(graphics_for_paper)
	gzip $(paper_tarfile)
	@echo
	@echo IEEE requires submission of validated PDF files via the http://pdf-express.org/plus/
	@echo web site. Therefore, this Makefile must generate a DVI file, tar it with the EPS
	@echo files for graphics, and gzip. The web site opens the compressed archive and converts
	@echo the whole mess to PDF, then validates it. IEEE does not like non-Type-1 embedded font
	@echo entries in PDF files.

$(slides_pdf_file): $(slides_sources) $(graphics_for_slides) Makefile
	@echo $$(($$(cat $(slides_counter_file)) + 1)) > $(slides_counter_file)
	while ( \
		$(latex_cmd) $(slides_target) ; \
		grep "Rerun to get" $(slides_target).log > /dev/null \
	) do true ; done
	@echo "Build `cat $(slides_counter_file)`"
	chmod a-x,a+r $(slides_pdf_file)

abstract:
	$(editor) $(abstract)

vi:
	$(editor) $(slides_source)

edit:
	$(editor) $(slides_source)

spell:
	aspell --lang=EN_GB check $(abstract)
	aspell --lang=EN_GB check $(paper_source)
	aspell --lang=EN_GB check $(slides_source)

wc:
	wc -w $(abstract)

clean:
	rm -f $(temporary_files)

allclean: clean
	rm -f $(paper_dvi_file) $(slides_pdf_file) $(paper_tarfile) $(compressed_tarfile)

# Convenience targets

notes:
	(cd ../notes/ && make notes)

quotes:
	(cd ../notes/ && make quotes)

cv:
	(cd ../CV/ && make vi)

bibtex:
	(cd ../bibtex && make vi)

