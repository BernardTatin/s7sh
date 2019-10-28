#
# Compilation with llvm C compiler
#

include mk/common-cc.mk

CC = clang
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
DFLAGS += -DHAVE_COMPLEX_NUMBERS=0
OFLAGS = -O0 -pthread

ALLFLAGS = -fPIC $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

ifeq ($(os),NetBSD)
COMMON_LIBS = -lpthread -lm
else
COMMON_LIBS = -lpthread -ldl -lm
endif

LD = clang
ifeq ($(os),SunOS)
	LFLAGS = -fPIC $(COMMON_LIBS) -Wl,-Bdynamic
else
	LFLAGS = -fPIC $(COMMON_LIBS) -Wl,-export-dynamic
endif
