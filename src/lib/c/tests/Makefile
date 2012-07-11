######################################################################
# Copyright (C) 2011 Hewlett-Packard Development Company, L.P.
# 
# This program is free software; you can redistribute it and/or
# modify it under the terms of the GNU General Public License
# version 2 as published by the Free Software Foundation.
# 
# This program is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
# GNU General Public License for more details.
# 
# You should have received a copy of the GNU General Public License along
# with this program; if not, write to the Free Software Foundation, Inc.,
# 51 Franklin Street, Fifth Floor, Boston, MA  02110-1301, USA.
######################################################################
TOP = ../../../..
include $(TOP)/Makefile.conf
SRCDIR = ..

TESTDIR = $(TOP)/src/testing/lib/c
TESTLIB = -L$(TESTDIR) -l focunit -I $(TESTDIR)
CFLAGS_LOCAL = $(CFLAGS_DB) $(CFLAGS_REPO) $(ALL_CFLAGS) \
               $(TESTLIB) -I$(SRCDIR) -I../ -lcunit
EXE = testlibs

OBJS = test_fossconfig.o    \
       test_fossscheduler.o \
       test_libfossdb.o     \

COVE = fossconfig_cov.o    \
       fossscheduler_cov.o \

all: test
test: $(EXE)
	@echo "make library tests"
	./$(EXE)

coverage: $(OBJS) libfossology_cov.a $(EXE).c
	@echo "make library coverage tests"
	$(CC) $(EXE).c -o $(EXE) $(OBJS) libfossology_cov.a $(CFLAGS_LOCAL) $(FLAG_COV)
	./$(EXE)
	lcov --directory $(SRCDIR)/ --capture --output-file cov.txt; \
	genhtml -o results cov.txt

$(EXE): $(OBJS) libfossology.a $(EXE).c
	$(CC) $(EXE).c -o $@ $(OBJS) $(SRCDIR)/libfossology.a $(CFLAGS_LOCAL)

$(OBJS): %.o: %.c
	$(CC) -c $(CFLAGS_LOCAL) $<

libfossology.a:
	$(MAKE) -C $(SRCDIR) $@

libfossology_cov.a: $(COVE)
	ar cvr $@ $(COVE)

########################
# coverage build rules #
########################

fossconfig_cov.o: $(SRCDIR)/fossconfig.c $(SRCDIR)/fossconfig.h
	$(CC) -c $< $(FLAG_COV) $(CFLAGS_LOCAL) -DDEFAULT_SETUP='"$(SYSCONFDIR)/fossology"' -o $@

fossscheduler_cov.o: $(SRCDIR)/fossscheduler.c $(SRCDIR)/fossscheduler.h
	$(CC) -c $< $(FLAG_COV) $(CFLAGS_LOCAL) -o $@


#####################
# other build rules #
#####################

clean:
	@echo "make library tests clean"
	rm -rf $(EXE) *.o *.g *.xml *.txt *.gcda *.gcno *.a results

install:
	@echo "make library tests nothing to install"

uninstall:
	@echo "make library tests nothing to uninstall"

.PHONY: all install uninstall clean test 