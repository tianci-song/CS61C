CC=gcc
CFLAGS=-g -O0 -Wall -mavx 
TARGET=loop_unroll

$(TARGET): loop_unroll.c
	$(CC) $(CFLAGS) -o $@ $^
	./$(TARGET)

clean:
	rm -rf $(TARGET)
