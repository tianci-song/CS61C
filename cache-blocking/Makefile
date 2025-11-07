CC=gcc
CFLAGS=-O3
PROG1=no_block
PROG2=do_block
PROG3=cache_blocking

all: 
	$(CC) $(CFLAGS) -o $(PROG1) $(PROG1).c
	$(CC) $(CFLAGS) -o $(PROG2) $(PROG2).c
	$(CC) $(CFLAGS) -o $(PROG3) $(PROG3).c

$(PROG1): $(PROG1).c
	$(CC) $(CFLAGS) -o $@ $^

$(PROG2): $(PROG2).c
	$(CC) $(CFLAGS) -o $@ $^

$(PROG3): $(PROG3).c
	$(CC) $(CFLAGS) -o $@ $^

run:
	perf stat -e cache-misses,cache-references,L1-dcache-load-misses ./$(PROG1)
	perf stat -e cache-misses,cache-references,L1-dcache-load-misses ./$(PROG2)

clean:
	rm $(PROG1) $(PROG2) $(PROG3)
