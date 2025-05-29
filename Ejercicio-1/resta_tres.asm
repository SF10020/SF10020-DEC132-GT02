section .bss
    num1 resw 1            ; Variable para almacenar el primer número ingresado
    num2 resw 1            ; Variable para el segundo número
    num3 resw 1            ; Variable para el tercer número
    resultado resw 1       ; Variable donde se guardará el resultado final
    buffer resb 16         ; Buffer temporal para leer los datos desde teclado
    outbuf resb 16         ; Buffer para convertir el resultado a texto y mostrarlo

section .data
    msg1 db "Ingrese el primer numero: ", 0
    msg2 db "Ingrese el segundo numero: ", 0
    msg3 db "Ingrese el tercer numero: ", 0
    msgr db "Resultado: ", 0

section .text
    global _start

; Programa principal: aquí se pide al usuario los tres números,
; se realiza la resta y se muestra el resultado final.
_start:
    ; Solicito el primer número al usuario
    mov eax, 4              ; syscall write
    mov ebx, 1              ; descriptor STDOUT
    mov ecx, msg1
    mov edx, 25             ; longitud del mensaje
    int 0x80

    call leer_numero
    mov [num1], ax          ; Guardo el primer número en memoria

    ; Solicito el segundo número
    mov eax, 4
    mov ebx, 1
    mov ecx, msg2
    mov edx, 26
    int 0x80

    call leer_numero
    mov [num2], ax          ; Guardo el segundo número

    ; Solicito el tercer número
    mov eax, 4
    mov ebx, 1
    mov ecx, msg3
    mov edx, 25
    int 0x80

    call leer_numero
    mov [num3], ax          ; Guardo el tercer número

    ; Realizo la resta utilizando únicamente registros de 16 bits (por requisito)
    mov ax, [num1]
    sub ax, [num2]
    sub ax, [num3]
    mov [resultado], ax     ; Guardo el resultado en memoria

    ; Muestro en pantalla el texto "Resultado: "
    mov eax, 4
    mov ebx, 1
    mov ecx, msgr
    mov edx, 11
    int 0x80

    ; Imprimo el resultado en pantalla
    mov ax, [resultado]
    call imprimir_numero

    ; Termino el programa correctamente
    mov eax, 1
    xor ebx, ebx
    int 0x80

; Rutina para leer un número desde teclado y regresarlo en AX
leer_numero:
    mov eax, 3              ; syscall read
    mov ebx, 0              ; descriptor STDIN
    mov ecx, buffer         ; buffer para leer datos
    mov edx, 16             ; leo hasta 16 caracteres
    int 0x80

    ; Convierto la cadena ASCII a número entero (soporta negativos)
    mov esi, buffer
    xor ax, ax              ; limpio AX para almacenar el número
    xor bx, bx              ; BX me servirá para saber si es negativo

    mov cl, byte [esi]      ; verifico si el primer carácter es '-'
    cmp cl, '-'
    jne .leer_digitos
    inc esi                 ; si es negativo, avanzo el puntero
    mov bl, 1               ; marco como número negativo

.leer_digitos:
    xor cx, cx
.next_digit:
    mov cl, byte [esi]      ; leo siguiente carácter
    cmp cl, 10              ; ¿es salto de línea?
    je .hecho
    cmp cl, 13              ; ¿carriage return?
    je .hecho
    cmp cl, 0               ; ¿fin de cadena?
    je .hecho
    cmp cl, 32              ; ¿espacio?
    je .hecho
    sub cl, '0'             ; convierto ASCII a valor numérico
    cmp cl, 9
    ja .hecho               ; si no es número, termino
    imul ax, ax, 10         ; ax = ax * 10
    add ax, cx              ; sumo el dígito a ax
    inc esi                 ; avanzo el puntero
    jmp .next_digit

.hecho:
    cmp bl, 1
    jne .fin
    neg ax                  ; si era negativo, cambio el signo
.fin:
    ret

; Rutina para imprimir el valor de AX como número decimal (con signo)
imprimir_numero:
    mov bx, 10
    mov esi, outbuf+15      ; inicio desde el final del buffer
    mov byte [esi], 10      ; agrego salto de línea al final
    dec esi

    cmp ax, 0
    jge .positivo
    neg ax
    mov dl, '-'
    mov [esi], dl
    dec esi                 ; guardo el signo si es negativo

.positivo:
    cmp ax, 0
    jne .loop
    mov byte [esi], '0'     ; si es cero, imprimo '0'
    dec esi
    jmp .print

.loop:
    xor dx, dx
    div bx                  ; divido ax entre 10, dx = resto
    add dl, '0'
    mov [esi], dl
    dec esi
    cmp ax, 0
    jne .loop

.print:
    inc esi
    mov eax, 4              ; syscall write
    mov ebx, 1
    mov ecx, esi
    mov edx, outbuf+16
    sub edx, esi            ; calculo longitud de la cadena
    int 0x80
    ret
