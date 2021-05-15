all: aes_128_encrypt 

BUILD := build/

aes_128_encrypt: $(BUILD)/Vaes_128_encrypt_icarus $(BUILD)/Vaes_128_encrypt

$(BUILD)/Vaes_128_encrypt_icarus: aes_128_encrypt.v test/aes_128_encrypt_test.v
	mkdir -p $(BUILD)
	iverilog -o $@ -DICARUS $^
	./$@

$(BUILD)/Vaes_128_encrypt: aes_128_encrypt.v test/aes_128_encrypt_test.v test/aes_128_encrypt_test_main.cpp
	mkdir -p $(BUILD)
	verilator --cc --exe -Wall -Wno-DECLFILENAME --build $^ -Mdir $(BUILD)/
	./$@

clean:
	rm -rf $(BUILD)
