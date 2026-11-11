# Laboratorio 12 - Pintar y Animar un Carácter en Ensamblador

**Objetivo:** Desarrollar un programa en ensamblador de 64 bits para Windows que pinte un carácter en una posición específica usando colores, y posteriormente animarlo moviéndolo por la consola utilizando la API de Windows (`SetConsoleCursorPosition`, `SetConsoleTextAttribute`, `WriteConsoleA`, `Sleep`).

---

## 🎥 Enlace al Video (Demostración)
parte 1
https://drive.google.com/file/d/1kfqXeM4-FmxQviBph3-zZhEkFe4K1zsf/view?usp=sharing
parte 2
https://drive.google.com/file/d/1tzs-piwjQaJiAFiwejdeCQ0LJhv6Gz3T/view?usp=sharing

---

## ⚙️ Instrucciones de Compilación
Para ensamblar y enlazar ambos programas, se utilizó `uasm64` y `GoLink`. Los comandos a ejecutar en la consola son:

**Para la Parte 1:**
```cmd
uasm64 -win64 semana12.asm
GoLink.exe semana12.obj kernel32.dll /fo semana12.exe /console /entry main
```

**Para la Parte 2:**
```cmd
uasm64 -win64 semana12_anim.asm
GoLink.exe semana12_anim.obj kernel32.dll /fo semana12_anim.exe /console /entry main
```
---

## 📋 Parte 1: Pintar un carácter
Se logró pintar un carácter en una coordenada específica de la consola.
* **Coordenada COORD:** La API de Windows requiere que la posición `X` y `Y` se envíen empaquetadas en un solo registro de 32 bits. Los 16 bits superiores representan la fila (Y) y los 16 bits inferiores representan la columna (X). Por ejemplo, el valor `0x00050028` empaqueta la fila 5 (`0005`) y la columna 40 (`0028`).

### Código Original (Parte 1)
<details>
<summary>Haz clic para ver el código original</summary>

```assembly
; ------------------------------------------------------------
; Semana 12 - Laboratorio (Parte 1): Pintar un carácter en color (ORIGINAL)
; ------------------------------------------------------------
extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn FillConsoleOutputCharacterA: proc 
extrn FillConsoleOutputAttribute: proc  
extrn ExitProcess: proc

.data
    hConsole dq 0
    caracter db 'X', 0
    escritos dq 0
    coord dw 10, 5          ; COORD: X=10, Y=5

    ; Variables para la limpieza
    leidos dd 0
    homeCoord dd 0          ; X=0, Y=0 (Punto de inicio)
    numCeldas dd 2000       ; 80 columnas x 25 filas (tamaño estándar de consola)

.code
main proc
    ; Reservamos 38h en el stack para mantener la alineación de la pila
    sub rsp, 38h

    ; Obtener handle de la consola
    mov rcx, -11
    call GetStdHandle
    mov [hConsole], rax
    mov rbx, rax

    ; ========================================================
    ; LIMPIAR LA PANTALLA (Llenar con espacios en blanco)
    ; ========================================================
    mov rcx, rbx            ; 1° hConsole
    mov rdx, 20h            ; 2° Carácter espacio ' ' (0x20)
    mov r8d, [numCeldas]    ; 3° Cuántas celdas limpiar
    mov r9d, [homeCoord]    ; 4° Coordenada de inicio (0,0)
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax ; 5° Puntero a caracteres escritos
    call FillConsoleOutputCharacterA

    ; (Opcional) Limpiar los atributos/colores viejos de la pantalla a negro por defecto (0x07)
    mov rcx, rbx
    mov rdx, 07h            ; Atributo por defecto (texto blanco, fondo negro)
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputAttribute

    ; ========================================================
    ; Mover el cursor a (10, 5)
    mov rcx, rbx
    mov rdx, 0x0005000A     ; X=10, Y=5
    call SetConsoleCursorPosition

    ; Cambiar color: fondo azul, texto amarillo
    mov rcx, rbx
    mov rdx, 0x1E
    call SetConsoleTextAttribute

    ; Escribir el carácter 'X'
    mov rcx, rbx
    lea rdx, caracter
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; Terminar
    xor ecx, ecx
    call ExitProcess
main endp
end
```
</details>

### Código Modificado (Checklist CL-3)
Se modificó la posición y el color usando `0x00050028` para la coordenada y `0x41` para el atributo de texto.
<details>
<summary>Haz clic para ver el código modificado</summary>

```assembly
; ------------------------------------------------------------
; Semana 12 - Laboratorio (Parte 1): Pintar un carácter en color (MODIFICADO)
; ------------------------------------------------------------
extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn FillConsoleOutputCharacterA: proc 
extrn FillConsoleOutputAttribute: proc  
extrn ExitProcess: proc

.data
    hConsole dq 0
    ;/////////////////////////////////////////////////////////////////////////////////////////////
    caracter db 'X', 0
    escritos dq 0
    coord dw 10, 5          ; COORD: X=10, Y=5

    ; Variables para la limpieza
    leidos dd 0
    homeCoord dd 0          ; X=0, Y=0 (Punto de inicio)
    numCeldas dd 2000       ; 80 columnas x 25 filas (tamaño estándar de consola)

.code
main proc
    ; Reservamos 38h en el stack para mantener la alineación de la pila
    sub rsp, 38h

    ; Obtener handle de la consola
    mov rcx, -11
    call GetStdHandle
    mov [hConsole], rax
    mov rbx, rax

    ; ========================================================
    ; LIMPIAR LA PANTALLA (Llenar con espacios en blanco)
    ; ========================================================
    mov rcx, rbx            ; 1° hConsole
    mov rdx, 20h            ; 2° Carácter espacio ' ' (0x20)
    mov r8d, [numCeldas]    ; 3° Cuántas celdas limpiar
    mov r9d, [homeCoord]    ; 4° Coordenada de inicio (0,0)
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax ; 5° Puntero a caracteres escritos
    call FillConsoleOutputCharacterA

    ; (Opcional) Limpiar los atributos/colores viejos de la pantalla a negro por defecto (0x07)
    mov rcx, rbx
    mov rdx, 07h            ; Atributo por defecto (texto blanco, fondo negro)
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputAttribute

    ; ========================================================
    ; Mover el cursor a (10, 5)
    mov rcx, rbx
    ;/////////////////////////////////////////////////////////////////////////////////////////////
    mov rdx, 0x00050028   ; X=10, Y=5
    call SetConsoleCursorPosition

    ; Cambiar color: fondo azul, texto amarillo
    mov rcx, rbx
    ;/////////////////////////////////////////////////////////////////////////////////////////////
    mov rdx, 0x41
    call SetConsoleTextAttribute

    ; Escribir el carácter 'X'
    mov rcx, rbx
    lea rdx, caracter
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; Terminar
    xor ecx, ecx
    call ExitProcess
main endp
end 
```
</details>

**Captura de pantalla Parte 1:**
![Parte 1](captura_parte1.png) *(Nota: Asegúrate de subir una imagen con este nombre a tu repositorio)*

---

## 🏃‍♂️ Parte 2: Animación Básica
El objetivo fue desplazar el carácter en la consola limpiando su rastro y usando retardos (`Sleep`).

### Código Original (Parte 2)
<details>
<summary>Haz clic para ver el código original</summary>

```assembly
; ----------------------------------------------------
; Semana 12 - Laboratorio (Parte 2): Animación básica (ORIGINAL)
; ----------------------------------------------------
extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn Sleep: proc
extrn FillConsoleOutputCharacterA: proc
extrn FillConsoleOutputAttribute: proc  
extrn ExitProcess: proc

.data
    hConsole dq 0
    caracter db 'X', 0
    espacio db ' ', 0
    escritos dq 0
    pos_x dw 0              
    pos_y dw 10             
    leidos dd 0
    homeCoord dd 0          
    numCeldas dd 2000       

.code
main proc
    sub rsp, 38h
    mov rcx, -11
    call GetStdHandle
    mov [hConsole], rax
    mov rbx, rax

    mov rcx, rbx
    mov rdx, 20h
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputCharacterA

    mov rcx, rbx
    mov rdx, 07h
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputAttribute

    mov rcx, rbx
    mov rdx, 0x0A
    call SetConsoleTextAttribute

    mov word ptr [pos_x], 0

anim_loop:
    cmp word ptr [pos_x], 0
    je pintar_caracter      

    mov rcx, rbx
    movzx rdx, word ptr [pos_x]
    dec rdx                 
    movzx rax, word ptr [pos_y]
    shl rax, 16
    or rdx, rax
    call SetConsoleCursorPosition

    mov rcx, rbx
    lea rdx, espacio
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

pintar_caracter:
    mov rcx, rbx
    movzx rdx, word ptr [pos_x]
    movzx rax, word ptr [pos_y]
    shl rax, 16
    or rdx, rax
    call SetConsoleCursorPosition

    mov rcx, rbx
    lea rdx, caracter
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    mov rcx, 50             
    call Sleep

    inc word ptr [pos_x]    
    cmp word ptr [pos_x], 70
    jl anim_loop            

    xor ecx, ecx
    call ExitProcess
main endp
end
```
</details>

### Código Modificado (Checklist CL-7)
Se modificó el carácter por `'O'`, la velocidad a `150ms`, y la dirección para que camine **de derecha a izquierda**.
<details>
<summary>Haz clic para ver el código modificado</summary>

```assembly
; ----------------------------------------------------
; Semana 12 - Laboratorio (Parte 2): Animación básica (MODIFICADO)
; ----------------------------------------------------
extrn GetStdHandle: proc
extrn SetConsoleCursorPosition: proc
extrn SetConsoleTextAttribute: proc
extrn WriteConsoleA: proc
extrn Sleep: proc
extrn FillConsoleOutputCharacterA: proc ; <-- Agregado para evitar errores
extrn FillConsoleOutputAttribute: proc  ; <-- Agregado para evitar errores
extrn ExitProcess: proc

.data
    hConsole dq 0
    ; ///////////////////////////////////////////////////////////////////   1
    caracter db 'O', 0
    espacio db ' ', 0
    escritos dq 0
    pos_x dw 0              ; Posición inicial en X (Columna 0)
    pos_y dw 10             ; Fila Y (Fila 10)
    
    ; Variables para la limpieza
    leidos dd 0
    homeCoord dd 0          
    numCeldas dd 2000       

.code
main proc
    ; Ajustamos a 38h para alinear la pila correctamente
    sub rsp, 38h

    ; Obtener handle de la consola
    mov rcx, -11
    call GetStdHandle
    mov [hConsole], rax
    mov rbx, rax

    ; ========================================================
    ; LIMPIAR LA PANTALLA
    ; ========================================================
    mov rcx, rbx
    mov rdx, 20h
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputCharacterA

    mov rcx, rbx
    mov rdx, 07h
    mov r8d, [numCeldas]
    mov r9d, [homeCoord]
    lea rax, leidos
    mov qword ptr [rsp + 20h], rax
    call FillConsoleOutputAttribute

    ; ========================================================
    ; Color: fondo negro, texto verde
    mov rcx, rbx
    mov rdx, 0x0A
    call SetConsoleTextAttribute

    ; Inicializar X en 0
    ; ///////////////////////////////////////////////////////////////////    3
    mov word ptr [pos_x], 70

anim_loop:
; ///////////////////////////////////////////////////////////////////        3
    cmp word ptr [pos_x], 70
    je pintar_caracter      ; Si es la primera posición, no borrar atrás

    ; Borrar la posición anterior (escribir espacio)
    mov rcx, rbx
    movzx rdx, word ptr [pos_x]
    ; ///////////////////////////////////////////////////////////////////     4
    inc rdx                 ; Resta 1 a X para borrar el rastro anterior
    movzx rax, word ptr [pos_y]
    shl rax, 16
    or rdx, rax
    call SetConsoleCursorPosition

    mov rcx, rbx
    lea rdx, espacio
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

pintar_caracter:
    ; Mover el cursor a la nueva posición
    mov rcx, rbx
    movzx rdx, word ptr [pos_x]
    movzx rax, word ptr [pos_y]
    shl rax, 16
    or rdx, rax
    call SetConsoleCursorPosition

    ; Escribir el carácter 'X'
    mov rcx, rbx
    lea rdx, caracter
    mov r8, 1
    lea r9, escritos
    mov qword ptr [rsp + 20h], 0
    call WriteConsoleA

    ; Retardo de 50 ms (Velocidad de la animación)
    ; ///////////////////////////////////////////////////////////////////    2
    mov rcx, 150             
    call Sleep

    ; Incrementar X y evaluar bucle
    ; ///////////////////////////////////////////////////////////////////    5
    dec word ptr [pos_x]    ; Mueve la X un espacio a la derecha
    ; ///////////////////////////////////////////////////////////////////    6
    cmp word ptr [pos_x], 0
    jge anim_loop            ; Repite hasta llegar a la columna 70

    ; Terminar
    xor ecx, ecx
    call ExitProcess
main endp
end
```
