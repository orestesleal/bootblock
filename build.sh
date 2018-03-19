#!/bin/sh
# 2018-03-17 - first build file
# Probably we will need a makefile in the future (who knows?)

# Build the object file based on the assembler file
# one.o is not relocated (yet) in this step, memory
# references start from 0
as one.S -o one.o

# set the starting address where the code should start (in real mode)
# and output an elf file in this step 
# NOTE: in gnu-as the order of the cli parameters is irrelevant 
ld -Ttext 0x7C00 one.o -o one.elf


# About the last "-Ttext 0x7c00": that makes the linker to
# relocate the code to start at 0x7c00

# example disassembly with objdump -D one.elf

# one.elf:     file format elf64-x86-64
# Disassembly of section .text:
# 0000000000007c00 <_start>:
#    7c00:       b8                      .byte 0xb8
#    7c01:       04 00                   add    $0x0,%al

# NOTE: is generating 16 bit code but the .elf file is
# a 64 bit elf, objcopy will remove that (next)

# remove elf headers, etc, we want a raw binary file
# that the real mode cpu can actually execute  straigh from 
# the bios call into the copied bootsector in memory (512-bytes)
objcopy -O binary one.elf one.bin

# one.bin should be copied to the first 512 bytes of a boot device
# NOTE: as of now is an invalid bootsector, doesn't have the signature
#       or code to to anything.

