# Makefile for Classed Modules
#
#    Copyright (C) 1995  Alan K. Stebbens <aks@hub.ucsb.edu>
#
#    This program is free software; you can redistribute it and/or modify
#    it under the terms of the GNU General Public License as published by
#    the Free Software Foundation; either version 2 of the License, or
#    (at your option) any later version.
#
#    This program is distributed in the hope that it will be useful,
#    but WITHOUT ANY WARRANTY; without even the implied warranty of
#    MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
#    GNU General Public License for more details.
#
#    You should have received a copy of the GNU General Public License
#    along with this program; if not, write to the Free Software
#    Foundation, Inc., 675 Mass Ave, Cambridge, MA 02139, USA.
#
#    $Id: Makefile,v 1.2 1996/03/01 02:54:34 aks Exp $

    # Set DEFAULT one or more of install-local, install-net, or 
    # install-home
    #
    # If INSTALL_VER is 'yes', this Makefile installs files both with and
    # without versions.  The non-version named is linked to the versioned
    # name.  This allows updates of a newer version without completely
    # stepping on the older version.  Users preferring the older version
    # can do:
    #
    #	use 'Array::PrintCols-1.1';
    #
    # If INSTALL_VER is 'no', then only the non-version names are 
    # installed.
    #
    #
    # Versioned names:
    #
    #	/usr/local/perl5/lib/Array/PrintCols-1.1.pm
    #
    # Non-versioned names:
    #
    #	/usr/local/perl5/lib/Array/PrintCols.pm

       CLASS = Sys
    MOD_NAME = OutPut
 
    # Set this to 'no', if you do not want version numbers to 
    # be installed

    INSTALL_VER = yes

      MODULE = $(LIB)/$(CLASS)/$(MOD_NAME).pm
  MODULE_VER = $(LIB)/$(CLASS)/$(MOD_NAME)-$(VERSION).pm
     VERSION = 0

    # Where Perl 5 lives

        PERL = /usr/local/bin/perl5

     DEFAULT = install-local
 
     NETROOT = /eci
      NETLIB = $(NETROOT)/perl5/lib
      NETMAN = $(NETROOT)/perl5/man/man$(MANSEC)
  
   LOCALROOT = /usr/local
    LOCALLIB = $(LOCALROOT)/perl5/lib
    LOCALMAN = $(LOCALROOT)/perl5/man/man$(MANSEC)
  
    HOMEROOT = $(HOME)
     HOMELIB = $(HOMEROOT)/lib/perl
     HOMEMAN = $(HOME)/man/man$(MANSEC)
  
    # Define the man section, and possibly a suffix.

      MANSEC = 3
     #MANSFX = p
      MANSFX =
     MANPAGE = $(MAN)/$(CLASS)::$(MOD_NAME).$(MANSEC)$(MANSFX)

   SHARFILES = README $(MOD_NAME).pm Makefile test.pl test.out.ref Copyright GNU-LICENSE
    SHAROPTS = -cm -s $(LOGNAME)@`hostname`
     ARCHIVE = $(CLASS)-$(MOD_NAME)
 ARCHIVE_VER = $(ARCHIVE)-$(VERSION)

    ARCHIVES = $(ARCHIVE).tar.gz $(ARCHIVE_VER).tar.gz $(ARCHIVE).shar $(ARCHIVE_VER).shar

     FTPHOST = root@hub.ucsb.edu
     FTPHOME = /usr/home/ftp
  FTPDESTDIR = /pub/prog/perl

     POD2MAN = pod2man

         LIB = .phony-lib
         MAN = .phony-man

       SHELL = /bin/sh

help:
	@echo 'make install             Default install ($(DEFAULT))'
	@echo 'make install-net         Install in $(NETLIB)'
	@echo 'make install-ftp         Install in $(FTPHOST):$(FTPHOME)$(FTPDESTDIR)'
	@echo 'make install-home        Install in $(HOMELIB)'
	@echo 'make install-local       Install in $(LOCALLIB)'
	@echo 'make install-cpan	Install in CPAN archives'
	@echo 'make uninstall           remove all installed files'
	@echo 'make uninstall-net       remove installed files from $(NETLIB)'
	@echo 'make uninstall-home      remove installed files from $(HOMELIB)'
	@echo 'make uninstall-local     remove installed files from $(LOCALLIB)'
	@echo 'make tar                 Make a tar.gz archive'
	@echo 'make shar                Make a shar archive'
	@echo 'make test                Run canned tests'
	@echo 'make help                This message'

    # Here's where we do testing

test:	test.out.ref test.out
	-diff test.out.ref test.out > test.out.diff
	@if [ -s test.out.diff ]; then			\
	    echo "There are differences." ; 		\
	else						\
	    echo "No differences." ;			\
	    rm -f test.out.diff test.out ;		\
	fi

GENTEST = $(MAKE) TESTOUT='$@' do-test

test.out.ref:	test.pl	; @$(MAKE) TESTOUT='$@' do-test
test.out:	test.pl ; @$(MAKE) TESTOUT='$@' do-test

do-test:
	@rm -f $(TESTOUT)
	-$(PERL) test.pl >test.stdout 2>test.stderr
	echo "*** STDOUT ***"	 > $(TESTOUT)
	cat test.stdout		>> $(TESTOUT)
	echo "*** STDERR ***"	>> $(TESTOUT)
	cat test.stderr		>> $(TESTOUT)
	@rm -f test.stdout test.stderr


    # Beginning of the "install" targets

install:	$(DEFAULT)

install-all:	install-local install-home install-net

install-local:
	@$(MAKE) LIB='$(LOCALLIB)' 		\
		MAN='$(LOCALMAN)' 		\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-net:	
	@$(MAKE) LIB='$(NETLIB)'		\
		MAN='$(NETMAN)'			\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-home:
	@$(MAKE) LIB='$(HOMELIB)' 		\
		MAN='$(HOMEMAN)' 		\
		INSTALL_VER=$(INSTALL_VER) 	\
	    install-version

install-version:
	@if [ "$(INSTALL_VER)" != yes ]; then		\
	    $(MAKE)	MODULE_VER='$(MODULE)' 		\
			LIB='$(LIB)'			\
			MAN='$(MAN)'			\
		install-module install-man ;		\
	else						\
	    $(MAKE) version ;				\
	    $(MAKE) 	LIB='$(LIB)'			\
			MAN='$(MAN)'			\
			VERSION=`cat .version`		\
		install-module install-man ;		\
	fi

install-module:	$(LIB)/$(CLASS) $(MODULE_VER)

$(MODULE_VER):	$(MOD_NAME).pm
	@rm -f $@
	cp $(MOD_NAME).pm $@
	@if [ "$(MODULE_VER)" != "$(MODULE)" ]; then	\
	    $(MAKE) SRC='$(MODULE_VER)' 		\
	    	    LINK='$(MODULE)' 			\
		link ;					\
	fi

link:
	@rm -f $(LINK)
	ln $(SRC) $(LINK)

version:	.version
.version:	$(MOD_NAME).pm
	@rm -f $@
	awk '/[$$]Id[:]/{print $$4}' $(MOD_NAME).pm > $@

    # install-man is a target which checks for the manual source
    # being newer than the pod2man output without using make's
    # own rules, because the the "::" syntax in the output module 
    # name confuses most make scripts.  So, we use find's -newer 
    # operator to tell us.

install-man:
	@new=1 ; 						\
	if [ -f $(MANPAGE) ]; then				\
	   new=`find $(MOD_NAME).pm -newer $(MANPAGE)		\
		-print 2>/dev/null` ;				\
	fi ;							\
	if [ -n "$$new" ]; then					\
	    $(MAKE) MAN='$(MAN)' pod-to-man ;			\
	fi

    # pod-to-man: unconditionally generate a man page from the
    # POD module text.

pod-to-man:
	@rm -f $(MANPAGE)
	$(POD2MAN) $(MOD_NAME).pm > $(MANPAGE)

    # Build target library directories if necessary

$(LIB) $(LIB)/$(CLASS) $(MAN):
	mkdir -p $@

INSTALLED_FILES = $(MODULE_VER) $(MODULE) $(MANPAGE) 

uninstall:	uninstall-net uninstall-home uninstall-local

uninstall-net:
	@$(MAKE) LIB='$(NETLIB)' MAN='$(NETMAN)' uninstall-it

uninstall-home:
	@$(MAKE) LIB='$(HOMELIB)' MAN='$(HOMEMAN)' uninstall-it

uninstall-local:
	@$(MAKE) LIB='$(LOCALLIB)' MAN='$(LOCALMAN)' uninstall-it

uninstall-it:
	@for file in $(INSTALLED_FILES) ; do	\
	  if [ -f $$file ]; then		\
	    $(MAKE) LIB='$(LIB)'		\
		    MAN='$(MAN)'		\
		    RMFILE="$$file"		\
		remove-it ;			\
	  fi ;					\
	done

remove-it:
	rm -f $(RMFILE)

    # 	Archive creation stuff
    #
    #  MAKE_ARCHIVE invokes another 'make' at the directory level above the
    #  current one, with the variables FILES, DIR, and ARCHIVE set
    #  appropriately.

MAKE_ARCHIVE = 	cwd=`pwd` ;			\
		cd .. ; 			\
		dir=`basename $$cwd` ;		\
		files=`echo "$(SHARFILES)" |	\
		       tr ' ' '\12' |		\
		       sed -e "s=^=$$dir/=" |	\
		       tr '\12' ' ' ` ;		\
		$(MAKE) -f $$dir/Makefile	\
			FILES="$$files"		\
			DIR=$$dir		\
			ARCHIVE=$(ARCHIVE_VER)

tar:			version
	@$(MAKE) VERSION="`cat .version`" tar-nover

shar:			version
	@$(MAKE) VERSION="`cat .version`" shar-nover

shar-nover: 		$(ARCHIVE).shar
tar-nover: 		$(ARCHIVE).tar.gz

$(ARCHIVE).tar.gz:	$(ARCHIVE_VER).tar.gz
	@rm -f $@
	ln $? $@

$(ARCHIVE).shar:	$(ARCHIVE_VER).shar
	@rm -f $@
	ln $? $@

$(ARCHIVE_VER).tar.gz:	$(SHARFILES)
	@$(MAKE_ARCHIVE) make-tar
	@rm -f $@
	gzip $(ARCHIVE_VER).tar

$(ARCHIVE_VER).shar:	$(SHARFILES)
	@$(MAKE_ARCHIVE) make-shar

make-tar:	$(FILES)
	@rm -f $(DIR)/$(ARCHIVE).tar
	tar cvf $(DIR)/$(ARCHIVE).tar $(FILES)

make-shar:	$(FILES)
	@rm -f $(DIR)/$(ARCHIVE).shar $(DIR)/$(ARCHIVE).shar
	shar $(SHAROPTS) $(FILES) > $(DIR)/$(ARCHIVE).shar

clean:
	rm -f *.tar.gz *.shar .version

install-ftp: shar tar
	$(MAKE) VERSION=`cat .version` install-ftp-version

install-ftp-version: $(ARCHIVES)
	@for archive in $(ARCHIVES); do 	\
	    $(MAKE) VERSION='$(VERSION)' 	\
	    	    FILE="$$archive"		\
		install-ftp-archive ;		\
	done

install-ftp-archive:	$(FILE)
	rcp $(FILE) $(FTPHOST):$(FTPHOME)$(FTPDESTDIR)

install-cpan:	tar
	$(MAKE) -f Makefile.cpan		\
		VERSION=`cat .version`		\
		CLASS='$(CLASS)'		\
		MOD_NAME='$(MOD_NAME)'		\
	    install-cpan
