# Based on the makefile found in http://stuff.mit.edu/people/jcrost/latexmake.html by Chris Rost.

# set projectname to the name of the main file without the .tex

include configs

# if no references, run "touch projectname.bbl; touch referencefile.bib"
# or delete dependency in .dvi and tarball sections
referencefile = refs

TEX = latex
BIBTEX = bibtex
HTTEX = htlatex

# support subdirectories
VPATH = Figs

all: pdf

pdf : $(projectname).pdf

$(projectname).pdf : $(projectname).ps
	ps2pdf $(projectname).ps $(projectname).pdf

$(projectname).ps : $(projectname).dvi
	dvips $(projectname)

$(projectname).dvi : $(figures) $(projectname).tex $(projectname).bib $(otherfiles)
	$(TEX) $(projectname); \
	$(BIBTEX) $(projectname); \
	while ($(TEX) $(projectname) ; \
	grep -q "Rerun to get citations correct." $(projectname).log || grep -q "There were undefined references." $(projectname).log ) do true ; \
	done

# keep .eps files in the same directory as the .fig files
%.eps : %.fig
	fig2dev -L eps $< > $(dir $< )$@

ps : $(projectname).ps

# make can't know all the sourcefiles.  some file may not have
# sourcefiles, e.g. eps's taken from other documents. 
$(projectname).tar.gz : $(figures) $(projectname).tex $(referencefile).bib
	tar -czvf $(projectname).tar.gz $^

tarball: $(projectname).tar.gz

html: $(projectname).html

$(projectname).html : $(figures) $(projectname).tex $(projectname).bbl $(otherfiles)
	$(HTTEX) $(projectname); \
	$(BIBTEX) $(projectname); \
	while ($(HTTEX) $(projectname) ; \
	grep -q "Rerun to get citations correct." $(projectname).log ) do true ; \
	done
