;
; kb311561de.nasm: the German io.sys of KB311561, built from the German Windows 98 SE CD
;
; Compile with: nasm -O0 -w+orphan-labels -f bin -o winboot.98d kb311561de.nasm
; Minimum NASM version required to compile: 0.98.39
;
; KB311561 contains the same io.sys (winboot.98s) in every language, with English
; messages. This file applies its changes to the German winboot.sys instead:
;
; * Input: winboot.sys from WIN98\PRECOPY1.CAB (continued in PRECOPY2.CAB) of the
;   German Windows 98 SE CD:
;   `cabextract -F winboot.sys PRECOPY1.CAB`
;   sha256sum: 33c946c67780f0da704128c72b733d1fc0e36132d7a7944ef2d18d635d4545b8  winboot.sys
; * Output: winboot.98d, the same changes (code, relocated offsets, size of msdos.sys
;   payload) as from the English Windows 98 SE io.sys to winboot.98s.
;   sha256sum: ed50491b02d2cb5f7dc1f1120f8a7d8bc8ed5c70d2167a09fd6aefa1d9d67027  winboot.98d
; * The logo moves from 0x1e000 to 0x1e010, into the 0x10 NUL bytes before MSDCM.
;   MSDCM at 0x2e400 remains the German one of the CD. (KB311561 also changes the
;   English MSDCM, making winboot.98s 0x118 bytes longer; the German winboot.98d
;   keeps the size of the CD file, and the MZ header, which describes MSDCM.)
;
%define ORIG_IO_FN 'winboot.sys'

%macro copy_until 1  ; %1: offset in ORIG_IO_FN.
  incbin ORIG_IO_FN, ifofs, (%1)-ifofs
  %assign ifofs %1
%endm

%macro skip 1  ; %1: byte count to skip in ORIG_IO_FN.
  %assign ifofs ifofs+(%1)
%endm

%assign ifofs 0
copy_until 0x808
skip 1  ; 65
db 0x66
copy_until 0x8fa
skip 1  ; 60
db 0x61
copy_until 0x948
skip 2  ; f7 27
db 0x0b, 0x28
copy_until 0x968
skip 1  ; 10
db 0x24
copy_until 0xac1
skip 2  ; f4 2f
db 0x08, 0x30
copy_until 0xfb4
skip 1  ; 60
db 0x61
copy_until 0x114b
skip 1  ; 89
db 0x8a
copy_until 0x13e2
skip 1  ; d5
db 0xd6
copy_until 0x17a6
skip 1  ; 89
db 0x8a
copy_until 0x17e0
skip 1  ; 60
db 0x61
copy_until 0x28fe
skip 1  ; 66
db 0x76
copy_until 0x2902
skip 1  ; 5c
db 0x6c
copy_until 0x290a
skip 1  ; 66
db 0x76
copy_until 0x290e
skip 1  ; 5e
db 0x6e
copy_until 0x2916
skip 1  ; 66
db 0x76
copy_until 0x291a
skip 1  ; 60
db 0x70
copy_until 0x2922
skip 1  ; 66
db 0x76
copy_until 0x2926
skip 1  ; 62
db 0x72
copy_until 0x30a8
skip 2  ; f6 18
db 0x0a, 0x19
copy_until 0x30b0
skip 1  ; 96
db 0xaa
copy_until 0x30b2
skip 1  ; b4
db 0xc8
copy_until 0x30b4
skip 1  ; a8
db 0xbc
copy_until 0x30bd
skip 1  ; 02
db 0x16
copy_until 0x310f
skip 1  ; 35
db 0x49
copy_until 0x3114
skip 1  ; bb
db 0xcf
copy_until 0x3141
skip 1  ; 17
db 0x2b
copy_until 0x31b7
skip 1  ; 1f
db 0x33
copy_until 0x32a7
skip 1  ; 22
db 0x36
copy_until 0x32c1
skip 1  ; ac
db 0xc0
copy_until 0x3499
skip 1  ; bd
db 0xd1
copy_until 0x34bf
skip 1  ; bd
db 0xd1
copy_until 0x35b4
skip 1  ; 15
db 0x29
copy_until 0x35d9
skip 1  ; ba
db 0xce
copy_until 0x3690
skip 2  ; fc 16
db 0x10, 0x17
copy_until 0x36f6
skip 1  ; bd
db 0xd1
copy_until 0x373e
skip 1  ; bd
db 0xd1
copy_until 0x38de
skip 1  ; 3b
db 0x4f
copy_until 0x38e3
skip 1  ; 36
db 0x4a
copy_until 0x38f4
skip 1  ; 36
db 0x4a
copy_until 0x3946
skip 1  ; bd
db 0xd1
copy_until 0x3977
skip 1  ; ba
db 0xce
copy_until 0x397e
skip 1  ; ba
db 0xce
copy_until 0x39c2
skip 1  ; 57
db 0x6b
copy_until 0x3a22
skip 1  ; ba
db 0xce
copy_until 0x3a4a
db 0x2e, 0xff, 0x36, 0xd0, 0x17
copy_until 0x3a4c
db 0x2e, 0x8f, 0x06, 0xd0, 0x17
copy_until 0x3a4e
skip 1  ; 18
db 0x22
copy_until 0x3a57
skip 1  ; 0c
db 0x16
copy_until 0x3a5f
db 0x2e, 0xff, 0x36, 0xd0, 0x17
copy_until 0x3a61
db 0x2e, 0x8f, 0x06, 0xd0, 0x17
copy_until 0x3a97
skip 1  ; a2
db 0x8e
copy_until 0x3a9e
skip 1  ; 8d
db 0x79
copy_until 0x3ac2
skip 1  ; 82
db 0x96
copy_until 0x3ac4
skip 1  ; 36
db 0x4a
copy_until 0x3ac6
skip 1  ; cb
db 0xdf
copy_until 0x3ac8
skip 1  ; 7e
db 0x92
copy_until 0x3aca
skip 1  ; 7e
db 0x92
copy_until 0x3acc
skip 1  ; 7e
db 0x92
copy_until 0x3ace
skip 1  ; 09
db 0x1d
copy_until 0x3ad0
skip 1  ; 77
db 0x8b
copy_until 0x3ad2
skip 1  ; d3
db 0xe7
copy_until 0x3ad5
skip 1  ; 1e
db 0x32
copy_until 0x3ad7
skip 1  ; 3e
db 0x52
copy_until 0x3ad9
skip 3  ; fe 1a 7e
db 0x12, 0x1b, 0x92
copy_until 0x3add
skip 1  ; 7e
db 0x92
copy_until 0x3adf
skip 1  ; 7e
db 0x92
copy_until 0x3ae1
skip 1  ; 54
db 0x68
copy_until 0x3ae3
skip 1  ; 8e
db 0xa2
copy_until 0x3ae5
skip 1  ; 13
db 0x27
copy_until 0x3ae7
skip 1  ; 38
db 0x4c
copy_until 0x3af7
skip 1  ; cc
db 0xb8
copy_until 0x3afc
skip 1  ; b7
db 0xcb
copy_until 0x3b02
skip 1  ; b8
db 0xcc
copy_until 0x3b1b
skip 1  ; b7
db 0xcb
copy_until 0x3b26
skip 1  ; c1
db 0xd5
copy_until 0x3b2d
skip 1  ; d4
db 0xe8
copy_until 0x3b39
skip 1  ; b7
db 0xcb
copy_until 0x3b49
skip 1  ; b9
db 0xcd
copy_until 0x3b53
skip 1  ; b8
db 0xcc
copy_until 0x3b5b
skip 1  ; b8
db 0xcc
copy_until 0x3b80
skip 1  ; 3f
db 0x2b
copy_until 0x3bb5
skip 1  ; 8e
db 0x7a
copy_until 0x3bb8
skip 1  ; 4f
db 0x3b
copy_until 0x3bd7
skip 1  ; b7
db 0xcb
copy_until 0x3bfc
skip 1  ; b8
db 0xcc
copy_until 0x3c6e
skip 1  ; bc
db 0xd0
copy_until 0x3c76
skip 1  ; b7
db 0xcb
copy_until 0x3cb4
skip 1  ; b7
db 0xcb
copy_until 0x3cbf
skip 1  ; bf
db 0xd3
copy_until 0x3ce5
skip 1  ; b7
db 0xcb
copy_until 0x3d46
skip 1  ; fd
db 0xe9
copy_until 0x3d4c
skip 1  ; b4
db 0xc8
copy_until 0x3d51
skip 1  ; b3
db 0xc7
copy_until 0x3d60
skip 1  ; bf
db 0xd3
copy_until 0x3d72
skip 1  ; bf
db 0xd3
copy_until 0x3d79
skip 1  ; ba
db 0xce
copy_until 0x3d88
skip 1  ; ba
db 0xce
copy_until 0x3d8c
skip 1  ; bf
db 0xd3
copy_until 0x3d9f
skip 1  ; be
db 0xd2
copy_until 0x3db7
skip 1  ; be
db 0xd2
copy_until 0x3dc2
skip 1  ; c2
db 0xae
copy_until 0x3dc7
skip 1  ; be
db 0xd2
copy_until 0x3df1
skip 1  ; bf
db 0xd3
copy_until 0x3e23
skip 1  ; ba
db 0xce
copy_until 0x3e34
skip 1  ; 50
db 0x3c
copy_until 0x3e6c
skip 1  ; ba
db 0xce
copy_until 0x3e75
skip 1  ; ce
db 0xba
copy_until 0x3e7a
skip 1  ; bd
db 0xd1
copy_until 0x3e82
skip 1  ; 67
db 0x53
copy_until 0x3ebc
skip 1  ; 26
db 0x12
copy_until 0x3ee0
skip 2  ; 02 f9
db 0xee, 0xf8
copy_until 0x3ef0
skip 1  ; bd
db 0xd1
copy_until 0x3ef6
skip 1  ; 38
db 0x24
copy_until 0x3f10
skip 1  ; be
db 0xd2
copy_until 0x3f26
skip 1  ; be
db 0xd2
copy_until 0x3f2c
skip 1  ; b6
db 0xca
copy_until 0x3f48
skip 1  ; bc
db 0xd0
copy_until 0x3f52
skip 1  ; b6
db 0xca
copy_until 0x3f74
skip 1  ; b2
db 0xc6
copy_until 0x3f7c
skip 1  ; be
db 0xd2
copy_until 0x3f86
skip 1  ; bd
db 0xd1
copy_until 0x3fcd
skip 1  ; be
db 0xd2
copy_until 0x3fe0
skip 1  ; ae
db 0xc2
copy_until 0x3fe5
skip 1  ; b0
db 0xc4
copy_until 0x3ff5
skip 1  ; bd
db 0xd1
copy_until 0x3ffc
skip 1  ; be
db 0xd2
copy_until 0x401f
skip 1  ; bd
db 0xd1
copy_until 0x4027
skip 1  ; be
db 0xd2
copy_until 0x403b
skip 1  ; bd
db 0xd1
copy_until 0x405d
skip 1  ; b2
db 0xc6
copy_until 0x4065
skip 1  ; b6
db 0xca
copy_until 0x407d
skip 1  ; b4
db 0xc8
copy_until 0x4088
skip 1  ; b3
db 0xc7
copy_until 0x408e
skip 1  ; ba
db 0xce
copy_until 0x4097
skip 1  ; 2c
db 0x18
copy_until 0x40b5
skip 2  ; 0e f0
db 0xfa, 0xef
copy_until 0x40bd
skip 1  ; 86
db 0x72
copy_until 0x40e2
skip 1  ; be
db 0xd2
copy_until 0x40e7
skip 1  ; bd
db 0xd1
copy_until 0x40f3
skip 1  ; ae
db 0xc2
copy_until 0x41a7
skip 1  ; 68
db 0x54
copy_until 0x41f2
skip 1  ; e0
db 0xcc
copy_until 0x42bf
skip 1  ; e9
db 0xfd
copy_until 0x42d1
skip 1  ; ee
db 0xda
copy_until 0x4333
skip 1  ; 51
db 0x3d
copy_until 0x434e
skip 1  ; 36
db 0x22
copy_until 0x43d6
skip 1  ; de
db 0xf2
copy_until 0x43da
skip 1  ; 12
db 0x26
copy_until 0x4599
skip 1  ; 32
db 0x46
copy_until 0x459c
skip 1  ; 80
db 0x94
copy_until 0x45a1
skip 1  ; 30
db 0x44
copy_until 0x45a6
skip 1  ; 31
db 0x45
copy_until 0x45e8
skip 1  ; 2c
db 0x40
copy_until 0x45ed
skip 1  ; 2e
db 0x42
copy_until 0x45f0
skip 1  ; 28
db 0x3c
copy_until 0x461c
skip 1  ; ca
db 0xde
copy_until 0x4621
skip 1  ; cc
db 0xe0
copy_until 0x4626
skip 1  ; d8
db 0xec
copy_until 0x462b
skip 1  ; dc
db 0xf0
copy_until 0x462e
skip 1  ; c8
db 0xdc
copy_until 0x463e
skip 1  ; c2
db 0xd6
copy_until 0x464c
skip 1  ; 72
db 0x86
copy_until 0x4654
skip 1  ; 74
db 0x88
copy_until 0x4679
skip 1  ; 72
db 0x86
copy_until 0x4682
skip 1  ; 73
db 0x87
copy_until 0x4699
skip 1  ; 6c
db 0x80
copy_until 0x46d0
skip 1  ; c7
db 0xb3
copy_until 0x46dd
skip 1  ; 21
db 0x0d
copy_until 0x46e3
skip 1  ; fd
db 0xe9
copy_until 0x47c3
skip 1  ; 6e
db 0x82
copy_until 0x49c2
skip 1  ; dd
db 0xf1
copy_until 0x49cd
skip 1  ; 9e
db 0xb2
copy_until 0x49df
skip 1  ; da
db 0xee
copy_until 0x49e7
skip 1  ; da
db 0xee
copy_until 0x4a03
skip 1  ; da
db 0xee
copy_until 0x4a0d
skip 1  ; dd
db 0xf1
copy_until 0x4a56
skip 1  ; bd
db 0xd1
copy_until 0x4a5e
skip 1  ; db
db 0xef
copy_until 0x4a69
skip 1  ; db
db 0xef
copy_until 0x4a77
skip 1  ; da
db 0xee
copy_until 0x4a84
skip 1  ; dc
db 0xf0
copy_until 0x4aa4
skip 1  ; dc
db 0xf0
copy_until 0x4ae1
skip 1  ; da
db 0xee
copy_until 0x4ceb
skip 2  ; f4 2a
db 0x08, 0x2b
copy_until 0x4d0d
skip 1  ; 66
db 0x76
copy_until 0x4d12
skip 1  ; 58
db 0x68
copy_until 0x4d20
skip 1  ; 66
db 0x76
copy_until 0x4d25
skip 1  ; 5a
db 0x6a
copy_until 0x4d2b
skip 1  ; 6d
db 0x59
copy_until 0x4d47
skip 1  ; fc
db 0xe8
copy_until 0x4d75
skip 1  ; da
db 0xc6
copy_until 0x4d82
skip 1  ; 85
db 0x71
copy_until 0x4d8c
skip 1  ; f8
db 0xe4
copy_until 0x4d99
skip 1  ; 6e
db 0x5a
copy_until 0x4daa
skip 1  ; da
db 0xc6
copy_until 0x4e37
skip 1  ; d0
db 0xbc
copy_until 0x4e4b
skip 1  ; e0
db 0xcc
copy_until 0x4e4e
skip 1  ; e0
db 0xcc
copy_until 0x4ea0
skip 1  ; 70
db 0x5c
copy_until 0x4ea6
skip 1  ; 2a
db 0x16
copy_until 0x4f06
skip 1  ; 78
db 0x8c
copy_until 0x4f09
skip 1  ; 6c
db 0x80
copy_until 0x4f44
skip 2  ; f8 2c
db 0x0c, 0x2d
copy_until 0x4f55
skip 2  ; f8 2c
db 0x0c, 0x2d
copy_until 0x4f76
skip 1  ; fb
db 0xe7
copy_until 0x4f98
skip 2  ; f8 2c
db 0x0c, 0x2d
copy_until 0x4fa8
skip 1  ; 78
db 0x8c
copy_until 0x4fcc
skip 1  ; 78
db 0x8c
copy_until 0x4fe2
skip 1  ; 78
db 0x8c
copy_until 0x504f
skip 1  ; 29
db 0x3d
copy_until 0x5056
skip 1  ; 29
db 0x3d
copy_until 0x505d
skip 1  ; 2a
db 0x3e
copy_until 0x5062
skip 1  ; 25
db 0x39
copy_until 0x506c
skip 1  ; 22
db 0x36
copy_until 0x5076
skip 1  ; 2a
db 0x3e
copy_until 0x507d
skip 1  ; 29
db 0x3d
copy_until 0x5087
skip 1  ; 2a
db 0x3e
copy_until 0x508e
skip 1  ; 23
db 0x37
copy_until 0x509c
skip 1  ; 04
db 0x18
copy_until 0x50a0
skip 1  ; 13
db 0x27
copy_until 0x50a9
skip 1  ; 23
db 0x37
copy_until 0x50b4
skip 1  ; 04
db 0x18
copy_until 0x50bb
skip 1  ; 25
db 0x39
copy_until 0x50ca
skip 1  ; 27
db 0x3b
copy_until 0x50d6
skip 1  ; 25
db 0x39
copy_until 0x5128
skip 1  ; 33
db 0x47
copy_until 0x515c
skip 1  ; 27
db 0x3b
copy_until 0x5163
skip 1  ; 27
db 0x3b
copy_until 0x516a
skip 1  ; 25
db 0x39
copy_until 0x5173
skip 1  ; 25
db 0x39
copy_until 0x5182
skip 1  ; 23
db 0x37
copy_until 0x518b
skip 1  ; 2c
db 0x40
copy_until 0x5195
skip 1  ; 31
db 0x45
copy_until 0x519a
skip 1  ; 2e
db 0x42
copy_until 0x51aa
skip 1  ; 13
db 0x27
copy_until 0x51b1
skip 1  ; 04
db 0x18
copy_until 0x51b4
skip 1  ; 13
db 0x27
copy_until 0x51c4
skip 1  ; 23
db 0x37
copy_until 0x51dd
skip 1  ; ca
db 0xde
copy_until 0x51f5
skip 1  ; 2d
db 0x41
copy_until 0x51f7
skip 1  ; 2d
db 0x41
copy_until 0x51f9
skip 1  ; 2d
db 0x41
copy_until 0x51fb
skip 1  ; 0f
db 0x23
copy_until 0x5201
skip 1  ; 2d
db 0x41
copy_until 0x5203
skip 1  ; 2d
db 0x41
copy_until 0x520d
skip 1  ; 2f
db 0x43
copy_until 0x5239
skip 1  ; 3d
db 0x51
copy_until 0x5242
skip 1  ; 02
db 0x16
copy_until 0x5248
skip 4  ; 00 00 00 00
copy_until 0x5a90
skip 1  ; 60
db 0x61
copy_until 0x5b26
skip 1  ; 60
db 0x61
copy_until 0x5bbc
skip 1  ; 60
db 0x61
copy_until 0x6caa
skip 1  ; 60
db 0x61
copy_until 0x6cae
skip 1  ; 60
db 0x61
copy_until 0x6cb2
skip 1  ; 60
db 0x61
copy_until 0x6d28
skip 1  ; 56
db 0x66
copy_until 0x6d34
skip 1  ; 50
db 0x60
copy_until 0x6e2b
skip 1  ; 50
db 0x60
copy_until 0x6ea2
skip 1  ; 02
db 0x16
copy_until 0x6ea6
skip 1  ; 6e
db 0x82
copy_until 0x6eac
skip 1  ; 70
db 0x84
copy_until 0x7213
skip 1  ; c8
db 0xdc
copy_until 0x733e
skip 1  ; 31
db 0x45
copy_until 0x73d6
skip 1  ; 29
db 0x3d
copy_until 0x740d
skip 1  ; 29
db 0x3d
copy_until 0x74b2
skip 1  ; 6e
db 0x82
copy_until 0x74b9
skip 1  ; 70
db 0x84
copy_until 0x76a9
skip 1  ; 40
db 0x50
copy_until 0x76ba
skip 1  ; 00
db 0x14
copy_until 0x76d3
skip 1  ; 00
db 0x14
copy_until 0x7708
skip 1  ; 50
db 0x60
copy_until 0x7747
skip 1  ; 50
db 0x60
copy_until 0x7821
skip 1  ; 6e
db 0x82
copy_until 0x7827
skip 1  ; 70
db 0x84
copy_until 0x7a3b
skip 1  ; 2c
db 0x40
copy_until 0x7dcf
skip 1  ; dd
db 0xf1
copy_until 0x851b
skip 1  ; 31
db 0x45
copy_until 0x8534
skip 1  ; 31
db 0x45
copy_until 0x9a1f
skip 1  ; 28
db 0x3c
copy_until 0x9a23
skip 1  ; 2a
db 0x3e
copy_until 0x9c5f
skip 1  ; 04
db 0x18
copy_until 0x9c63
skip 1  ; 06
db 0x1a
copy_until 0x9c6b
skip 1  ; 20
db 0x34
copy_until 0x9c6f
skip 1  ; 22
db 0x36
copy_until 0x9c76
skip 1  ; 08
db 0x1c
copy_until 0x9c7a
skip 1  ; 0a
db 0x1e
copy_until 0x9c7e
skip 1  ; 0c
db 0x20
copy_until 0xa745
skip 1  ; 60
db 0x61
copy_until 0xa749
skip 1  ; 60
db 0x61
copy_until 0xa74d
skip 1  ; 60
db 0x61
copy_until 0xaa6c
skip 1  ; 00
db 0x14
copy_until 0xaa76
skip 1  ; 00
db 0x14
copy_until 0xaa7c
skip 1  ; 00
db 0x14
copy_until 0xaa80
skip 1  ; 30
db 0x44
copy_until 0xab20
skip 1  ; 31
db 0x45
copy_until 0xab2a
skip 1  ; 31
db 0x45
copy_until 0xac23
skip 1  ; 74
db 0x88
copy_until 0xb373
skip 1  ; 32
db 0x46
copy_until 0xb37e
skip 1  ; 80
db 0x94
copy_until 0xb65e
skip 1  ; 74
db 0x88
copy_until 0xb69b
skip 1  ; 74
db 0x88
copy_until 0xb7e3
skip 1  ; 29
db 0x3d
copy_until 0xbb2e
skip 1  ; 03
db 0x17
copy_until 0xbb44
skip 1  ; 00
db 0x14
copy_until 0xbbe6
skip 1  ; 29
db 0x3d
copy_until 0xbcd3
skip 1  ; 72
db 0x86
copy_until 0xbcd9
skip 1  ; 76
db 0x8a
copy_until 0xbcec
skip 1  ; 74
db 0x88
copy_until 0xbcf8
skip 1  ; 72
db 0x86
copy_until 0xbe2b
skip 1  ; 31
db 0x45
copy_until 0xbe30
skip 1  ; 31
db 0x45
copy_until 0xda97
skip 1  ; 31
db 0x45
copy_until 0xedb6
skip 1  ; 10
db 0x24
copy_until 0xedd6
skip 1  ; 10
db 0x24
copy_until 0xf4f0
skip 1  ; 6c
db 0x80
copy_until 0x104c1
skip 1  ; 2a
db 0x3e
copy_until 0x107d4
skip 1  ; b9
db 0xcd
copy_until 0x2e3f0
skip 0x10  ; NULs before MSDCM.
incbin ORIG_IO_FN, ifofs
