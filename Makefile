# Build variables
BASEBDIR=./build
BDIR=$(BASEBDIR)/`git show --oneline | head -1 | cut -d" " -f1`
SDIR=./src
BNAME=aetherials-`git show --oneline | head -1 | cut -d" " -f1`
CONF=default.cfg
SOURCE=main.tex
TEMP=templ.tex

# Author and metadata
# THESE FIELDS MAY NOT CONTAIN ANY SEMICOLONS!
TITLE=Ætherials
PENNAME=Liette Faerchild
LEGALNAME=Ren Kararou
PRONOUNS=fae/faer
STREETADDR=1010 Fake Blvd
LASTADDR=Denver, CO
EMAIL=ren@kararou.space
PHONE=(303)555-4202

all: pdf epub word cleanbuild timestamp 

timestamp: mkbuild
	if [ -f $(BDIR)/$(BNAME).epub ]; then mv $(BDIR)/$(BNAME).epub $(BDIR)/$(BNAME)-`date -u +%d%m%y-%H%M`.epub; fi
	if [ -f $(BDIR)/$(BNAME).pdf ]; then mv $(BDIR)/$(BNAME).pdf $(BDIR)/$(BNAME)-`date -u +%d%m%y-%H%M`.pdf; fi
	if [ -f $(BDIR)/$(BNAME).docx ]; then mv $(BDIR)/$(BNAME).docx $(BDIR)/$(BNAME)-`date -u +%d%m%y-%H%M`.docx; fi
		

mkbuild:
	if [ ! -d $(BDIR) ]; then mkdir -p $(BDIR); fi

mktemp: mkbuild
	if [ ! -f $(BDIR)/$(TEMP) ]; then cp $(SDIR)/$(SOURCE) $(BDIR)/$(TEMP); fi

wordcount: mktemp
	# This only works when you've got
	sed -i "s;WORDCOUNT;`cat $(SDIR)/chapters/*.tex | wc -w`;g" \
		$(BDIR)/$(TEMP)

repo: mktemp
	sed -i "s;REPO;`git remote get-url origin`;g" $(BDIR)/$(TEMP)

title: mktemp
	sed -i "s;PROJECT;$(TITLE);g" $(BDIR)/$(TEMP)

phone: mktemp
	sed -i "s;PHONE;$(PHONE);g" $(BDIR)/$(TEMP)

pen: mktemp
	sed -i "s;PENNAME;$(PENNAME);g" $(BDIR)/$(TEMP)
	# Change the following line's -f# to decide which name to use
	# LNAME needs to be the family name.
	sed -i "s;SNAME;`echo $(PENNAME) | cut -d" " -f2`;g" $(BDIR)/$(TEMP)

email: mktemp
	sed -i "s;EMAIL;$(EMAIL);g" $(BDIR)/$(TEMP)

3ppn: mktemp
	sed -i "s;PRONOUNS;$(PRONOUNS);g" $(BDIR)/$(TEMP)

addr: mktemp
	sed -i "s;STREETADDR;$(STREETADDR);g" $(BDIR)/$(TEMP)
	sed -i "s;LASTADDR;$(LASTADDR);g" $(BDIR)/$(TEMP)

lname: mktemp
	sed -i "s;LEGALNAME;$(LEGALNAME);g" $(BDIR)/$(TEMP)
	
template: mktemp wordcount repo title phone pen email 3ppn addr lname
	if [ -f $(BDIR)/$(TEMP) ]; \
		then mv $(BDIR)/$(TEMP) $(BDIR)/$(SOURCE); \
		else cp $(SDIR)/$(SOURCE) $(BDIR)/$(SOURCE); \
	fi

pdf: template
	pdflatex -jobname=$(BNAME) -output-directory=$(BDIR) $(BDIR)/$(SOURCE)

epub: template
	tex4ebook -f epub  -c $(SDIR)/$(CONF) -j $(BNAME) $(BDIR)/$(SOURCE)
	mv $(BNAME).epub $(BDIR)

word: template
	pandoc $(BDIR)/$(SOURCE) -o $(BDIR)/$(BNAME).docx

spellcheck: 
	for c in $(SDIR)/chapters/*.tex; do aspell -t -c $${c}; done

cleanbuild:
	rm -rf $(BDIR)/*.log $(BDIR)/*.aux $(BDIR)/*.toc $(BDIR)/$(TEMP) \
		$(BDIR)/$(SOURCE) ./*.opf ./*.html ./*.aux ./*.css ./*.dvi \
		./*-epub/ ./*-mobi/ ./*.idv ./*.lg ./*.log  ./*.toc ./*.xref \
		./*.4ct ./*.4tc ./*.ncx ./*.tmp $(SDIR)/chapters/*.bak

clean: cleanbuild
	rm -rf $(BASEBDIR) 

