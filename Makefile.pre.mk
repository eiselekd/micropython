all:

prepare:
	apt install gperf bison libtool flex texinfo help2man gawk libpython-dev libpython3-dev python-serial

tool:
	if [ ! -d esp-open-sdk ] ; then git clone --recursive https://github.com/pfalcon/esp-open-sdk.git;  fi
	cd esp-open-sdk; make STANDALONE=y
	mv esp-open-sdk/xtensa-lx106-elf/bin/esptool.py esp-open-sdk/xtensa-lx106-elf/bin/esptool.py.bck;
	git clone https://github.com/espressif/esptool

# git@github.com:eiselekd/esptool.git
esptool:
	git clone https://github.com/espressif/esptool; 

tool-tar:
	cd esp-open-sdk; tar czvf sdk.tar.gz sdk/* xtensa-lx106-elf


esp8266-pre:
	git submodule update --init
	make -C mpy-cross

esp8266:
	export PATH=$$PATH:$(CURDIR)/esp-open-sdk/xtensa-lx106-elf/bin; make axtls ; make  

.PHONY: esp8266

