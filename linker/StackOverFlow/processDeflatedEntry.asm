    /* arm-linux-androideabi-objdump generate */
    83a8:    e92d 4ff0     stmdb    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, lr}
    83ac:    469b          mov    fp, r3
    83ae:    4b4f          ldr    r3, [pc, #316]    ; (84ec <processDeflatedEntry+0x144>)
    83b0:    4692          mov    sl, r2
    83b2:    4a4f          ldr    r2, [pc, #316]    ; (84f0 <processDeflatedEntry+0x148>)
    83b4:    4681          mov    r9, r0
    83b6:    447b          add    r3, pc
    83b8:    f5ad 3d80     sub.w    sp, sp, #65536    ; 0x10000
    83bc:    b093          sub    sp, #76    ; 0x4c
    83be:    460e          mov    r6, r1
    83c0:    5898          ldr    r0, [r3, r2]
    83c2:    f50d 3180     add.w    r1, sp, #65536    ; 0x10000
    83c6:    3144          adds    r1, #68    ; 0x44
    83c8:    2238          movs    r2, #56    ; 0x38
    83ca:    2702          movs    r7, #2
    83cc:    68f5          ldr    r5, [r6, #12]
    83ce:    6803          ldr    r3, [r0, #0]
    83d0:    f50d 4400     add.w    r4, sp, #32768    ; 0x8000
    83d4:    9001          str    r0, [sp, #4]
    83d6:    a803          add    r0, sp, #12
    83da:    f44f 4800     mov.w    r8, #32768    ; 0x8000
    83de:    600b          str    r3, [r1, #0]
    83e0:    2100          movs    r1, #0
    83e2:    f006 e8fa     blx    e5d8 <memset>
    83e6:    970e          str    r7, [sp, #56]    ; 0x38
    83e8:    4f42          ldr    r7, [pc, #264]    ; (84f4 <processDeflatedEntry+0x14c>)
    83ea:    f06f 010e     mvn.w    r1, #14
    83ee:    a803          add    r0, sp, #12
    83f0:    2338          movs    r3, #56    ; 0x38
    83f2:    447f          add    r7, pc
    83f4:    9406          str    r4, [sp, #24]
    83f6:    f8cd 801c     str.w    r8, [sp, #28]
    83fa:    463a          mov    r2, r7
    83fc:    f001 ea6a     blx    98d4 <inflateInit2_>
    8400:    4601          mov    r1, r0
    8402:    b160          cbz    r0, 841e <processDeflatedEntry+0x76>
    8404:    1d82          adds    r2, r0, #6
    8406:    d103          bne.n    8410 <processDeflatedEntry+0x68>
    8408:    483b          ldr    r0, [pc, #236]    ; (84f8 <processDeflatedEntry+0x150>)
    840a:    4639          mov    r1, r7
    840c:    4478          add    r0, pc
    840e:    e001          b.n    8414 <processDeflatedEntry+0x6c>
    8410:    483a          ldr    r0, [pc, #232]    ; (84fc <processDeflatedEntry+0x154>)
    8412:    4478          add    r0, pc
    8414:    f006 feea     bl    f1ec <printf>
    8418:    f04f 34ff     mov.w    r4, #4294967295    ; 0xffffffff
    841c:    e049          b.n    84b2 <processDeflatedEntry+0x10a>
    841e:    af11          add    r7, sp, #68    ; 0x44
    8420:    9a04          ldr    r2, [sp, #16]
    8422:    b9ba          cbnz    r2, 8454 <processDeflatedEntry+0xac>
    8424:    f5b5 4f00     cmp.w    r5, #32768    ; 0x8000
    8428:    bfb4          ite    lt
    842a:    46a8          movlt    r8, r5
    842c:    f44f 4800     movge.w    r8, #32768    ; 0x8000
    8430:    4639          mov    r1, r7
    8432:    f8d9 0000     ldr.w    r0, [r9]
    8436:    4642          mov    r2, r8
    8438:    f005 edae     blx    df98 <read>
    843c:    4540          cmp    r0, r8
    843e:    4601          mov    r1, r0
    8440:    d005          beq.n    844e <processDeflatedEntry+0xa6>
    8442:    482f          ldr    r0, [pc, #188]    ; (8500 <processDeflatedEntry+0x158>)
    8444:    4642          mov    r2, r8
    8446:    4478          add    r0, pc
    8448:    f006 fed0     bl    f1ec <printf>
    844c:    e024          b.n    8498 <processDeflatedEntry+0xf0>
    844e:    1a2d          subs    r5, r5, r0
    8450:    9703          str    r7, [sp, #12]
    8452:    9004          str    r0, [sp, #16]
    8454:    2100          movs    r1, #0
    8456:    a803          add    r0, sp, #12
    8458:    f001 eac2     blx    99e0 <inflate>
    845c:    2801          cmp    r0, #1
    845e:    4603          mov    r3, r0
    8460:    d905          bls.n    846e <processDeflatedEntry+0xc6>
    8462:    4828          ldr    r0, [pc, #160]    ; (8504 <processDeflatedEntry+0x15c>)
    8464:    4619          mov    r1, r3
    8466:    4478          add    r0, pc
    8468:    f006 fec0     bl    f1ec <printf>
    846c:    e014          b.n    8498 <processDeflatedEntry+0xf0>
    846e:    9807          ldr    r0, [sp, #28]
    8470:    b130          cbz    r0, 8480 <processDeflatedEntry+0xd8>
    8472:    2b01          cmp    r3, #1
    8474:    d1d4          bne.n    8420 <processDeflatedEntry+0x78>
    8476:    f5b0 4f00     cmp.w    r0, #32768    ; 0x8000
    847a:    d101          bne.n    8480 <processDeflatedEntry+0xd8>
    847c:    9c08          ldr    r4, [sp, #32]
    847e:    e015          b.n    84ac <processDeflatedEntry+0x104>
    8480:    9906          ldr    r1, [sp, #24]
    8482:    465a          mov    r2, fp
    8484:    4620          mov    r0, r4
    8486:    9300          str    r3, [sp, #0]
    8488:    1b09          subs    r1, r1, r4
    848a:    47d0          blx    sl
    848c:    9a00          ldr    r2, [sp, #0]
    848e:    b930          cbnz    r0, 849e <processDeflatedEntry+0xf6>
    8490:    481d          ldr    r0, [pc, #116]    ; (8508 <processDeflatedEntry+0x160>)
    8492:    4478          add    r0, pc
    8494:    f005 fcd6     bl    de44 <puts>
    8498:    f04f 34ff     mov.w    r4, #4294967295    ; 0xffffffff
    849c:    e006          b.n    84ac <processDeflatedEntry+0x104>
    849e:    f44f 4300     mov.w    r3, #32768    ; 0x8000
    84a2:    9406          str    r4, [sp, #24]
    84a4:    9307          str    r3, [sp, #28]
    84a6:    2a00          cmp    r2, #0
    84a8:    d0ba          beq.n    8420 <processDeflatedEntry+0x78>
    84aa:    e7e7          b.n    847c <processDeflatedEntry+0xd4>
    84ac:    a803          add    r0, sp, #12
    84ae:    f003 e944     blx    b738 <inflateEnd>
    84b2:    6932          ldr    r2, [r6, #16]
    84b4:    4294          cmp    r4, r2
    84b6:    d007          beq.n    84c8 <processDeflatedEntry+0x120>
    84b8:    1c63          adds    r3, r4, #1
    84ba:    d007          beq.n    84cc <processDeflatedEntry+0x124>
    84bc:    4813          ldr    r0, [pc, #76]    ; (850c <processDeflatedEntry+0x164>)
    84be:    4621          mov    r1, r4
    84c0:    4478          add    r0, pc
    84c2:    f006 fe93     bl    f1ec <printf>
    84c6:    e001          b.n    84cc <processDeflatedEntry+0x124>
    84c8:    2001          movs    r0, #1
    84ca:    e000          b.n    84ce <processDeflatedEntry+0x126>
    84ce:    f50d 3180     add.w    r1, sp, #65536    ; 0x10000
    84d2:    9b01          ldr    r3, [sp, #4]
    84d4:    3144          adds    r1, #68    ; 0x44
    84d6:    680a          ldr    r2, [r1, #0]
    84d8:    6819          ldr    r1, [r3, #0]
    84da:    428a          cmp    r2, r1
    84dc:    d001          beq.n    84e2 <processDeflatedEntry+0x13a>
    84de:    f004 fc95     bl    ce0c <__stack_chk_fail>
    84e2:    b013          add    sp, #76    ; 0x4c
    84e4:    f50d 3d80     add.w    sp, sp, #65536    ; 0x10000
    84e8:    e8bd 8ff0     ldmia.w    sp!, {r4, r5, r6, r7, r8, r9, sl, fp, pc}


    84ec:    00018c3a     .word    0x00018c3a
    84f0:    ffffff84     .word    0xffffff84
    84f4:    00011d6b     .word    0x00011d6b
    84f8:    00011d71     .word    0x00011d71
    84fc:    00011dae     .word    0x00011dae
    8500:    00011da9     .word    0x00011da9
    8504:    00011db2     .word    0x00011db2
    8508:    00011db2     .word    0x00011db2
    850c:    00011dba     .word    0x00011dba


    /* IDA generate */
processDeflatedEntry            ; CODE XREF: mzProcessZipEntryContents+42p

var_10070    = -0x10070
var_1006C    = -0x1006C
var_10064    = -0x10064
var_10060    = -0x10060
var_10058    = -0x10058
var_10054    = -0x10054
var_10050    = -0x10050
var_10038    = -0x10038
var_1002C    = -0x1002C
var_8070    = -0x8070
var_70        = -0x70

        PUSH.W        {R4-R11,LR}
        MOV        R11, R3

        LDR        R3, =(_GLOBAL_OFFSET_TABLE_ - 0x83BA)
        MOV        R10, R2
        LDR        R2, =(__stack_chk_guard_ptr - 0x20FF4)
        MOV        R9, R0
        ADD        R3, PC ; _GLOBAL_OFFSET_TABLE_

        SUB.W      SP, SP,    #0x10000
        SUB        SP, SP,    #0x4C

        MOV        R6, R1

        LDR        R0, [R3,R2] ; __stack_chk_guard

        ADD.W      R1, SP,    #0x10070+var_70
        ADDS       R1, #0x44
        MOVS       R2, #0x38
        MOVS       R7, #2
        LDR        R5, [R6,#0xC]
        LDR        R3, [R0]
        ADD.W       R4, SP,    #0x10070+var_8070

        STR        R0, [SP,#0x10070+var_1006C]

        ADD        R0, SP,    #0x10070+var_10064
        ADDS        R4, #0x44
        MOV.W        R8, #0x8000
        STR        R3, [R1]
        MOVS        R1, #0
        BLX        memset
        STR        R7, [SP,#0x10070+var_10038]
        LDR        R7, =(a1_2_8_fLinuxfo -    0x83F6)
        MOV        R1, #0xFFFFFFF1
        ADD        R0, SP,    #0x10070+var_10064
        MOVS        R3, #0x38
        ADD        R7, PC    ; "1.2.8.f-linuxfoundation-mods-v1"
        STR        R4, [SP,#0x10070+var_10058]
        STR.W        R8, [SP,#0x10070+var_10054]
        MOV        R2, R7
        BLX        inflateInit2_
        MOV        R1, R0
        CBZ        R0, loc_841E
        ADDS        R2, R0,    #6
        BNE        loc_8410
        LDR        R0, =(aMinzipInstalle -    0x8410)
        MOV        R1, R7
        ADD        R0, PC    ; "minzip: Installed zlib is not compatibl"...
        B        loc_8414
; ---------------------------------------------------------------------------

loc_8410                ; CODE XREF: processDeflatedEntry+5Ej
        LDR        R0, =(aMinzipCallToIn -    0x8416)
        ADD        R0, PC    ; "minzip: Call to inflateInit2 failed (ze"...

loc_8414                ; CODE XREF: processDeflatedEntry+66j
        BL        printf
        MOV.W        R4, #0xFFFFFFFF
        B        loc_84B2
; ---------------------------------------------------------------------------

loc_841E                ; CODE XREF: processDeflatedEntry+5Aj
        ADD        R7, SP,    #0x10070+var_1002C

loc_8420                ; CODE XREF: processDeflatedEntry+CCj
                    ; processDeflatedEntry+100j
        LDR        R2, [SP,#0x10070+var_10060]
        CBNZ        R2, loc_8454
        CMP.W        R5, #0x8000
        ITE LT
        MOVLT        R8, R5
        MOVGE.W        R8, #0x8000
        MOV        R1, R7
        LDR.W        R0, [R9]
        MOV        R2, R8
        BLX        read
        CMP        R0, R8
        MOV        R1, R0
        BEQ        loc_844E
        LDR        R0, =(aMinzipInflateR -    0x844A)
        MOV        R2, R8
        ADD        R0, PC    ; "minzip: inflate read failed (%d vs %ld)"...
        BL        printf
        B        loc_8498
; ---------------------------------------------------------------------------

loc_844E                ; CODE XREF: processDeflatedEntry+98j
        SUBS        R5, R5,    R0
        STR        R7, [SP,#0x10070+var_10064]
        STR        R0, [SP,#0x10070+var_10060]

loc_8454                ; CODE XREF: processDeflatedEntry+7Aj
        MOVS        R1, #0
        ADD        R0, SP,    #0x10070+var_10064
        BLX        inflate
        CMP        R0, #1
        MOV        R3, R0
        BLS        loc_846E
        LDR        R0, =(aMinzipZlibInfl -    0x846A)
        MOV        R1, R3
        ADD        R0, PC    ; "minzip: zlib inflate call failed (zerr="...
        BL        printf
        B        loc_8498
; ---------------------------------------------------------------------------

loc_846E                ; CODE XREF: processDeflatedEntry+B8j
        LDR        R0, [SP,#0x10070+var_10054]
        CBZ        R0, loc_8480
        CMP        R3, #1
        BNE        loc_8420
        CMP.W        R0, #0x8000
        BNE        loc_8480

loc_847C                ; CODE XREF: processDeflatedEntry+102j
        LDR        R4, [SP,#0x10070+var_10050]
        B        loc_84AC
; ---------------------------------------------------------------------------

loc_8480                ; CODE XREF: processDeflatedEntry+C8j
                    ; processDeflatedEntry+D2j
        LDR        R1, [SP,#0x10070+var_10058]
        MOV        R2, R11
        MOV        R0, R4
        STR        R3, [SP,#0x10070+var_10070]
        SUBS        R1, R1,    R4
        BLX        R10
        LDR        R2, [SP,#0x10070+var_10070]
        CBNZ        R0, loc_849E
        LDR        R0, =(aMinzipProcessF -    0x8496)
        ADD        R0, PC    ; "minzip: Process function elected to fai"...
        BL        puts

loc_8498                ; CODE XREF: processDeflatedEntry+A4j
                    ; processDeflatedEntry+C4j
        MOV.W        R4, #0xFFFFFFFF
        B        loc_84AC
; ---------------------------------------------------------------------------

loc_849E                ; CODE XREF: processDeflatedEntry+E6j
        MOV.W        R3, #0x8000
        STR        R4, [SP,#0x10070+var_10058]
        STR        R3, [SP,#0x10070+var_10054]
        CMP        R2, #0
        BEQ        loc_8420
        B        loc_847C
; ---------------------------------------------------------------------------

loc_84AC                ; CODE XREF: processDeflatedEntry+D6j
                    ; processDeflatedEntry+F4j
        ADD        R0, SP,    #0x10070+var_10064
        BLX        inflateEnd

loc_84B2                ; CODE XREF: processDeflatedEntry+74j
        LDR        R2, [R6,#0x10]
        CMP        R4, R2
        BEQ        loc_84C8
        ADDS        R3, R4,    #1
        BEQ        loc_84CC
        LDR        R0, =(aMinzipSizeMism -    0x84C4)
        MOV        R1, R4
        ADD        R0, PC    ; "minzip: Size mismatch on inflated file "...
        BL        printf
        B        loc_84CC
; ---------------------------------------------------------------------------

loc_84C8                ; CODE XREF: processDeflatedEntry+10Ej
        MOVS        R0, #1
        B        loc_84CE
; ---------------------------------------------------------------------------

loc_84CC                ; CODE XREF: processDeflatedEntry+112j
                    ; processDeflatedEntry+11Ej
        MOVS        R0, #0

loc_84CE                ; CODE XREF: processDeflatedEntry+122j
        ADD.W        R1, SP,    #0x10070+var_70
        LDR        R3, [SP,#0x10070+var_1006C]
        ADDS        R1, #0x44
        LDR        R2, [R1]
        LDR        R1, [R3]
        CMP        R2, R1
        BEQ        loc_84E2
        BL        __stack_chk_fail
; ---------------------------------------------------------------------------

loc_84E2                ; CODE XREF: processDeflatedEntry+134j
        ADD        SP, SP,    #0x4C
        ADD.W        SP, SP,    #0x10000
        POP.W        {R4-R11,PC}
; End of function processDeflatedEntry
