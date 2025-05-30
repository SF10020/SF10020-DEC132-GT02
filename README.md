Portafolio de quinta actividad desarrollado en lenguaje ensamblador x86 - 32 bits (Linux)
Este repositorio contiene los ejercicios de la quinta actividad evaluada elaborados en lenguaje ensamblador x86 para arquitectura de 32 bits en Linux (WSL/Ubuntu)


1. Resta de tres enteros (16 bits)
Descripción: Programa que permite al usuario ingresar tres números enteros y realiza la resta entre ellos, usando únicamente registros de 16 bits.
La entrada y salida se realizan por consola utilizando llamadas al sistema Linux (int 0x80).

Ingreso: El usuario introduce los tres valores a restar.
Procesamiento: La operación se realiza con registros de 16 bits (ax, bx, cx, etc.).
Salida: El resultado de la resta se muestra por pantalla.

Compilación y ejecución
nasm -f elf32 resta_tres.asm -o resta_tres.o
ld -m elf_i386 resta_tres.o -o resta_tres
./resta_tres


2. Multiplicación de dos enteros (8 bits)
Descripción: Este programa solicita al usuario ingresar dos números enteros, realiza la multiplicación usando exclusivamente registros de 8 bits, y muestra el resultado.

Ingreso: El usuario introduce los dos factores a multiplicar.
Procesamiento: La multiplicación se realiza usando los registros de 8 bits (al, bl) y la instrucción mul (o imul si es con signo).
Salida: El producto se muestra en la consola.

Compilación y ejecución
nasm -f elf32 multiplicacion_8bits.asm -o multiplicacion_8bits.o
ld -m elf_i386 multiplicacion_8bits.o -o multiplicacion_8bits
./multiplicacion_8bits


3. División de dos enteros (32 bits)
Descripción:Permite ingresar dos números enteros, realiza la división usando registros de 32 bits y muestra tanto el cociente como el residuo.

Ingreso: El usuario ingresa numerador y denominador.
Procesamiento: Se emplean registros de 32 bits (eax, ecx, edx) y la instrucción idiv para la división con signo.
Salida: El cociente y el residuo aparecen en pantalla, cada uno con su respectiva etiqueta.

Compilación y ejecución
nasm -f elf32 division_32bits.asm -o division_32bits.o
ld -m elf_i386 division_32bits.o -o division_32bits
./division_32bits

Autor
Carlos Manuel Solís Flores - SF10020
Ingeniería en Desarrollo de Software
Diseño y estructura de computadores GT02
