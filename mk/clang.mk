#
# Compilation with llvm C compiler
#

include mk/common-cc.mk

CC = clang
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
DFLAGS += -DHAVE_COMPLEX_NUMBERS=0
OFLAGS = -O0 -pthread
ALLFLAGS = -fPIC $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = clang
ifeq ($(os),SunOS)
	LFLAGS = -ldl -lm -lpthread -Wl,-Bdynamic
endif
ifeq ($(os),Linux)
	LFLAGS = -shared -ldl -lm -lpthread -Wl,-export-dynamic
endif


