# ======================================================================
# Makefile for s7
# ======================================================================

SOURCES = s7.c repl.c

_exe = repl-s7

_lobjs = $(patsubst %.c,%.o,$(notdir $(SOURCES)))
_objs = $(addprefix $(_odir)/, $(_lobjs))

_deps = s7.h

os = $(shell uname)
compiler ?= gcc
CC = $(compiler)
_odir = $(CC)-objs

ifeq ($(CC),cc)
FLAGS = -Bdynamic -Xcc
#-Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
DFLAGS = -DUSE_SND=0 -DWITH_SYSTEM_EXTRAS=1
IFLAGS = -I.
OFLAGS = -xO2
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = cc
LFLAGS = -Bdynamic  -ldl -lm
# -ldl -lm -L/opt/developerstudio12.6/lib
endif
ifeq ($(CC),gcc)
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
DFLAGS = -DUSE_SND=0 -DWITH_SYSTEM_EXTRAS=1
IFLAGS = -I.
OFLAGS = -O2 -pthread
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = gcc
ifeq ($(os),SunOS)
	LFLAGS = -L/usr/gnu/lib -ldl -lm -lintl -lpthread -flinker-output=dyn
endif
ifeq ($(os),Linux)
	LFLAGS = -ldl -lm -lpthread -Wl,-export-dynamic
endif
endif

all: $(_odir) $(_exe)

print_conf:
	@echo "os       = $(os)"
	@echo "compiler	= $(compiler)"
	@echo "CC		= $(CC)"
	@echo "LD		= $(LD)
	@echo "_objs 	= $(_objs)"
	@echo "_lobjs 	= $(_lobjs)"

$(_odir):
	mkdir -p $@

$(_exe): $(_objs)
	@echo "$(LD) $(_objs) $(LFLAGS) -o $@"
	$(LD) $(_objs) $(LFLAGS) -o $@

$(_odir)/%.o: %.c $(_deps)
	$(CC) $(ALLFLAGS) -c $< -o $@

clean:
	@rm -fv $(_exe) $(_objs)

full-clean: clean
	@rm -fv *.log *.o *.so

test: all
	./$(_exe)

test-load: all
	./$(_exe)  more-tests/fact.scm more-tests/show-facts.scm

.PHONY: all clean install test test-load full-clean print_conf
