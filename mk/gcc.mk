#
# Compilation with GNU C compiler
#

include mk/common-cc.mk

CC = gcc
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
OFLAGS = -O$(optim) -pthread
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = gcc
ifeq ($(os),SunOS)
	LFLAGS = -L/usr/gnu/lib -ldl -lm -lintl -lpthread -flinker-output=dyn
endif
ifeq ($(os),Linux)
	LFLAGS = -ldl -lm -lpthread -Wl,-export-dynamic
endif
ifeq ($(os),NetBSD)
	LFLAGS = -lm -lpthread -Wl,-export-dynamic
endif

