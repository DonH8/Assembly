format PE console
entry start

include 'C:\Program Files\FASM\INCLUDE\WIN32A.INC'


section '.text' code readable executable


start:
call read_dec
mov edx,eax
call read_dec
add eax,edx
call print_eax

push 0
call [ExitProcess]
;=======[read_dec]=========================
read_dec:
    .read_dec_bytes_read = -4
    .read_dec_buffer     = -20

    .MAX_BYTES_TO_READ = 12

    push    ebp
    mov     ebp,esp

    ; Hapesire per locals:
    sub     esp,16+4

    push    edx
    push    ebx
    push    ecx
    push    edi
    
    lea     edi,[ebp + .read_dec_buffer]
    mov     ecx,.MAX_BYTES_TO_READ
    call    read_line

    ; Null terminator ne last byte:
    add     edi,.MAX_BYTES_TO_READ
    dec     edi
    mov     byte [edi],0

    ; Tentojme me convert buffer ne number
    push    0       ; Decimal.
    push    0

    lea     ecx,[ebp + .read_dec_buffer]
    push    ecx
    call    [strtoul]
    add     esp,4*3

    ; Result eshte ne eax.
    pop     edi
    pop     ecx
    pop     ebx
    pop     edx

    add     esp,16+4
    pop     ebp
    ret

; =====[print_eax]==========
; E printon eax ne console:

print_eax:
    pushad      ; Ruajme kejt regjistrat.

; Skip over the data:
    jmp     .print_eax_after_data
    .print_eax_fmt   db          "%d",10,13,0
.print_eax_after_data:

    push    eax     ; Argumenti.
    push    .print_eax_fmt
    call    [printf]
    add     esp,8
    popad           ; I rikthejme krejt regjistrat.
    ret



; ================[read_line]=====================
; Lexon string prej console dhe shton null terminator ne fund te stringut.
; ecx tregon madhesine e bufferit.


read_line:
    .bytes_read = -4
    .buff_size = -8
    .buff_left_size = -0ch
    .buff_ptr = -10h
    .dummy_dw = -14h

    push    ebp
    mov     ebp,esp
    
    ; Hapesire per locals:
    sub     esp,4*5

    pushad

    ; Ruan madhesine e destination buffer:
    mov     dword [ebp + .buff_size],ecx
    mov     dword [ebp + .buff_left_size],ecx

    ; Ruan adresen of destination buffer:
    mov     dword [ebp + .buff_ptr],edi

    ; E call Standard input handle:
    push    STD_INPUT_HANDLE  ; -10
    call    [GetStdHandle]
    mov     ebx,eax

    ; Nqs buff_size == 0,nuk lexojme fare bytes.
    ; We just consume one line from the console.
    cmp     dword [ebp + .buff_size],0
    jz      .discard_loop

    ; Lexon bytes nga console.
    ; Ndalet nqs njoni prej kushteve permbushet:
    ; Newline character eshte shfaqur.
    ; Bufferi eshte full.
.read_byte:
    ; Lexon bytes prej Standard input handle:
    push    0
    lea     ecx, [ebp + .bytes_read]
    push    ecx
    push    1       ; Read one byte.
    mov     ecx, dword [ebp + .buff_ptr]
    push    ecx
    push    ebx
    call    [ReadFile]

    mov     edi, dword [ebp + .buff_ptr]
    inc     dword [ebp + .buff_ptr]
    dec     dword [ebp + .buff_left_size]

    ; Shikon nese osht shfaqur newline character:
    ; Nqs po ndalet loopa:
    cmp     byte [edi],0dh
    jz      .exit_read_loop

    ; A ka arrit max kapaictet Bufferi:
    cmp     dword [ebp + .buff_left_size],0
    jnz     .read_byte
.exit_read_loop:

    ; E set null terminator:
    mov     byte [edi],0

    ; Discard loop:
    ; I diskardmi krejt characters deri sa te arrimi te 0ah character.
.discard_loop:
    push    0
    lea     ecx, [ebp + .bytes_read]
    push    ecx
    push    1       ; Lexon ni byte.
    lea     ecx, [ebp + .dummy_dw]
    push    ecx
    push    ebx
    call    [ReadFile]

    cmp     byte [ebp + .dummy_dw],0ah
    jnz     .discard_loop

    popad

    add     esp,4*5
    pop     ebp
    ret
    
section '.idata' import data readable
 
library kernel,'kernel32.dll',\
        msvcrt,'msvcrt.dll'
 
import  kernel,\
        ExitProcess,'ExitProcess',\
        GetStdHandle,'GetStdHandle',\
        ReadFile,'ReadFile'

import  msvcrt,\
        printf, 'printf',\
        strtoul, 'strtoul'