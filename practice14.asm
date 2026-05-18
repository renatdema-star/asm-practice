section .data
    msg1    db "1) ", 0
    msg2    db 10, "2) ", 0
    msg3    db 10, "3) MEDIAN: ", 0
    nl      db 10, 0
    space   db " ", 0

section .bss
    in_buf   resb 8192
    out_buf  resb 64
    arr      resd 100
    n        resd 1
    var_i    resd 1
    var_j    resd 1
    var_min  resd 1

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

    ; loops
    mov ecx, 0
.parse_loop:
    cmp ecx, [n]
    jae .parse_done
    push ecx
    call get_next_int
    pop ecx
    ; memory
    mov [arr + ecx*4], eax
    inc ecx
    jmp .parse_loop
.parse_done:

    ; I/O
    mov ecx, msg1
    call print_str
    mov esi, arr
    mov ecx, [n]
    call print_arr

    ; logic, loops, math
    mov dword [var_i], 0
.sort_i_loop:
    mov eax, [n]
    dec eax
    cmp [var_i], eax
    jge .sort_done
    
    mov eax, [var_i]
    mov [var_min], eax
    
    mov eax, [var_i]
    inc eax
    mov [var_j], eax
.sort_j_loop:
    mov eax, [n]
    cmp [var_j], eax
    jge .sort_j_done
    
    ; memory, logic
    mov ebx, [var_j]
    mov ecx, [var_min]
    mov eax, [arr + ebx*4]
    mov edx, [arr + ecx*4]
    cmp eax, edx
    jge .no_new_min
    mov [var_min], ebx
.no_new_min:
    inc dword [var_j]
    jmp .sort_j_loop
.sort_j_done:
    
    ; memory
    mov eax, [var_i]
    mov ebx, [var_min]
    mov ecx, [arr + eax*4]
    mov edx, [arr + ebx*4]
    mov [arr + eax*4], edx
    mov [arr + ebx*4], ecx
    
    inc dword [var_i]
    jmp .sort_i_loop
.sort_done:

    ; I/O
    mov ecx, msg2
    call print_str
    mov esi, arr
    mov ecx, [n]
    call print_arr

    ; I/O
    mov ecx, msg3
    call print_str

    ; math, logic, memory
    mov eax, [n]
    dec eax
    shr eax, 1
    mov eax, [arr + eax*4]
    call print_num
    
    mov ecx, nl
    call print_str

.exit:
    ; I/O
    mov eax, 1
    mov ebx, 0
    int 0x80

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

print_arr:
    ; I/O, loops
    push eax
    push ebx
    push ecx
    push edx
    push esi
    
    test ecx, ecx
    jz .arr_done
    
.arr_loop:
    push ecx
    mov eax, [esi]
    call print_num
    pop ecx
    
    cmp ecx, 1
    je .skip_space
    push ecx
    mov ecx, space
    call print_str
    pop ecx
.skip_space:
    add esi, 4
    dec ecx
    jnz .arr_loop
.arr_done:
    pop esi
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
