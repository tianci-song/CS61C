CC=gcc
CFLAGS=-O3 -fopenmp
PROG=cache_blocking

$(PROG): $(PROG).c
	$(CC) $(CFLAGS) -o $@ $^

clean:
	rm $(PROG)
