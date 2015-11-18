compile:
	gcc -c ipl.S -o tmp.o
	ld -Ttext=0x7c00 tmp.o -o ../bin/ipl.bin --oformat binary
	gcc -S  bootpack.c 
	gcc -c  bootpack.s -o tmp.o
	ld tmp.o -o ../bin/myos.bin --oformat binary
	rm tmp.o

install:
	sudo umount ../usb
	sudo mkfs.vfat -I /dev/sdb
	sudo dd if=../bin/ipl.bin of=/dev/sdb
	sudo mount /dev/sdb	../usb
	sudo cp ../bin/myos.bin ../usb

mbr:
	sudo xxd -l 0x200 /dev/sdb

clean:
	rm ../bin/*
