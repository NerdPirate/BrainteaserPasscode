; The security door passcode is a seven digit number whose digits total 35. The fourth digit is three more than the first digit, the fifth digit is four more than the second digit, the sixth digit is one less than the fourth digit, the last digit is one less than twice the second digit, and the sum of the first tand third digits is one more than the fourth digits. However, the passcode has no repeated digits. What is the passcode?

; Overview
; Using 9 variables, we permute through all possible combinations (9! possibilities) and check the first 7 variables against the passcode constraints. With 7 unique digits in the passcode, there are 9! - 2! combinations.
; Using Heap's algorithm for producing all permutations
; Specifically, we are using 9 bytes of a vector, but only 7 bytes (indices 0-6) are checked against constraints

; remember rdi, rsi, rdx, rcx, r8, r9
; return val in rax
          section   .text
          global    _start
_start:
; set bytes in vector register to each of the possible digits

          pxor      xmm0, xmm0
          xor       eax, eax
          add       eax, 1
          pinsrb    xmm0, eax, 0
          add       eax, 1
          pinsrb    xmm0, eax, 1
          add       eax, 1
          pinsrb    xmm0, eax, 2
          add       eax, 1
          pinsrb    xmm0, eax, 3
          add       eax, 1
          pinsrb    xmm0, eax, 4
          add       eax, 1
          pinsrb    xmm0, eax, 5
          add       eax, 1
          pinsrb    xmm0, eax, 6
          add       eax, 1
          pinsrb    xmm0, eax, 7
          add       eax, 1
          pinsrb    xmm0, eax, 8
          movdqa    xmm4, [_mask_identity] ; create identity mask for later
          call      permute
          test      al, al
          jnz       _failure
; print Passcode: 
          mov       rdi, 1                  ; stdout
          mov       rsi, msg                ; addr output
          mov       rdx, 10                 ; number of bytes
          call      print
          call      print_digits
; print newline 
          mov       rdi, 1                  ; stdout
          mov       rsi, _lf                ; addr output
          mov       rdx, 1                  ; number of bytes
          call      print
          jmp       exit

_failure:
          mov       rdi, 1                  ; stdout
          mov       rsi, fail_msg           ; addr output
          mov       rdx, 24                 ; number of bytes
          call      print

; exit program in an orderly fashion 
exit:
          mov       rax, 60                 ; system call for exit
          xor       rdi, rdi                ; exit code 0
          syscall                           ; invoke operating system to exit

print:
          mov       rax, 1                  ; system call for write
          syscall                           ; invoke operating system to do the write
          ret

print_digits:
          mov       rdi, 1                  ; stdout
          ;pxor      xmm0, xmm0
          pextrb    rcx, xmm0, 0            ; extract 1st digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 1            ; extract 2nd digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 2            ; extract 3rd digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 3            ; extract 4th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 4            ; extract 5th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 5            ; extract 6th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 6            ; extract 7th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          ; TODO testing

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _lb                ; address of [
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 7            ; extract 8th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _space             ; address of space
          mov       rdx, 1                  ; number of bytes
          call      print

          pextrb    rcx, xmm0, 8            ; extract 9th digit
          mov       rsi, _0                 ; address of '0'
          add       rsi, rcx                ; set output
          mov       rdx, 1                  ; number of bytes
          call      print

          mov       rsi, _rb                ; address of ]
          mov       rdx, 1                  ; number of bytes
          call      print

          ret

permute:
          call      chk_cnstrnts            ; cb(s) before while
          test      al, al
          jz        _exit_permute           ; if al is 0, we are done

          pxor      xmm1, xmm1              ; c = 0
          xor       rdi, rdi                ; j = 0
_loop:
          mov       rsi, rdi                ; copy j into rsi
          call      extract_byte
          sub       rsi, rax                ; j - c[j]
          jbe       _else
_inner_if:
          test      rdi, 1                  ; j & 0x1 
          jz        _inner_else             ; == 0 if even
          call      swap_bytes              ;swap xmm0 indices c[j], j
          jmp       _afterinner_ifelse
_inner_else:
          call      swap_bytes_0            ; swap xmm0 indices 0, j
_afterinner_ifelse:
          call      chk_cnstrnts            ; cb(s) after inner if-else
          test      al, al
          jz        _exit_permute           ; if al is 0, we are done
          call      extract_byte            ; c[j] += 1
          add       rax, 1
          call      insert_byte
          xor       rdi, rdi                ; j = 0
          jmp       _after_ifelse
_else:    
          xor       rax, rax
          call      insert_byte             ; c[j] = 0, rdi is j, rax is 0;
          add       rdi, 1                  ; j++
_after_ifelse:
          mov       rsi, rdi                ; copy j into rsi
          sub       rsi, 9                  ; j-9
          jbe       _loop                   ; while j < n
_exit_permute:
          ret

; Extract byte from arbitrary index in xmm1, index is in rdi, val returned in rax, only defined between indices 0-8
extract_byte:
          mov       r11, _table_extract
          lea       r8, [rdi*8+r11]
          jmp       [r8]
_extract_byte_0:
          pextrb    rax, xmm1, 0
          ret
_extract_byte_1:
          pextrb    rax, xmm1, 1
          ret
_extract_byte_2:
          pextrb    rax, xmm1, 2
          ret
_extract_byte_3:
          pextrb    rax, xmm1, 3
          ret
_extract_byte_4:
          pextrb    rax, xmm1, 4
          ret
_extract_byte_5:
          pextrb    rax, xmm1, 5
          ret
_extract_byte_6:
          pextrb    rax, xmm1, 6
          ret
_extract_byte_7:
          pextrb    rax, xmm1, 7
          ret
_extract_byte_8:
          pextrb    rax, xmm1, 8
          ret

; Insert byte into arbitrary index in xmm1, index is in rdi, val to set is in eax, only defined between indices 0-8
insert_byte:
          mov       r11, _table_insert
          lea       r8, [rdi*8+r11]
          jmp       [r8]
_insert_byte_0:
          pinsrb    xmm1, eax, 0
          ret
_insert_byte_1:
          pinsrb    xmm1, eax, 1
          ret
_insert_byte_2:
          pinsrb    xmm1, eax, 2
          ret
_insert_byte_3:
          pinsrb    xmm1, eax, 3
          ret
_insert_byte_4:
          pinsrb    xmm1, eax, 4
          ret
_insert_byte_5:
          pinsrb    xmm1, eax, 5
          ret
_insert_byte_6:
          pinsrb    xmm1, eax, 6
          ret
_insert_byte_7:
          pinsrb    xmm1, eax, 7
          ret
_insert_byte_8:
          pinsrb    xmm1, eax, 8
          ret

swap_bytes:
          call      extract_byte            ; rax = c[j]
          movdqa    xmm3, xmm1              ; save xmm1 in xmm3
          movdqa    xmm1, xmm4              ; copy identity mask into xmm1
          call      insert_byte             ; byte j will come from position c[j]
          mov       rbx, rax                ; save rax ( c[j] )
          mov       r10, rdi                ; save rdi ( j )
          mov       rax, rdi                ; move j into rax
          mov       rdi, rbx                ; move c[j] into rdi
          call      insert_byte             ; byte c[j] will come from position j
          mov       rdi, r10                ; restore rdi (j)
          pshufb    xmm0, xmm1              ; do the digit swap
          movdqa    xmm1, xmm3              ; restore xmm1
          ret

swap_bytes_0:
          movdqa    xmm3, xmm1              ; save xmm1 in xmm3 so we can create mask in xmm1
          movdqa    xmm1, xmm4              ; copy identity mask into xmm1
          pinsrb    xmm1, edi, 0            ; byte 0 will come from position j
          xor       rax, rax
          call      insert_byte             ; byte j will come from position 0
          pshufb    xmm0, xmm1              ; do the digit swap
          movdqa    xmm1, xmm3              ; restore xmm1
          ret

; The security door passcode is a seven digit number whose digits
; total 35. The fourth digit is three more than the first digit,
; the fifth digit is four more than the second digit, the sixth
; digit is one less than the fourth digit, the last digit is one
; less than twice the second digit, and the sum of the first and
; third digits is one more than the fourth digits. However, the
; passcode has no repeated digits. Digits must be > 0 and < 10.
; What is the passcode?

chk_cnstrnts:
          ; Add up elements and see if they total 35
          ; Note: Performing horizontal add (e.g., phaddw) seems
          ;   easier but is actually slower. Approximately 11 cpu
          ;   cycles to implement below reduction and comparison
          ;   using phaddw (reciprocal of throughput, not total
          ;   latency), vs approximately 6 in current
          ;   implementation. Based on instruction timing tables
          ;   from Agner Fog for Intel Coffee Lake
          movdqa    xmm3, xmm0
          pshufb    xmm3, [_mask_reduce_4]
          paddb     xmm3, xmm0
          movdqa    xmm2, xmm3
          pshufb    xmm2, [_mask_reduce_2]
          paddb     xmm3, xmm2
          pextrb    ebx, xmm3, 0             ; extract [0]+[2]+[4]+[6]
          pextrb    ecx, xmm3, 1             ; extract [1]+[3]+[5]
          mov       al, 35
          sub al, bl
          sub al, cl
          jnz _exit_fail

          ; TODO make efficient use of vectors to calculate
          ;   multiple constraints simultaneously

          ; The fourth digit is three more than the first digit
          pextrb ebx, xmm0, 0 ; ebx is 1st digit [0]
          pextrb eax, xmm0, 3 ; eax is 4th digit [3]
          sub eax, 3
          sub eax, ebx
          jnz _exit_fail

          ; The fifth digit is four more than the second digit
          pextrb ebx, xmm0, 1 ; ebx is 2nd digit [1]
          pextrb eax, xmm0, 4 ; eax is 5th digit [4]
          sub eax, 4
          sub eax, ebx
          jnz _exit_fail

          ; The sixth digit is one less than the fourth digit
          pextrb ebx, xmm0, 3 ; ebx is 4th digit [3]
          pextrb eax, xmm0, 5 ; eax is 6th digit [5]
          add eax, 1
          sub eax, ebx
          jnz _exit_fail

          ; TODO check other constraints


_exit_pass:
          mov al, 0
_exit_fail:
          ret

          section   .data
; printable characters
fail_msg: db        "Failed to find passcode", 10
msg:      db        "Passcode: "
_0:       db        '0'          ; 0 character
_1:       db        '1'          ; 1 character
_2:       db        '2'          ; 2 character
_3:       db        '3'          ; 3 character
_4:       db        '4'          ; 4 character
_5:       db        '5'          ; 5 character
_6:       db        '6'          ; 6 character
_7:       db        '7'          ; 7 character
_8:       db        '8'          ; 8 character
_9:       db        '9'          ; 9 character
_space:   db        ' '          ; space character
_lf:      db        10           ; newline character
_lb:      db        '['          ; [ char for testing
_rb:      db        ']'          ; ] char for testing

; jump tables
_table_extract:
          dq  _extract_byte_0,_extract_byte_1,_extract_byte_2,_extract_byte_3,_extract_byte_4,_extract_byte_5,_extract_byte_6,_extract_byte_7,_extract_byte_8
_table_insert:
          dq  _insert_byte_0,_insert_byte_1,_insert_byte_2,_insert_byte_3,_insert_byte_4,_insert_byte_5,_insert_byte_6,_insert_byte_7,_insert_byte_8

; byte shuffle masks
          align 16
_mask_identity:
          db        0,1,2,3,4,5,6,7,8,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
          align 16
_mask_reduce_4:
          db        4,5,6,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
          align 16
_mask_reduce_2:
          db        2,3,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF,0xFF
