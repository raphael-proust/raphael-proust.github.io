
SOURCES=$(wildcard *.md) $(wildcard games/*.md)
TARGETS=$(patsubst %.md,%.html,$(SOURCES))

PANDOCOPTS=--include-before-body=meta/navbar.html --standalone --template=meta/template.html
PANDOCMETADATA=--title-prefix="Dromedary and a half" --metadata=author:"Raphaël Proust" --metadata=lang:en

.PHONY: all clean
all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.md meta/navbar.html meta/template.html
	pandoc $(PANDOCOPTS) $(PANDOCMETADATA) -f markdown -t html $< -o $@
