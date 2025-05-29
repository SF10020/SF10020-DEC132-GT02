section .bss
    num1 resb 1        ; Variable para guardar el primer número ingresado por el usuario (8 bits)
    num2 resb 1        ; Variable para guardar el segundo número ingresado por el usuario (8 bits)
    buffer resb 8      ; Buffer temporal para leer los números desde la entrada estándar
    resultado resw 1   ; Variable para guardar el resultado de la multiplicación (hasta 16 bits por si hay overflow)
    outbuf resb 6      ; Buffer para convertir el resultado a texto ASCII (máximo 5 dígitos y un nulo)

section .data
    msg1 db "Ingrese el primer numero a multiplicar:", 10 ; Mensaje para pedir el primer número, con salto de línea
    len_msg1 equ $ - msg1

    msg2 db "Ingrese el segundo numero a multiplicar:", 10 ; Mensaje para pedir el segundo número, con salto de línea
    len_msg2 equ $ - msg2

    msgr db "Resultado: ", 10      ; Mensaje para mostrar antes del resultado, con salto de línea
    len_msgr equ $ - msgr

    salto db 10                    ; Salto de línea final para que el prompt no quede junto al resultado

section .text
    global _start

_start:
    ; =======================
    ; Solicito el primer número al usuario y lo leo como texto
    mov eax, 4                  ; syscall write (imprimir)
    mov ebx, 1                  ; descriptor de archivo: stdout
    mov ecx, msg1               ; puntero al mensaje 1
    mov edx, len_msg1           ; longitud del mensaje 1
    int 0x80

    mov eax, 3                  ; syscall read (leer)
    mov ebx, 0                  ; descriptor de archivo: stdin
    mov ecx, buffer             ; donde se guarda lo leído
    mov edx, 8                  ; máximo 8 caracteres
    int 0x80

    ; =======================
    ; Convierto el texto leído a número (entero positivo)
    mov esi, buffer             ; inicio del buffer de entrada
    xor eax, eax                ; limpio EAX (acumulará el número)
    xor ebx, ebx                ; limpio EBX (lo uso para cada dígito temporalmente)

.convert_num1:
    mov bl, byte [esi]          ; cargo el siguiente carácter en BL
    cmp bl, 10                  ; ¿es salto de línea?
    je .num1_done
    cmp bl, 13                  ; ¿es carriage return?
    je .num1_done
    cmp bl, 0                   ; ¿fin de cadena?
    je .num1_done
    sub bl, '0'                 ; convierto de ASCII a valor numérico
    cmp bl, 9                   ; verifico si es un dígito válido (0–9)
    ja .num1_done
    imul eax, eax, 10           ; multiplico acumulador por 10 (preparo para siguiente dígito)
    add eax, ebx                ; sumo el dígito actual
    inc esi                     ; avanzo al siguiente carácter
    jmp .convert_num1           ; repito el proceso para todos los caracteres

.num1_done:
    mov [num1], al              ; guardo el resultado final (solo 8 bits) en num1

    ; =======================
    ; Solicito el segundo número al usuario y lo leo como texto
    mov eax, 4                  ; syscall write (imprimir)
    mov ebx, 1                  ; stdout
    mov ecx, msg2               ; mensaje 2
    mov edx, len_msg2           ; longitud mensaje 2
    int 0x80

    mov eax, 3                  ; syscall read
    mov ebx, 0                  ; stdin
    mov ecx, buffer             ; buffer temporal
    mov edx, 8                  ; máximo 8 caracteres
    int 0x80

    ; =======================
    ; Convierto el texto leído a número (entero positivo)
    mov esi, buffer             ; inicio del buffer
    xor eax, eax                ; limpio acumulador
    xor ebx, ebx

.convert_num2:
    mov bl, byte [esi]          ; siguiente carácter en BL
    cmp bl, 10                  ; salto de línea
    je .num2_done
    cmp bl, 13                  ; carriage return
    je .num2_done
    cmp bl, 0                   ; fin de cadena
    je .num2_done
    sub bl, '0'                 ; de ASCII a número
    cmp bl, 9                   ; si no es dígito, termina
    ja .num2_done
    imul eax, eax, 10
    add eax, ebx
    inc esi
    jmp .convert_num2

.num2_done:
    mov [num2], al              ; guardo el resultado (8 bits)

    ; =======================
    ; Multiplicación usando SOLO registros de 8 bits como pide el ejercicio
    mov al, [num1]              ; cargo el primer número en AL
    mov bl, [num2]              ; cargo el segundo número en BL
    mul bl                      ; AL * BL, resultado de 16 bits en AX (sin signo)
    mov [resultado], ax         ; guardo el resultado (puede ser de más de 1 byte)

    ; =======================
    ; Convierto el resultado a texto para imprimirlo (soporta hasta 5 dígitos)
    mov ax, [resultado]         ; cargo el resultado en AX
    mov edi, outbuf + 5         ; apunto al final del buffer
    mov byte [edi], 0           ; opcional: terminador nulo (no usado realmente aquí)

.conv_result:
    xor dx, dx                  ; limpio DX para la división
    mov bx, 10                  ; divisor 10 para obtener cada dígito
    div bx                      ; AX / 10; cociente en AX, residuo en DX
    add dl, '0'                 ; convierto dígito a ASCII
    dec edi                     ; retrocedo puntero en buffer
    mov [edi], dl               ; guardo el dígito en el buffer
    test ax, ax                 ; ¿ya terminamos? (AX == 0)
    jnz .conv_result            ; si no, seguimos con el siguiente dígito

    ; =======================
    ; Imprimo el mensaje "Resultado: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msgr
    mov edx, len_msgr
    int 0x80

    ; Imprimo el resultado (empezando desde el primer dígito)
    mov eax, 4
    mov ebx, 1
    mov ecx, edi                ; puntero al primer carácter del resultado
    mov edx, outbuf + 5
    sub edx, edi                ; longitud de la cadena numérica
    int 0x80

    ; Imprimo un salto de línea final para no mezclar con el prompt
    mov eax, 4
    mov ebx, 1
    mov ecx, salto
    mov edx, 1
    int 0x80

    ; =======================
    ; Salida del programa
    mov eax, 1                  ; syscall exit
    xor ebx, ebx                ; código de salida 0
    int 0x80
