section .data
    msg1    db "1) ", 0
    msg2    db 10, "2) ", 0
    msg_yes db 10, "3) PALINDROME: YES", 10, 0
    msg_no  db 10, "3) PALINDROME: NO", 10, 0
    space   db " ", 0

section .bss
    in_buf   resb 8192
    out_buf  resb 64
    arr_orig resd 200
    arr_rev  resd 200
    n        resd 1

section .text
    global _start

_start:
    mov eax, 3
    mov ebx, 0
    mov ecx, in_buf
    mov edx, 8192
    int 0x80

    mov esi, in_buf
    
    call get_next_int
    mov [n], eax

    mov ecx, 0
.parse_loop:
    cmp ecx, [n]
    jae .parse_done
    push ecx
    call get_next_int
    pop ecx
    mov [arr_orig + ecx*4], eax
    inc ecx
    jmp .parse_loop
.parse_done:

    mov ecx, [n]
    mov esi, arr_orig
    mov edi, arr_rev
    cld
    rep movsd

    mov ecx, [n]
    shr ecx, 1
    test ecx, ecx
    jz .reverse_done

    mov esi, arr_rev
    mov edi, arr_rev
    mov eax, [n]
    dec eax
    shl eax, 2
    add edi, eax

.reverse_loop:
    mov eax, [esi]
    mov ebx, [edi]
    mov [esi], ebx
    mov [edi], eax
    add esi, 4
    sub edi, 4
    dec ecx
    jnz .reverse_loop
.reverse_done:

    mov ecx, msg1
    call print_str
    
    mov esi, arr_orig
    mov ecx, [n]
    call print_arr

    mov ecx, msg2
    call print_str

    mov esi, arr_rev
    mov ecx, [n]
    call print_arr

    mov ecx, [n]
    mov esi, arr_orig
    mov edi, arr_rev
.compare_loop:
    mov eax, [esi]
    mov ebx, [edi]
    cmp eax, ebx
    jne .not_palindrome
    add esi, 4
    add edi, 4
    dec ecx
    jnz .compare_loop

    mov ecx, msg_yes
    call print_str
    jmp .exit

.not_palindrome:
    mov ecx, msg_no
    call print_str

.exit:
    mov eax, 1
    mov ebx, 0
    int 0x80

get_next_int:
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

