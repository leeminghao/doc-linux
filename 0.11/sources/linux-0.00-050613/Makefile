AS86     =as86 -0 -a
LD86     =ld86 -0
AS       =as --32
LD       =ld
LDFLAGS  =-m elf_i386 -Ttext 0 -e startup_32 -s -x -M

all: Image

Image: boot system
	dd bs=32 if=boot of=Image skip=1
	objcopy -O binary system head
	cat head >> Image

disk: Image
	dd bs=8192 if=Image of=a.img conv=notrunc
	sync; sync; sync

system: head.o
	$(LD) $(LDFLAGS) head.o -o system > System.map

head.o: head.s
	$(AS) head.s -o head.o

boot: boot.s
	$(AS86) boot.s -o boot.o
	$(LD86) -s boot.o -o boot

clean:
	rm -f Image System.map core boot head *.o system *.img
