section .data
    msg1    db "1) ", 0
    msg2    db 10, "2) calls = ", 0
    nl      db 10, 0

section .bss
    in_buf   resb 8192
    out_buf  resb 64
    n        resd 1
    calls    resd 1

section .text
    global _start

_start:
    ; I/O
    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 8192
    int 0x80

    mov esi, in_buf
    
    ; parse
    call get_next_int
    mov [n], eax

    ; logic, memory
    mov dword [calls], 0
    mov eax, [n]
    call fact

    ; I/O
    push eax
    mov ecx, msg1
    call print_str
    pop eax
    call print_num

    mov ecx, msg2
    call print_str
    mov eax, [calls]
    call print_num
    
    mov ecx, nl
    call print_str

.exit:
    ; I/O
    mov eax, 1
    mov ebx, 0
    int 0x80

fact:
    ; memory
    inc dword [calls]
    
    ; prologue
    push ebp
    mov ebp, esp
    push ebx

    ; logic
    cmp eax, 0
    je .base_case
    cmp eax, 1
    je .base_case

    ; math
    mov ebx, eax
    dec eax
    call fact
    imul eax, ebx
    jmp .end

.base_case:
    mov eax, 1

.end:
    ; epilogue
    pop ebx
    mov esp, ebp
    pop ebp
    ret

get_next_int:
    ; parse, logic
    xor eax, eax
    xor ebx, ebx
    xor ecx, ecx
.skip_ws:
    mov bl, [esi]
    cmp bl, 0
    je .done
    cmp bl, '-'
    je .is_neg
    cmp bl, '0'
    jb .next_char
    cmp bl, '9'
    ja .next_char
    jmp .read_digits
.is_neg:
    mov ecx, 1
    inc esi
    jmp .read_digits
.next_char:
    inc esi
    jmp .skip_ws
.read_digits:
    ; math
    mov bl, [esi]
    cmp bl, '0'
    jb .finish
    cmp bl, '9'
    ja .finish
    imul eax, 10
    sub bl, '0'
    add eax, ebx
    inc esi
    jmp .read_digits
.finish:
    cmp ecx, 1
    jne .done
    neg eax
.done:
    ret

print_str:
    ; I/O, loops
    push eax
    push ebx
    push ecx
    push edx
    mov edx, 0
.len_loop:
    cmp byte [ecx + edx], 0
    je .len_done
    inc edx
    jmp .len_loop
.len_done:
    mov eax, 4
    mov ebx, 1
    int 0x80
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret

print_num:
    ; math, I/O, logic
    push eax
    push ebx
    push ecx
    push edx
    push edi
    
    mov edi, out_buf + 63
    mov byte [edi], 0
    mov ebx, 10
    
    test eax, eax
    jns .positive
    neg eax
    push 1
    jmp .check_zero
.positive:
    push 0
    
.check_zero:
    test eax, eax
    jnz .convert
    dec edi
    mov byte [edi], '0'
    jmp .print
    
.convert:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .convert
    
.print:
    pop eax
    test eax, eax
    jz .do_print
    dec edi
    mov byte [edi], '-'
.do_print:
    mov ecx, edi
    call print_str
    
    pop edi
    pop edx
    pop ecx
    pop ebx
    pop eax
    ret
