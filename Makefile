all: aes_128_encrypt

aes_128_encrypt:
	iverilog -o aes_128_encrypt_test aes_128_encrypt.v aes_128_encrypt_test.v && ./aes_128_encrypt_test

clean:
	rm -f ./aes_128_encrypt_test
