; <|< x86 bootsector >|>
;
; [1] https://web.archive.org/web/20120425004936/http://www.acpica.org:80/download/specsbbs101.pdf
; [2] http://www.ablmcc.edu.hk/~scy/CIT/8086_bios_and_dos_interrupts.htm

; A (aparently) full spec of a BIOS behavior and features is found on [1]

ORG 0x7c00             ; the will load us into this address, so we tell 
                       ; the assembler to begin assembling instructions
                       ; beginning with this address

SECTION .text

; first steps
; ===========
; setup a real mode stack - we are in the beginning of a
; 64k segment in selector 0, that is the space we have 
; to make a local stack (not in other segment) 
; possibly close to the very end of the segment since
; the stack grows into lower memory addresses

  mov ax, 0x8000        ; setup the stack segment
  mov ss, ax         
  mov sp, 0x0ff0        ; & the stack ptr


  ; use the video services provided by the BIOS [1] to display a message
  mov al, 1
  mov bh, 0
  mov bl, 11100000b     ; color attribute, high nibble=bg, low-nibble=text
  mov cx, buffer_len    ; length of buffer with text
  mov dl, 10
  mov dh, 7
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

buffer:  db 'x86 bootsector',0       ; display at boot
buffer_len: equ $-buffer           ; length of 'buffer'

padding: times 110-($-$$) db 0x0   ; ugh, nasty syntax

db 0x55,0xAA               ; BIOS signature
