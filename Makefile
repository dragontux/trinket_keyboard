CFLAGS  = -Wall -Os -DF_CPU=16500000 -Iusbdrv -I. -DDEBUG_LEVEL=0 -mmcu=attiny85 
CFLAGS += -fdata-sections -ffunction-sections

usbdrv_ssrc = $(wildcard usbdrv/*.S)
usbdrv_objs = $(usbdrv_csrc:.c=.o) $(usbdrv_ssrc:.S=.o)

cppsrc = $(wildcard *.cpp)
csrc   = $(wildcard *.c)
cobjs  = $(cppsrc:.cpp=.o) $(csrc:.c=.o)

objs = $(usbdrv_objs) $(cobjs)

all: $(objs) key.elf key.hex

key.elf: $(objs)
	avr-gcc $(CFLAGS) -Wl,-gc-sections -o $@ $(objs)
	avr-size $@

key.hex: key.elf
	avr-objcopy -Oihex key.elf key.hex

.S.o:
	avr-gcc $(CFLAGS) -x assembler-with-cpp -c $< -o $@

.c.o:
	avr-gcc $(CFLAGS) -c $< -o $@

.cpp.o:
	avr-g++ $(CFLAGS) -c $< -o $@

clean:
	rm -f $(objs)

flash: key.hex
	avrdude -c usbtiny -p attiny85 -U flash:w:key.hex

sudoflash: key.hex
	sudo avrdude -c usbtiny -p attiny85 -U flash:w:key.hex
