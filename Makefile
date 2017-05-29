
SOURCES=$(wildcard *.md)
TARGETS=$(patsubst %.md,%.html,$(SOURCES))

PANDOCOPTS=--css=style.css --include-before-body=navbar.html --standalone --template=template.html

.PHONY: all clean
all: $(TARGETS)

clean:
	rm -f $(TARGETS)

%.html: %.md metadata navbar.html template.html
	pandoc $(PANDOCOPTS) -f markdown -t html metadata $< -o $@
