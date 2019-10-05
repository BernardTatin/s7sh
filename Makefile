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
FLAGS = -Wall -Wextra
# -pedantic  
DFLAGS = -DUSE_SND=0 
IFLAGS = -I.
OFLAGS = -O2
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = gcc
LFLAGS =  -ldl -lm -Wl,-export-dynamic

all: $(_odir) $(_exe)

$(_odir):
	mkdir -p $@

$(_exe): $(_objs)
	$(LD) $(_objs) $(LFLAGS) -o $@

$(_odir)/%.o: %.c $(_deps)
	$(CC) $(ALLFLAGS) -c $< -o $@

clean:
	@rm -fv $(_exe) $(_objs)

test: all 
	./$(_exe)

.PHONY: all clean install test
