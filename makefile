%.bin: %.asm
	nasm -f bin $< -o $@

master.img: boot.bin loader.bin
	yes | bximage -q -hd=16 -mode=create -sectsize=512 -imgmode=flat master.img
	dd if=boot.bin of=master.img bs=512 count=1 conv=notrunc
	dd if=loader.bin of=master.img bs=512 count=4 seek=2 conv=notrunc
.PHONY:clean
clean:
	rm -rf *.bin
	rm -rf *.img


.PHONY:bochs
bochs:master.img
	bochs -q -f bochsrc



.PHONY:bochsg
bochsg:master.img
	bochs -q -f bochsrc.gdb
	
.PHONY:qemu
qemu:master.img
	qemu-system-i386 \
	-m 32M \
	-boot c \
	-hda $<

.PHONY:qemug
qemug:master.img
	qemu-system-i386 \
	-s -S \
	-m 32M \
	-boot c \
	-hda $<
