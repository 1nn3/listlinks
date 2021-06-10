prefix ?= ~/.local

bindir ?= $(prefix)/bin
libdir ?= $(prefix)/lib

all:

install:
	install -D selenium-listlinks.py $(DESTDIR)$(bindir)/listlinks
	install -D listlinks-notify.sh $(DESTDIR)$(bindir)/listlinks-notify

uninstall:
	-rm -f $(DESTDIR)$(bindir)/listlinks
	-rm -f $(DESTDIR)$(bindir)/listlinks-notify

clean:

distclean: clean

.PHONY: all install clean distclean uninstall

