all:

prepare:
	apt install gperf bison libtool flex texinfo help2man gawk libpython-dev libpython3-dev python-serial

tool:
	if [ ! -d esp-open-sdk ] ; then git clone --recursive https://github.com/pfalcon/esp-open-sdk.git;  fi
	if [ ! -d esp-open-sdk/xtensa-lx106-elf/bin ] ; then \
	cd esp-open-sdk; make STANDALONE=y; \
	mv esp-open-sdk/xtensa-lx106-elf/bin/esptool.py esp-open-sdk/xtensa-lx106-elf/bin/esptool.py.bck; \
	fi
	#use esptool instead
	make esptool

tool-tar:
	cd esp-open-sdk; tar czvf sdk.tar.gz sdk/* xtensa-lx106-elf

esp8266-pre: tool
	git submodule update --init
	cd micropython/; make -C mpy-cross

esp8266: esp8266-pre
	export PATH=$$PATH:$(CURDIR)/esptool:$(CURDIR)/esp-open-sdk/xtensa-lx106-elf/bin; cd micropython/esp8266; make axtls ; make  

.PHONY: esp8266 esptool

###################################

esptool:
	if [ ! -d esptool ]; then git clone git@github.com:eiselekd/esptool.git; fi

restore: esptool
	$(CURDIR)/esptool/esptool.py --port /dev/ttyUSB0 erase_flash  
	$(CURDIR)/esptool/esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x00000 fw/boot_v1.7.bin
	$(CURDIR)/esptool/esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x3fc000 fw/esp_init_data_default.bin

restore-nodemcu: restore
	$(CURDIR)/esptool/esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x00000 fw-compiled-from-docker/nodemcu_integer_master_20170623-1447.bin
	echo "Reboot: wait for filesystem reformat, connect 'screen /dev/ttyUSB0 115200' (ctrl-a k y)"

restore-micropython: restore
	$(CURDIR)/esptool/esptool.py --port /dev/ttyUSB0 write_flash -fm dio 0x00000 micropython/esp8266/build/firmware-combined.bin
	echo "Connect 'screen /dev/ttyUSB0 115200' (ctrl-a k y)"
