#! /bin/sh --
#
# compile.sh: compile script for patchio98se
# by pts@fazekas.hu at Wed Jan 29 16:13:54 CET 2025
#
# Run it on Linux i386 or amd64: tools/busybox sh compile.sh
#

test "$0" = "${0%/*}" || cd "${0%/*}"
export LC_ALL=C  # For deterministic output. Typically not needed. Is it too late for Perl?
export TZ=GMT  # For deterministic output. Typically not needed. Perl respects it immediately.
if test "$1" != --sh-script; then export OPATH="$PATH"; export PATH=/dev/null/missing; exec tools/busybox sh "${0##*/}" --sh-script "$@"; exit 1; fi
shift
test "$ZSH_VERSION" && set -y 2>/dev/null  # SH_WORD_SPLIT for zsh(1). It's an invalid option in bash(1), and it's harmful (prevents echo) in ash(1).
set -ex

# With the argument `de', build the German io.sys in the directory de/, from
# winboot.sys of the German Windows 98 SE CD. Copy WIN98\PRECOPY1.CAB and
# WIN98\PRECOPY2.CAB of the CD (or winboot.sys and command.com from them) to
# de/ first.
if test "$1" = de; then
  lang=de; shift; test -d de || mkdir de; cd de; t=../
else
  lang=en; t=
fi

cabextract=${t}tools/cabextract-1.11.upx
perl=${t}tools/miniperl-5.004.04.upx
nasm=${t}tools/nasm-0.98.39.upx
mtools=${t}tools/mtools-4.0.18.upx
apack1p=${t}tools/apack1p-1.00.upx
upx=${t}tools/upx-3.94.upx
unexepack=${t}tools/pts-unexepack-v1.upx

# Downloads:
#
# * https://web.archive.org/web/20221002040438/https://www.allbootdisks.com/disk_files/Win98se/IO.SYS  (old, unpatched)
# * https://web.archive.org/web/20250129012842/https://www.allbootdisks.com/disk_files/Win98se/COMMAND.COM
# * https://web.archive.org/web/20020204073516/http://download.microsoft.com/download/win98/patch/22527/w98/en-us/311561usa8.exe  (contains the patched io.sys of KB311561)
if test "$lang" = de; then
  test -f winboot.sys || "$cabextract" -q -F winboot.sys PRECOPY1.CAB
  test -f command.com || "$cabextract" -q -F command.com PRECOPY1.CAB
  test "$(sha256sum winboot.sys)" = "33c946c67780f0da704128c72b733d1fc0e36132d7a7944ef2d18d635d4545b8  winboot.sys"
  test "$(sha256sum command.com)" = "47a37d865c601a9058a73f16816bb26b77b18881a2ee395290eca1d423e9dfae  command.com"
  "$nasm" -O0 -w+orphan-labels -f bin -o winboot.98d ${t}kb311561de.nasm
  test "$(sha256sum winboot.98d)" = "fa2fe238ffcb30aae852a7bedae6845d55c798fec4426059e59fb540714037e6  winboot.98d"
  orig=winboot.98d
  langflags="-DLANG_DE -DMSDOS71 -i${t}"
elif test -f winboot.98s && test -f command.com; then  # !! Add an option to omit command.com.
  :
else
  # Try to find the non-BusyBox wget(1) on PATH.
  wget="$(set +ex; IFS=: ; for dir in ${OPATH:-$PATH}; do p="$dir/wget" && test -f "$p" && test -x "$p" && printf '%s' "$p" && break; done; :)"
  wget_flags="-nv -O"
  if test -z "$wget"; then  # If wget(1) not found, try curl(1).
    wget="$(set +ex; IFS=: ; for dir in ${OPATH:-$PATH}; do p="$dir/curl" && test -f "$p" && test -x "$p" && printf '%s' "$p" && break; done; :)"
    wget_flags=-sSLfo
  fi
  if ! test -f winboot.98s; then
    if ! test -f 311561usa8.exe; then
      "$wget" $wget_flags 311561usa8.exe.tmp https://web.archive.org/web/20020204073516/http://download.microsoft.com/download/win98/patch/22527/w98/en-us/311561usa8.exe
      test "$(sha256sum 311561usa8.exe.tmp)" = "569ecb4fe36a7c00bf7f6d353467d8f95e4708fb8809d3e456760a8ef42be6fc  311561usa8.exe.tmp"
      mv -f 311561usa8.exe.tmp 311561usa8.exe
    fi
    test "$(sha256sum 311561usa8.exe)" = "569ecb4fe36a7c00bf7f6d353467d8f95e4708fb8809d3e456760a8ef42be6fc  311561usa8.exe"
    # echo "incbin '311561usa8.exe', 67224, 222099" >tc.nasm   # No need for this, cabextract works directly on 311561usa8.exe
    # nasm-0.98.39 -O0 -w+orphan-labels -f bin -o tc.cab tc.nasm  # Input file: 311561usa8.exe
    "$cabextract" -q -F winboot.98s 311561usa8.exe
    test "$(sha256sum winboot.98s)" = "d34436a7ce911ed39549fce6107f3b55ad5d413565ebabc1398e13f2df103271  winboot.98s"
  fi
  if ! test -f command.com; then
    "$wget" $wget_flags command.com.tmp https://web.archive.org/web/20250129012842/https://www.allbootdisks.com/disk_files/Win98se/COMMAND.COM
    test "$(sha256sum command.com.tmp)" = "c3b5899620d6c58b90727b640bb7bb6a723f6013629c9459c241e9dc9e7ff20b  command.com.tmp"
    mv -f command.com.tmp command.com
  fi
fi

if test "$lang" = en; then
  test "$(sha256sum winboot.98s)" = "d34436a7ce911ed39549fce6107f3b55ad5d413565ebabc1398e13f2df103271  winboot.98s"
  test "$(sha256sum command.com)" = "c3b5899620d6c58b90727b640bb7bb6a723f6013629c9459c241e9dc9e7ff20b  command.com"
  orig=winboot.98s
  langflags=
fi

"$nasm" -O0 -w+orphan-labels -f bin -o fd.img -DP_1440K ${t}fat12b.nasm

"$perl" -x ${t}logod.pl --fofs=0x1e010 "$orig" IO.SYS.win98sekb.bmp
"$unexepack" -q "$orig" IO.SYS.win98sekb.msdcm
# pts-unexepack-v1 sets .nblocks 1 too high if the image size is a multiple of 0x200 (German MSDCM).
"$perl" -e 'open(F, "+<$ARGV[0]") or die; binmode(F); read(F, $_, 6) == 6 or die; my($lastsize, $nblocks) = unpack("x2vv", $_); my $size = -s($ARGV[0]); if (!$lastsize and ($nblocks << 9) > $size) { seek(F, 4, 0) or die; print(F pack("v", $size >> 9)) or die } close(F) or die' IO.SYS.win98sekb.msdcm

"$perl" -x ${t}ufepack.pl --upx="$upx" --nasm="$nasm" --186 --filter=0x06 IO.SYS.win98sekb.msdcm IO.SYS.win98sekb.msdcmfx  # Output file IO.SYS.win98sekb.msdcmfx created but not used. The goal is to make it smaller than aPACK output (IO.SYS.win98sekb.msdcmc).

"$apack1p" -q -3 -h IO.SYS.win98sekb.msdcm IO.SYS.win98sekb.msdcmc
"$upx" --no-lzma --no-reloc --ultra-brute --small -f -q -q -q -o IO.SYS.win98sekb.msdcmx IO.SYS.win98sekb.msdcm
"$perl" -e 'if (-s($ARGV[0]) < -s($ARGV[1])) { die if !unlink($ARGV[1]) } else { die if !rename($ARGV[1], $ARGV[0]) }' IO.SYS.win98sekb.msdcmc IO.SYS.win98sekb.msdcmx  # Keep the smaller, --apack1p wins here.

"$nasm" $langflags -DNOPATCH -O0 -w+orphan-labels -f bin -DNOPATCH -o IO.SYS.win98sekb ${t}patchio98se.nasm
cmp "$orig" IO.SYS.win98sekb

#"$nasm" -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=4 -DJUST_MSLOAD -o msloadv7is4.bin msloadv7i.nasm
#"$nasm" -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=2 -DJUST_MSLOAD -o msloadv7is2.bin msloadv7i.nasm
"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -DJUST_MSLOAD -o msloadv7is0.bin ${t}msloadv7i.nasm

#"$nasm" -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=4 -o IO.SYS.win98sekb4 patchio98se.nasm  # Uses msloadv7s4.bin.
#"$nasm" -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=2 -o IO.SYS.win98sekb2 patchio98se.nasm  # Uses msloadv7s2.bin.
"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -o IO.SYS.win98sekb0 ${t}patchio98se.nasm  # Uses msloadv7s0.bin.
"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -DOPTIMIZE_FOR_COMPRESSION -o IO.SYS.win98sekbp ${t}patchio98se.nasm  # Uses msloadv7s0.bin.
"$perl" -x ${t}fixmsdcm.pl IO.SYS.win98sekbp  # No need for fixing, this just does some checks.
"$perl" -x ${t}io7pack.pl --apack1p="$apack1p" --upx="$upx" --ignores-logo IO.SYS.win98sekbp IO.SYS.win98sekbpc
# Even with --filter=6 here, the size of IO.SYS.win98sekbpl would be reduced
# from 70384 to 68955 only (plus the size of the unfilter code), which is
# larger than the size of IO.SYS.win98sekbplx. So if the user has a 386 CPU,
# *plx is not only much faster, but also shorter than *pl.
"$perl" -x ${t}io7pack.pl --upx-lzma="$upx"                 --ignores-logo IO.SYS.win98sekbp IO.SYS.win98sekbpl
# This compressor produces even smaller output than io7pack.pl: IO.SYS.win98sekbplx is ~1900 bytes shorter than IO.SYS.win98sekbpl.
"$perl" -x ${t}upxdc.pl --flat16-386-start=0x70:0 --prefix=0x340 --update-hdrsize --force-lzma --lzma1=-9e,pb=0,lc=4,mf=bt4,nice=120 --filter=6 IO.SYS.win98sekbp IO.SYS.win98sekbplx


"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -o IO.SYS.win98sekbu ${t}ucio98se.nasm  # Uses msloadv7s0.bin.
"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -DOPTIMIZE_FOR_COMPRESSION -o IO.SYS.win98sekbuu ${t}ucio98se.nasm  # Uses msloadv7s40bin.
"$perl" -x ${t}fixmsdcm.pl IO.SYS.win98sekbuu  # No need for fixing, this just does some checks.
"$perl" -x ${t}io7pack.pl --apack1p="$apack1p" --upx="$upx" IO.SYS.win98sekbuu IO.SYS.win98sekbuc
"$perl" -x ${t}io7pack.pl --upx-lzma="$upx"                 IO.SYS.win98sekbuu IO.SYS.win98sekbul

"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -DMSDCM -o IO.SYS.win98sekbum ${t}ucio98se.nasm  # Uses msloadv7s4.bin.
"$perl" -x ${t}fixmsdcm.pl IO.SYS.win98sekbum
"$nasm" $langflags -O0 -w+orphan-labels -f bin -DMSLOAD_SECTOR_COUNT=0 -DMSDCM -DOPTIMIZE_FOR_COMPRESSION -o IO.SYS.win98sekbumu ${t}ucio98se.nasm  # Uses msloadv7s0.bin.
"$perl" -x ${t}fixmsdcm.pl IO.SYS.win98sekbumu  # !! TODO(pts): Combine this with io7pack.pl, to make MSDCM .minalloc smaller.
"$perl" -x ${t}io7pack.pl --apack1p="$apack1p" --upx="$upx" IO.SYS.win98sekbumu IO.SYS.win98sekbumc
"$perl" -x ${t}io7pack.pl --upx-lzma="$upx"                 IO.SYS.win98sekbumu IO.SYS.win98sekbuml

# ---

#"$mtools" -c mcopy -bsomp -i fd.img winboot.98s ::IO.SYS
"$mtools" -c mcopy -bsomp -i fd.img IO.SYS.win98sekbpc ::IO.SYS
"$mtools" -c mattrib -i fd.img +s ::IO.SYS
"$mtools" -c mcopy -bsomp -i fd.img command.com ::COMMAND.COM

: qemu-system-i386 -M pc-1.0 -m 2 -nodefaults -vga cirrus -drive file=fd.img,format=raw,if=floppy -boot a

: "$0" OK.
