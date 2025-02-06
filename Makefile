# Compiler and flags
CC = gcc
CFLAGS = -Wall -Werror -msse4.2 -fPIC
LDFLAGS = -no-pie

# Files
TARGET = main
OBJS = main.o hamming.o

# Build the target
$(TARGET): $(OBJS)
	$(CC) $(CFLAGS) $(LDFLAGS) -o $@ $^

# Generic rule to compile both .c and .s files
%.o: %.c %.s
	$(CC) $(CFLAGS) -c $< -o $@

# Clean up the object files and the executable
.PHONY: clean
clean:
	rm -f $(OBJS) $(TARGET)
