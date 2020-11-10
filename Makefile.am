#PKGLIBDIR = @libdir@/@package@$(KVCONFIG) --pkglibdir

#ACLOCAL_AMFLAGS = -I m4

SUBDIRS = src


install-data-hook:
	$(install_sh) -m 755 -d $(DESTDIR)/usr/share/perl5
	cp -f src/Kvutil.pm  $(DESTDIR)/usr/share/perl5/

include mk/debian.mk
