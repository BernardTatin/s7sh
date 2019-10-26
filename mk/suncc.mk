#
# Compilation with Solaris C compiler
#

include mk/common-cc.mk

CC = cc
FLAGS = -Bdynamic -Xcc -m64
#-Wall -Wextra -Wno-unused-parameter -Wno-implicit-fallthrough
# -pedantic
OFLAGS = -xO2
ALLFLAGS = $(FLAGS) $(DFLAGS) $(IFLAGS) $(OFLAGS)

LD = cc
LFLAGS = -m64 -Bdynamic  -ldl -lm

