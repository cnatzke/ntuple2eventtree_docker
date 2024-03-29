.EXPORT_ALL_VARIABLES:

.SUFFIXES:

.PHONY: clean all

# := is only evaluated once

SHELL 		= /bin/sh

NAME		   = NTuple2EventTree

LIB_DIR 	   = /software/CommandLineInterface/lib

COMM_DIR 	= /software/CommandLineInterface

ROOTLIBS    := $(shell root-config --libs)
ROOTFLAGS   := $(shell root-config --cflags)
ROOTINC     := -I$(shell root-config --incdir)

GRSI_CONFIG = $(shell which grsi-config)

ifeq ($(GRSI_CONFIG),)
$(error $(GRSI_CONFIG): grsi-config not found, did you source thisgrsi.sh?)
endif

INCLUDES    = -I$(COMM_DIR) -I.

LIBRARIES	= CommandLineInterface Utilities

CC		      = gcc
CXX         = g++
CPPFLAGS 	= $(ROOTINC) $(INCLUDES)
CXXFLAGS	   = $(ROOTFLAGS) -pedantic -Wall -Wno-long-long -g -O3 $(shell $(GRSI_CONFIG) --cflags --GRSIData-cflags)

LDFLAGS		= -g -fPIC

LDLIBS 		= -L$(LIB_DIR) -Wl,-rpath,/opt/gcc/lib64 $(ROOTLIBS) $(addprefix -l,$(LIBRARIES)) $(shell $(GRSI_CONFIG) --all-libs --GRSIData-libs) -L/opt/local/lib

ROOTCINT=$(shell command -v rootcint 2> /dev/null)
ifndef $(ROOTCINT)
   ROOTCINT=rootcling
else
   ROOTCINT=rootcint
endif


LOADLIBES = \
	Converter.o \
	Settings.o \
	$(NAME)Dictionary.o

# -------------------- implicit rules --------------------
# n.o made from n.c by 		$(CC) -c $(CPPFLAGS) $(CFLAGS)
# n.o made from n.cc by 	$(CXX) -c $(CPPFLAGS) $(CXXFLAGS)
# n made from n.o by 		$(CC) $(LDFLAGS) n.o $(LOADLIBES) $(LDLIBS)

# -------------------- rules --------------------

all:  $(NAME)
	@echo Done

# -------------------- pattern rules --------------------
# this rule sets the name of the .cc file at the beginning of the line (easier to find)

%.o: %.cc %.hh
	$(CXX) $< -c $(CPPFLAGS) $(CXXFLAGS) -o $@

# -------------------- default rule for executables --------------------

%: %.cc $(LOADLIBES)
	$(CXX) $< $(CXXFLAGS) $(CPPFLAGS) $(LOADLIBES) $(LDFLAGS) $(LDLIBS) -o $@

# -------------------- Root stuff --------------------

DEPENDENCIES = \
	RootLinkDef.h

$(NAME)Dictionary.o: $(NAME)Dictionary.cc
	 $(CXX) -fPIC $(CXXFLAGS) $(CPPFLAGS) -c $<

$(NAME)Dictionary.cc: $(DEPENDENCIES)
	 rm -f $(NAME)Dictionary.cc $(NAME)Dictionary.h; $(ROOTCINT) -f $@ -c $(CPPFLAGS) $(DEPENDENCIES)

# -------------------- tar ball --------------------

tar:
	@echo "creating zipped tar-ball ... "
	@tar -cvzf $(NAME).tar.gz ../$(NAME)/Makefile \
	../$(NAME)/*.hh ../$(NAME)/*.cc \
	../$(NAME)/lib$(NAME).so \
	../$(NAME)/RootLinkDef.h ../$(NAME)/Settings.dat

# -------------------- clean --------------------

clean:
	@rm  -f $(NAME) lib$(NAME).so *.o $(NAME)Dictionary.cc $(NAME)Dictionary.h $(NAME)Dictionary_rdict.pcm
