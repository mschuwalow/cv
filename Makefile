PROJECT_DIR := $(realpath $(dir $(firstword $(MAKEFILE_LIST))))

OUTPUT_DIR := $(PROJECT_DIR)/build
SRC_DIR := $(PROJECT_DIR)/src

MAINFILE := cv

PROJECT_FILES := flake.nix flake.lock
SOURCE_FILES := $(shell fd -a -t f -e tex -e sty -e png . $(SRC_DIR))
INPUT_FILES := $(PROJECT_FILES) $(SOURCE_FILES)

.PHONY: default clean list-fonts

default: $(OUTPUT_DIR)/$(MAINFILE).pdf

clean:
	rm -rf $(OUTPUT_DIR)

list-fonts:
	luaotfload-tool --update &&\
	luaotfload-tool --list='*'

$(OUTPUT_DIR)/$(MAINFILE).pdf: $(INPUT_FILES)
	rsync -a $(SRC_DIR)/ $(OUTPUT_DIR)/ &&\
	cd $(OUTPUT_DIR) &&\
	latexmk \
		-quiet \
		-g \
		-shell-escape \
		-synctex=1 \
		-interaction=nonstopmode \
		-halt-on-error \
		-lualatex \
		-norc \
		-jobname=$(MAINFILE)
