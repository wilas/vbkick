# Makefile for vbkick and convert_2_scancode.py scripts (bash & python)
# src: https://github.com/wilas/vbkick

# where place scripts
prefix = /usr/local
bindir = $(prefix)/bin
mandir = /usr/local/man/man1

# install command
INSTALL = install

# what scripts install/uninstall
EXEC = vbkick convert_2_scancode.py

all:
	@printf "usage:\tmake install\n"
	@printf "\tmake uninstall\n"

install:
	$(INSTALL) -m 0755 -d $(bindir)
	$(INSTALL) -m 0755 -p $(EXEC) $(bindir)/
	$(INSTALL) -g 0 -o 0 -m 0644 -p man/vbkick.1 ${mandir}

uninstall:
	cd $(bindir) && rm -f $(EXEC)
