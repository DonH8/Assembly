format PE console
entry start

include 'C:\Program Files\FASM\INCLUDE\WIN32A.INC' 

section '.data' data readable writeable
    my_str db 'Hello, this box has my name in it', 0
	my_strr db 'Hello, my name is Don Hoxha', 0

section '.text' code readable executable

start:
    ; Shfaqe nje messagebox me string hardcoded
    push    0
    push    my_str
    push    my_strr
	push 	0
    call    [MessageBoxA]

    ; Exit procesin
    push    0
    call    [ExitProcess]


section '.idata' import data readable
 
library kernel,'kernel32.dll',\
		user32, 'user32.dll'

import  kernel,\
        ExitProcess,'ExitProcess'
import  user32, \
        MessageBoxA, 'MessageBoxA'
