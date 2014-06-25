#
# Makefile for vbkick and convert_2_scancode.py scripts (bash & python)
# src: https://github.com/wilas/vbkick
#
# Copyright (c) 2013-2014, Kamil Wilas (wilas.pl)
# This Source Code Form is subject to the terms of the Mozilla Public
# License, v. 2.0. If a copy of the MPL was not distributed with this
# file, You can obtain one at http://mozilla.org/MPL/2.0/.
#
.PHONY: all install uninstall tests clean

# where place files
MANDIR := /usr/local/man/man1
PREFIX ?= /usr/local/bin

# get info about env.
BASH_DEFAULT := $(shell command -v bash 2>&1)
PL_DEFAULT := $(shell command -v perl 2>&1)

# install command
INSTALL := install

# place for tmp files
BUILD_DIR := build_src

# what scripts install/uninstall
BASH_TARGET := vbkick
PL_TARGET := vbhttp.pm vbtyper.pm

# needed to remove already installed legancy script
PY_TARGET := convert_2_scancode.py


all:
	@printf "%b" "usage:\tmake install\n"
	@printf "%b" "\tmake uninstall\n"

install: check-install
	mkdir -p $(BUILD_DIR)
	@for file in $(PL_TARGET); do \
		sed '1,1 s:#!/usr/bin/perl:#!$(PL_SHEBANG):; 1,1 s:"::g' $$file > $(BUILD_DIR)/$$file.tmp; \
	done
	@sed '1,1 s:#!/bin/bash:#!$(BASH_SHEBANG):; 1,1 s:"::g' $(BASH_TARGET) > $(BUILD_DIR)/$(BASH_TARGET).tmp
	$(INSTALL) -m 0755 -d $(PREFIX)
	@for file in $(PL_TARGET); do \
		printf "%b" "$(INSTALL) -m 0755 -p $(BUILD_DIR)/$$file.tmp $(PREFIX)/$$file\n"; \
		$(INSTALL) -m 0755 -p $(BUILD_DIR)/$$file.tmp $(PREFIX)/$$file; \
	done
	$(INSTALL) -m 0755 -p $(BUILD_DIR)/$(BASH_TARGET).tmp $(PREFIX)/$(BASH_TARGET)
	$(INSTALL) -m 0755 -d $(MANDIR)
	$(INSTALL) -g 0 -o 0 -m 0644 -p docs/man/vbkick.1 $(MANDIR)
	rm -rf $(BUILD_DIR)

uninstall:
	cd $(MANDIR) && rm -f vbkick.1
	cd $(PREFIX) && rm -f $(BASH_TARGET) && rm -f $(PY_TARGET)
	@for file in $(PL_TARGET); do \
		printf "%b" "rm -f $(PREFIX)/$$file\n"; \
		rm -f $(PREFIX)/$$file; \
	done

tests:
	perl tests/test_vbhttp.t
	@printf "%b\n" ""
	perl tests/test_vbtyper.t

clean:
	rm -rf $(BUILD_DIR)

check-install:
ifndef BASH_SHEBANG
  ifndef BASH_DEFAULT
    $(error "bash command not available")
  endif
  BASH_SHEBANG := $(BASH_DEFAULT)
endif
ifndef PL_SHEBANG
  ifndef PL_DEFAULT
    $(error "perl command not available")
  endif
  PL_SHEBANG := $(PL_DEFAULT)
endif
