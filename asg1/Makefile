# $Id: Makefile,v 1.8 2014-10-07 17:37:02-07 - - $

GPP   = g++ -g -O0 -Wall -Wextra -std=gnu++11
GRIND = valgrind --leak-check=full --show-reachable=yes

all : oc

oc : main.o stringset.o auxlib.o
	${GPP} main.o stringset.o auxlib.o -o oc

%.o : %.cc
	${GPP} -c $<

ci :
	cid + Makefile stringset.h stringset.cc main.cc 

spotless : clean
	- rm oc

clean :
	-rm stringset.o main.o

# Depencencies.
main.o: main.cc stringset.h auxlib.h
stringset.o: stringset.cc stringset.h
auxlib.o: auxlib.cc auxlib.h

