# ======================================================================
# Makefile for s7
# ======================================================================

SOURCES = s7.c repl.c

_lobjs = $(patsubst %.c,%.o,$(notdir $(SOURCES)))
_objs = $(addprefix $(_odir)/, $(_lobjs))

_deps = s7.h

os = $(shell uname)
compiler ?= gcc
_odir = $(CC)-objs

ifeq ($(compiler),suncc)
	include mk/suncc.mk
endif
ifeq ($(compiler),clang)
	include mk/clang.mk
endif
ifeq ($(compiler),gcc)
	include mk/gcc.mk
endif

_exe = repl-s7-$(compiler)

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
	@rm -fv libc_s7.so
	./$(_exe)

test-load: all
	@rm -fv libc_s7.so
	./$(_exe)  more-tests/fact.scm more-tests/show-facts.scm

.PHONY: all clean install test test-load full-clean print_conf
