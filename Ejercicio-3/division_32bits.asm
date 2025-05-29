section .bss
    num1 resd 1        ; Aquí guardo el numerador como un entero de 32 bits (lo ingresa el usuario)
    num2 resd 1        ; Aquí guardo el denominador como un entero de 32 bits
    buffer resb 16     ; Buffer donde leo el texto que escribe el usuario
    resultado resd 1   ; Aquí guardo el cociente después de dividir (también 32 bits)
    resto resd 1       ; Aquí guardo el residuo de la división (32 bits)
    outbuf resb 12     ; Buffer para convertir cualquier número a ASCII (hasta 10 dígitos + signo)

section .data
    msg1 db "Ingrese el numerador: ", 10      ; Mensaje para pedir el primer número (con salto de línea)
    len_msg1 equ $ - msg1

    msg2 db "Ingrese el denominador: ", 10    ; Mensaje para pedir el segundo número (con salto de línea)
    len_msg2 equ $ - msg2

    msgr db "Cociente: ", 10                  ; Mensaje que imprime antes del resultado
    len_msgr equ $ - msgr

    msgr2 db "Residuo: ", 10                  ; Mensaje antes de mostrar el residuo
    len_msgr2 equ $ - msgr2

    salto db 10                               ; Salto de línea para finalizar la impresión

section .text
    global _start

_start:
    ; ===========================
    ; Leo el numerador que ingresa el usuario
    mov eax, 4
    mov ebx, 1
    mov ecx, msg1
    mov edx, len_msg1
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; Convierto el texto leído a número entero (soporta signo)
    call ascii_a_entero
    mov [num1], eax      ; Guardo el número convertido en num1

    ; ===========================
    ; Leo el denominador que ingresa el usuario
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, len_msg2
    int 0x80

    mov eax, 3
    mov ebx, 0
    mov ecx, buffer
    mov edx, 16
    int 0x80

    ; Convierto el texto leído a número entero
    call ascii_a_entero
    mov [num2], eax      ; Guardo el denominador en num2

    ; ===========================
    ; Realizo la división usando registros de 32 bits como pide el enunciado
    mov eax, [num1]      ; El numerador lo pongo en EAX
    cdq                  ; Extiendo el signo de EAX en EDX (por si es negativo)
    mov ecx, [num2]      ; El denominador va en ECX
    idiv ecx             ; Divido: EAX/ECX → cociente en EAX, residuo en EDX
    mov [resultado], eax ; Guardo el cociente
    mov [resto], edx     ; Guardo el residuo

    ; ===========================
    ; Imprimo el cociente
    mov eax, 4
    mov ebx, 1
    mov ecx, msgr
    mov edx, len_msgr
    int 0x80

    mov eax, [resultado]          ; Paso el resultado a EAX para conversión a texto
    mov edi, outbuf + 11          ; Apunto al final del buffer de salida
    mov byte [edi], 0             ; Por seguridad, pongo un terminador nulo (no necesario para imprimir, pero buena práctica)

    call entero_a_ascii           ; Convierto el resultado a ASCII

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, outbuf + 12
    sub edx, edi
    int 0x80

    ; Salto de línea para separar los resultados
    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 0x80

    ; ===========================
    ; Imprimo el residuo
    mov eax, 4
    mov ebx, 1
    mov ecx, msgr2
    mov edx, len_msgr2
    int 0x80

    mov eax, [resto]             ; Paso el residuo a EAX para conversión a texto
    mov edi, outbuf + 11
    mov byte [edi], 0

    call entero_a_ascii          ; Convierto el residuo a ASCII

    mov eax, 4
    mov ebx, 1
    mov ecx, edi
    mov edx, outbuf + 12
    sub edx, edi
    int 0x80

    ; Salto de línea final
    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 0x80

    ; ===========================
    ; Salgo del programa
    mov eax, 1
    xor ebx, ebx
    int 0x80

; -----------------------------------------------------
; Esta rutina convierte un texto en buffer a un entero en EAX
; La uso cada vez que leo un número del usuario (soporta negativos)
ascii_a_entero:
    mov esi, buffer
    xor eax, eax
    xor ebx, ebx
    mov ecx, 0              ; Este ECX lo uso como "flag" para saber si es negativo

    mov bl, [esi]
    cmp bl, '-'
    jne .conv_loop
    inc esi                 ; Si el primer carácter es '-', me muevo al siguiente y activo el flag
    mov ecx, 1

.conv_loop:
    mov bl, [esi]
    cmp bl, 10
    je .fin
    cmp bl, 13
    je .fin
    cmp bl, 0
    je .fin
    cmp bl, 32
    je .fin
    sub bl, '0'
    cmp bl, 9
    ja .fin
    imul eax, eax, 10       ; Multiplico el acumulador por 10
    add eax, ebx            ; Sumo el siguiente dígito
    inc esi
    jmp .conv_loop

.fin:
    cmp ecx, 1
    jne .retornar
    neg eax                 ; Si era negativo, le cambio el signo al final
.retornar:
    ret

; -----------------------------------------------------
; Esta rutina convierte el entero de EAX a ASCII en el buffer de outbuf
; Sirve para imprimir cualquier número en pantalla
entero_a_ascii:
    push eax
    push edx
    push ebx

    mov ecx, edi

    cmp eax, 0
    jge .conv_num
    neg eax
    dec edi
    mov byte [edi], '-'     ; Si el número era negativo, agrego el signo

.conv_num:
    mov ebx, 10

.conv_loop:
    xor edx, edx
    div ebx
    add dl, '0'
    dec edi
    mov [edi], dl
    test eax, eax
    jnz .conv_loop

    cmp byte [edi-1], '-'
    jne .done
    dec edi

.done:
    pop ebx
    pop edx
    pop eax
    ret
