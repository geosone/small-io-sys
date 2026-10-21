;
; lang.inc: language-dependent parts of patchio98se.nasm and ucio98se.nasm
;
; Without -DLANG_DE, the input file is the English winboot.98s of KB311561.
; With -DLANG_DE, it is the German winboot.98d built by kb311561de.nasm. Its
; code is at the same file offsets as in winboot.98s, only the messages (and
; the MPAD runs after them) are at different offsets.
;
; With -DMSDOS71 (only together with -DLANG_DE), the messages say MS-DOS 7.1
; instead of Windows 98, as on the MS-DOS 7.1 boot disks.
;

%ifdef LANG_DE
  %define ORIG_IO_FN 'winboot.98d'
  %assign ORIG_LASTSIZE 0xb6  ; MZ header: .lastsize, .ss and .cs (of MSDCM).
  %assign ORIG_SS 0x827
  %assign ORIG_CS 0x7e5
  %assign FOFS_MPAD1 0x54ca  ; `times 0x8e db 'MPAD'`, until 0x5702.
  %assign FOFS_MSG_REG 0x1131b  ; db 'Systemregistrierung verarbeiten [Eingabe=J,Esc=N]?$', 0
  %assign FOFS_MSG_REG_END 0x1134f
  %assign FOFS_MSG_DCM 0x1169d  ; db 'Achtung: Der Systemkonfigurations-Manager konnte nicht gestartet werden.', 13, 10, ...
  %assign FOFS_MSG_DCM_END 0x11736
  %assign FOFS_MPAD2 0x11de5  ; `times 0x41b db 'MPAD'`, until 0x12e51.
  %assign FOFS_EOF 0x364b6  ; sha256sum is: fa2fe238ffcb30aae852a7bedae6845d55c798fec4426059e59fb540714037e6  winboot.98d
%else
  %define ORIG_IO_FN 'winboot.98s'
  %assign ORIG_LASTSIZE 0x1ce  ; MZ header: .lastsize, .ss and .cs (of MSDCM).
  %assign ORIG_SS 0x838
  %assign ORIG_CS 0x7f6
  %assign FOFS_MPAD1 0x54c2  ; `times 0x90 db 'MPAD'`, until 0x5702.
  %assign FOFS_MSG_REG 0x112a5  ; db 'Process the system registry [Enter=Y,Esc=N]?$', 0
  %assign FOFS_MSG_REG_END 0x112d3
  %assign FOFS_MSG_DCM 0x115ed  ; db 'Warning: the system configuration manager failed to run.', 13, 10, ...
  %assign FOFS_MSG_DCM_END 0x1166d
  %assign FOFS_MPAD2 0x11c49  ; `times 0x47e db 'MPAD'`, until 0x12e51.
  %assign FOFS_EOF 0x365ce  ; sha256sum is: d34436a7ce911ed39549fce6107f3b55ad5d413565ebabc1398e13f2df103271  winboot.98s
  %ifdef MSDOS71
    %error MSDOS71_NEEDS_LANG_DE
    db 1/0
  %endif
%endif

%macro patch_msdos71_texts 0  ; Only for LANG_DE. Same changes as on the MS-DOS 7.1 boot disks.
  patch_fofs 0x10a34, db, 'Diese Windows', ' Diese MS-DOS'  ; ...-Version erfordert einen 386-Prozessor oder hoeher.
  patch_fofs 0x10ab3, db, 'Windows 98', 'MS-DOS 7.1'  ; ... wird gestartet...
  patch_fofs 0x10ad5, db, 'Windows 98', 'MS-DOS 7.1'  ; ... startet jetzt das Programm fuer MS-DOS.
  patch_fofs 0x10b0c, db, 'Windows 98', 'MS-DOS 7.1'  ; ... wird neu gestartet...
  patch_fofs 0x10b67, db, 'Windows 98', 'MS-DOS 7.1'  ; Druecken Sie Esc, um den MS-DOS-Modus abzubrechen und ... neu zu starten.
  patch_fofs 0x10fc6, db, 'Windows 98', 'MS-DOS 7.1'  ; Microsoft ... Startmenue
  patch_fofs 0x10ffe, db, '--', '  '  ; Underline of the start menu title.
  patch_fofs 0x110c2, db, 'WINDOWS\COMMAND.COM)', 'DOS\COMMAND.COM)    '  ; Geben Sie den Namen des Befehlsinterpreters ein (z.B. C:\...
%endm
