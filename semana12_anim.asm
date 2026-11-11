; ----------------------------------------------------
; Semana 12 - Laboratorio (Parte 2): Animación básica
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