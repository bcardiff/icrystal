CRYSTAL ?= crystal

CRYSTAL_CONFIG_PATH=$(shell $(CRYSTAL) env CRYSTAL_PATH 2> /dev/null)
CRYSTAL_CONFIG_LIBRARY_PATH=$(shell $(CRYSTAL) env CRYSTAL_LIBRARY_PATH 2> /dev/null)

EXPORTS := \
  CRYSTAL_CONFIG_PATH="$(CRYSTAL_CONFIG_PATH)" \
  CRYSTAL_CONFIG_LIBRARY_PATH="$(CRYSTAL_CONFIG_LIBRARY_PATH)"

SHELL = sh

BINDIR = ./bin

.PHONY: $(BINDIR)/icrystal
$(BINDIR)/icrystal:
	mkdir -p $(BINDIR)
	$(EXPORTS) $(CRYSTAL) build $(FLAGS) src/cli.cr -o $(BINDIR)/icrystal

.PHONY: $(BINDIR)/spec
$(BINDIR)/spec:
	mkdir -p $(BINDIR)
	$(EXPORTS) $(CRYSTAL) build $(FLAGS) spec/**_spec.cr -o $(BINDIR)/spec

.PHONY: spec
spec: $(BINDIR)/spec
	$(BINDIR)/spec

.PHONY: all
all: $(BINDIR)/icrystal

clean:
	rm -f bin/*
