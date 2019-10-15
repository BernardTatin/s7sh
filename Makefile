# ======================================================================
# Makefile for s7
# ======================================================================

SOURCES = s7.c repl.c

_odir = objs
_exe = repl-s7

_lobjs = $(patsubst %.c,%.o,$(notdir $(SOURCES)))
_objs = $(addprefix $(_odir)/, $(_lobjs))

_deps = s7.h Makefile

CC = gcc
CCNAME = gcc
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
DFLAGS = -DUSE_SND=0 -DWITH_SYSTEM_EXTRAS=1
IFLAGS = -I.
OFLAGS = -O2 -pthread
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = gcc
LFLAGS =  -ldl -lm -lpthread -Wl,-export-dynamic

all: $(_odir) $(_exe)

$(_odir):
	mkdir -p $@

$(_exe): $(_objs)
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

.PHONY: all clean install test test-load full-clean
