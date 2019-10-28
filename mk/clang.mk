#
# Compilation with llvm C compiler
#

include mk/common-cc.mk

CC = clang
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
DFLAGS += -DHAVE_COMPLEX_NUMBERS=0
OFLAGS = -O0 -pthread

ALLFLAGS = -fPIC $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

COMMON_LIBS = -lpthread -ldl -lm

LD = clang
ifeq ($(os),SunOS)
	LFLAGS = $(COMMON_LIBS) -Wl,-Bdynamic
endif
ifeq ($(os),Linux)
	LFLAGS = -fPIC $(COMMON_LIBS) -Wl,-export-dynamic
endif


