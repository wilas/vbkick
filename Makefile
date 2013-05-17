# Makefile for vbkick and convert_2_scancode.py scripts (bash & python)
# src: https://github.com/wilas/vbkick

# where place scripts
prefix = /usr/local
bindir = $(prefix)/bin

# choosen install command
INSTALL = install

# what scripts do we want install/uninstall
EXEC = vbkick convert_2_scancode.py

all:
	@printf "usage:\tmake install\n"
	@printf "\tmake uninstall\n"

install:
	$(INSTALL) -m 0755 -d $(bindir)
	$(INSTALL) -m 0755 -p $(EXEC) $(bindir)/

uninstall:
	cd $(bindir) && rm -f $(EXEC)
