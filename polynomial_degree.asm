global polynomial_degree
; rdi <- *y
; rsi <- n

section .text

; Przepisuje wartości z tablicy wejściowej na stos.
rewrite_array:
    movsxd rax, dword [rdi + r10 * 4]
    mov qword [rbx + r9], rax        ; przepisujemy wartość z tablicy na stos
    lea r9, [r9 + 8]
    mov rcx, r13                     ; tyle musimy wypełnić bloków
    dec rcx                          ; ale w 1 już jest liczba
    mov rax, -1
    cmp dword [rdi + r10 * 4], 0
    jl .loop                         ; liczba ujemna, więc wypełniamy 1
    xor rax, rax                     ; liczba nieujemna, więc wypełniamy 0
.loop:
    mov qword [rbx + r9], rax        ; powielamy bit znaku na starsze bity bignuma
    lea r9, [r9 + 8]
    loop .loop
    inc r10
    cmp r10, rsi
    jl rewrite_array
    ret

; Sprawdza, czy aktualna tablica jest wypełniona zerami lub ma wielkość 1.
check_array:
    xor r8, r8
.loop:
    cmp qword [rbx + r8], 0
    jne .check_one
    lea r8, [r8 + 8]
    cmp r8, r15
    jl .loop
    mov rax, rdx              ; jeśli tu jesteśmy to znaczy, że tablica to same zera
    sub rax, rsi              ; rax = (pocz. dł. tablicy) - (obecna dł. tablicy)
    dec rax                   ; zwracamy wynik pomniejszony o 1, bo tak
    jmp .finish
.check_one:                   ; sprawdza, czy tablica zawiera tylko jedną liczbę
    cmp rsi, 1                ; porównanie aktualnego rozmiaru tablicy z 1
    jne polynomial_degree.main
    mov rax, rdx              ; jeśli tu jesteśmy to znaczy, że tablica ma dł. 1
    sub rax, rsi              ; rax = (pocz. dł. tablicy) - (obecna dł. tablicy)
    jmp .finish
; Tutaj kończy się nasza funkcja, wszystkie rzeczy ze stosu grzecznie zdejmujemy.
.finish:
    mov rsp, rbp              ; przywracanie wskaźnika stosu
    pop rbx
    pop rbp
    pop r15
    pop r14
    pop r13
    pop r10
    ret

polynomial_degree:
    push r10
    push r13
    push r14
    push r15
    push rbp
    push rbx
    mov rdx, rsi              ; jakoś trzeba zapamiętać początkowe n (jako const)
    mov rbp, rsp              ; wskaźnik na stary rsp, potem łatwo przywrócić stos

    mov r13, rsi
    add r13, 127
    shr r13, 6                ; r13 = (n + 64 + 63) / 64 <- liczba bloków na bignuma
    mov rax, r13
    shl rax, 3
    mov r14, rax              ; r14 = r13 * 8            <- liczba bajtów na bignuma
    imul rax, rsi
    mov r15, rax              ; r15 = r14 * n            <- liczba bajtów na całą tablicę

    sub rsp, rax              ; rezerwowanie miejsca na całą tablicę - r15 bajtów
    mov rbx, rsp              ; wskaźnik na pierwszy qword pierwszego bignuma na stosie
    xor r8, r8                ; iterator po bignumach na stosie
    xor r9, r9                ; drugi iterator po bignumach na stosie
    xor r10, r10              ; iterator po wejściowej tablicy

    call rewrite_array
    call check_array
; Odejmuje od kolejnej liczby poprzednią i zapisuje w miejsce poprzedniej.
.main:
    dec rsi
    xor r8, r8                ; r8 -> wskaźnik na pierwszego bignuma
    mov r9, r14               ; r9 -> wskaźnik na drugiego bignuma
.loop:
    mov rax, qword [rbx + r9] ; zapisujemy 1-szy fragment kolejnego bignuma do rax
    sub rax, qword [rbx + r8] ; odejmujemy od niego 1-szy fragment poprzedniego
    mov qword [rbx + r8], rax ; wynik zapisujemy w tym właśnie fragmencie
    lea r8, [r8 + 8]
    lea r9, [r9 + 8]
    mov rcx, r13              ; musimy poodejmować kolejne fragmenty tych bignumów
    dec rcx                   ; a jeden już odjęliśmy, więc rcx -= 1
.inner_loop:
    mov rax, qword [rbx + r9] ; robimy to co wyżej, tylko na kolejnych fragmentach
    sbb rax, qword [rbx + r8]
    mov qword [rbx + r8], rax
    lea r8, [r8 + 8]
    lea r9, [r9 + 8]
    loop .inner_loop
    cmp r9, r15               ; czy odjęliśmy już ostatnie dwa bignumy od siebie?
    jl .loop
    sub r15, r14              ; jeśli tak, to zmniejszamy liczbę bajtów na tablicę (zmniejsza się jej rozmiar o 1)
    call check_array          ; tablica zmieniona, sprawdzamy co dalej
    ret
