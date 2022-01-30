// aarch64 asm
/********************************************************************
* Copyright (c) 2022, Eric Mackay
* All rights reserved.
* 
* This source code is licensed under the BSD-style license found in the
* LICENSE file in the root directory of this source tree.
********************************************************************/

/********************************************************************
* Author: Eric Mackay
* Date:   January 22, 2022
********************************************************************/

.text
.globl    _start
_start:
// print Passcode: 
        mov         x0, #1                  // stdout
        ldr         x1, =msg                // addr output
        ldr         x2, =len                // number of bytes
        bl          print
        bl          exit

// exit program in an orderly fashion 
exit:
        mov         w8, EXITCALL            // system call for exit
        mov         x0, #0                  // exit code 0
        svc         #0                      // invoke operating system to exit

print:
        mov         w8, PRINTCALL           // system call for write
        svc         #0                      // invoke operating system to do the write
        ret

.data
// printable characters
msg: .ascii        "Hello world\n"
len = . - msg
