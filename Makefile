CRYSTAL ?= crystal

CRYSTAL_CONFIG_PATH=$(shell $(CRYSTAL) env CRYSTAL_PATH 2> /dev/null)
CRYSTAL_CONFIG_LIBRARY_PATH=$(shell $(CRYSTAL) env CRYSTAL_LIBRARY_PATH 2> /dev/null)

EXPORTS := \
  CRYSTAL_CONFIG_PATH="$(CRYSTAL_CONFIG_PATH):$(CURDIR)/src/std" \
  CRYSTAL_CONFIG_LIBRARY_PATH="$(CRYSTAL_CONFIG_LIBRARY_PATH)"

SHELL = sh

BINDIR = ./bin

$(BINDIR)/icrystal: src/cli.cr src/icrystal.cr src/icrystal/*.cr
	mkdir -p $(BINDIR)
	$(CRYSTAL) build $(FLAGS) src/cli.cr -o $(BINDIR)/icrystal

$(BINDIR)/spec: src/*.cr src/**/*.cr spec/*.cr
	mkdir -p $(BINDIR)
	$(CRYSTAL) build $(FLAGS) spec/**_spec.cr -o $(BINDIR)/spec

.PHONY: $(BINDIR)/crystal-repl-server
$(BINDIR)/crystal-repl-server:
	$(MAKE) -C ./lib/crystal-repl-server ../../bin/crystal-repl-server BINDIR=../../bin CRYSTAL=$(CRYSTAL) $(EXPORTS)

.PHONY: spec
spec: $(BINDIR)/spec
	$(BINDIR)/spec

.PHONY: all
all: $(BINDIR)/icrystal $(BINDIR)/crystal-repl-server spec

clean:
	rm -f bin/*
