 ; <|< x86 bootsector >|>
 ;  generic x86 (intel, amd, or 8086 clones) bootblock
 ;
 ; [1] https://web.archive.org/web/20120425004936/http://www.acpica.org:80/download/specsbbs101.pdf
 ; [2] http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm
 ; [3] http://www.pcguide.com/ref/mbsys/bios/index.htm
 ;
 ;
 ;  NOTE: I'm going to try to make brief but important remarks
 ;        during the file and in this intro so we can follow
 ;        the flow of what should be happening, what is the
 ;        state at specific times of the execution of the bootblock,
 ;        etc but probably is going to be extensive
 ;
 ;  The BIOS launches us in real-adress mode (via INT 19h) with paging 
 ;  disabled (CR0[31] = 0), all other bits on CR0 are zero too
 ;  XXX: not complete accurate, it was like that on the i486 era
 ;  not now
 ;
 ;  State of all general purpose and other registers is undefined so
 ;  we don't rely on the content of those at the startup for anything
 ;
 ;  Maximum size of the linear address space in real-address mode
 ;  is 2^20 bytes (1MB) but since real-address mode use segments
 ;  each segment can be a maximum of 64 KBytes.
 ;
 ;  Real-address mode use a 'selector' to select a code segment
 ;  and Offset to select a displacement in that (64K) segment.
 ;  painful stuff from the 8086 era.
 ;  
 ;  > * More info on the Intel Manual Vol. 1 Section 3.3
 ;
 ;  A multiprocessor machine runs the Multiprocessor protocol (MP)
 ;  which select the bootstrap processor (BSP), which become the
 ;  active processor (the one available to execute code) for the
 ;  initialization. More information on the Intel manual Vol. 3A 
 ;  Chapter 9  (Processor Management and Initialization)
 ;  
 ;  Should an IDT (Interrupt Descriptor Table or Interrupt Vector
 ;  table) be at address 0 and was setup by the BIO? 
 ;  See IDM (Intel Developer Manual)  Vol. 3A Sec. 9.7
 ;
 ;  This is Gold:  https://en.wikipedia.org/wiki/BIOS#System_startup
 ;
 ;  So far the BIOS has dealt with a lot of platform specific stuff
 ;  in the machine. Upon copying of the 512 bytes from boot disk
 ;  to memory we must take care from there by:
 ;
 ;    - Setting up a GDT (for memory management)
 ;    - Load another piece of the initialization code (kernel?) since
 ;      512 bytes is not enough. This can be done using BIOS services
 ;      to read beyond the first 512 bytes of the booting disk. However,
 ;      this require that the bootsector is copied on a boot disk
 ;      and after that (contiguous) there can be another file (data)
 ;      copied that can act as the kernel. This can be a flat file
 ;      with no MBR or anything just a flat boot file since the BIOS
 ;      does't know anything about disk paritions, mbr or anything
 ;      so we are free to do it out way. This type of boot disk
 ;      can be created with dd and the bootsector copied into the
 ;      first 512 bytes, and another data (kernel) after those.
 ;      this file can be loaded on channel ATA0-master on bochs to test
 ;    - And some more platform specific procedures before enabling 
 ;      protected mode and jump to kernel initialization.
 ;
 ;  NOTE: All this should be close to accurate, if not is at leat
 ;  a starting point to begin reading, thinking, writing.
 ;
 ;  Review
 ;  ======
 ;  So on this stage we have the CPU state (initialized), on top we
 ;  have the BIOS, which already did a great deal of initialization
 ;  of registers, segments, selectors, the basic Interrupt Vector Table, etc.
 ;  device initialization, etc. so we must consider that the BIOS did a lot
 ;  of stuff for us since by default there is not an IDT in real-mode,
 ;  or anything setup just the CPU running code from a specific location
 ;  (the ROM code) in a specific address.
 ;  All this in real-address mode (16 bit) and after the BIOS gives control 
 ;  to us we need to follow the platform requirements to be able to get to
 ;  protected mode and take it from there (32 bit execution) which is
 ;  is described in IDM Vol 3A Sec 9.8
 ;
 ;  x86 memory addressing is also explained in a great deal in the book 
 ;  Understanding the Linux Kernel 3rd Ed -- Chapter 2: Memory Addressing
 ;
 ;


 ; A (aparently) full spec of a BIOS boot behavior and features is found on [1]

ORG 0x7c00             ; the BIOS will load us into this address, so we tell 
                       ; the assembler to begin assembling instructions
                       ; beginning with this address. As per the BIOS boot
                       ; specs [1] this bootsector is on a IPL device or an
                       ; Initial Program Load Device, it's the booting dev.
                       ; BIOS -> IPL -> bootsector
                       ;   |              |
                       ;   ----------------
                       ;   -> gives control
SECTION .text

; first steps
; ===========
; setup a real mode stack - we are in a 64k segment 
; in selector 0, with this space we have to make a 
; local stack (not in other segment) possibly close 
; to the very end of the segment since the stack 
; grows into lower memory addresses

  mov ax, 0x8000        ; setup the stack-segment
  mov ss, ax         
  mov sp, 0x0ff0        ; and the stack-pointer


  ; use the video services provided by the BIOS [2] to display a message
  mov al, 1
  mov bh, 0
  mov bl, 00101111b     ; color attribute, high nibble=bg, low-nibble=text
  mov cx, buffer_len    ; length of buffer with text
  mov dl, 0             ; column
  mov dh, 0             ; row
  push cs
  pop es
  mov bp, buffer
  mov ah, 0x13
  int 0x10
  jmp $                 ; infinite loop


; reservar 400 bytes para la seccion .text
; no se como reservar desde la seccion .data
; 512 bytes menos la cantidad de bytes usados en
; el programa ya que solo me permite hace una
; referencia hacia la seccion local. Pero esto
; hizo el truco para crear un binario de 512 bytes
; que es un bootsector con la firma al final.
buf: times 400-($-$$) db 0xff

SECTION .data

buffer:  db 'x86 bootsector',0     ; display at boot
buffer_len: equ $-buffer           ; length of 'buffer'

padding: times 110-($-$$) db 0x0   ; ugh, nasty syntax

db 0x55,0xAA                       ; BIOS signature
