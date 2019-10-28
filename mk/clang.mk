#
# Compilation with llvm C compiler
#

include mk/common-cc.mk

CC = clang
FLAGS = -Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
DFLAGS += -DHAVE_COMPLEX_NUMBERS=0
OFLAGS = -O0 -pthread  
#
ALLFLAGS = -fPIC $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = clang
ifeq ($(os),SunOS)
	LFLAGS = -lpthread -ldl -lm  -Wl,-Bdynamic
#
endif
ifeq ($(os),Linux)
	LFLAGS = -fPIC -lpthread -ldl -lm  -Wl,-export-dynamic
#
endif
ifeq ($(os),NetBSD)
	LFLAGS = -fPIC -lpthread -lm  -Wl,-export-dynamic
#	LFLAGS = -fPIC -lpthread -ldl -lm  -Wl,-export-dynamic
#
endif


