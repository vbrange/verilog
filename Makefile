all: aes_128

aes_128:
	iverilog -o aes_128_test aes_128.v aes_128_test.v && ./aes_128_test

clean:
	rm -f ./aes_128_test
