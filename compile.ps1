<#
.SYNOPSIS
    compile.ps1: build IO.SYS.win98sekbpc (without the logo and MSDCM,
    compressed with aPACK) on Linux and Windows, with PowerShell 5.1 or 7.

.DESCRIPTION
    The same steps as compile.sh for this file, without busybox and Perl
    (io7pack.pl is done here, only its aPACK part):

    * en: winboot.98s of KB311561 (311561usa8.exe is downloaded).
    * de: winboot.98d (kb311561de.nasm) from winboot.sys of the German
      Windows 98 SE CD, in the directory de/: copy WIN98\PRECOPY1.CAB and
      WIN98\PRECOPY2.CAB of the CD (or winboot.sys and command.com from
      them) to de/ first. command.com is extracted too.

    Tools: on Linux the ones in tools/; on Windows nasm 3.02 (nasm.us;
    2.16 encodes some instructions differently) and apack1p.exe
    (github.com/pts/apack1p release v1), downloaded once to tools/win/,
    and expand.exe of Windows.

.EXAMPLE
    pwsh compile.ps1 de
#>
param(
    [ValidateSet('en', 'de')][string]$Lang = 'en'
)
$ErrorActionPreference = 'Stop'

$onWindows = [Environment]::OSVersion.Platform -eq 'Win32NT'
$top = $PSScriptRoot
$work = if ($Lang -eq 'de') { Join-Path $top 'de' } else { $top }
if (-not (Test-Path -LiteralPath $work)) { New-Item -ItemType Directory -Path $work | Out-Null }

function Test-Sha256([string]$path, [string]$sha256) {
    $h = (Get-FileHash -LiteralPath $path -Algorithm SHA256).Hash.ToLowerInvariant()
    if ($h -ne $sha256) { throw "Bad SHA-256 of ${path}: $h, expected $sha256" }
}

function Get-Download([string]$url, [string]$path, [string]$sha256) {
    if (-not (Test-Path -LiteralPath $path)) {
        Write-Host "info: downloading $url"
        [Net.ServicePointManager]::SecurityProtocol = [Net.ServicePointManager]::SecurityProtocol -bor [Net.SecurityProtocolType]::Tls12
        Invoke-WebRequest -Uri $url -OutFile "$path.tmp" -UseBasicParsing
        Test-Sha256 "$path.tmp" $sha256
        Move-Item -LiteralPath "$path.tmp" -Destination $path
    }
    Test-Sha256 $path $sha256
}

function Invoke-Tool([string]$prog, [string[]]$arguments) {
    Write-Host "+ $prog $($arguments -join ' ')"
    & $prog @arguments
    if ($LASTEXITCODE) { throw "$prog failed (exit code $LASTEXITCODE)" }
}

# --- tools --------------------------------------------------------------------

if ($onWindows) {
    $win = Join-Path $top 'tools/win'
    if (-not (Test-Path -LiteralPath $win)) { New-Item -ItemType Directory -Path $win | Out-Null }
    $nasm = Join-Path $win 'nasm.exe'
    if (-not (Test-Path -LiteralPath $nasm)) {
        $zip = Join-Path $win 'nasm-3.02-win32.zip'
        Get-Download 'https://www.nasm.us/pub/nasm/releasebuilds/3.02/win32/nasm-3.02-win32.zip' $zip 'dca7d736580aafcf88a07838bb597a4f093fa157e56ce522891e86ab0a37c949'
        Add-Type -AssemblyName System.IO.Compression.FileSystem
        $z = [IO.Compression.ZipFile]::OpenRead($zip)
        try {
            $e = $z.Entries | Where-Object { $_.FullName -eq 'nasm-3.02/nasm.exe' }
            [IO.Compression.ZipFileExtensions]::ExtractToFile($e, $nasm)
        } finally { $z.Dispose() }
    }
    $apack1p = Join-Path $win 'apack1p.exe'
    Get-Download 'https://github.com/pts/apack1p/releases/download/v1/apack1p.exe' $apack1p '84f6bc452ecd1755cd38a8c93e77a075d4403cd8630ed6593782804e123b9234'
} else {
    $nasm = Join-Path $top 'tools/nasm-0.98.39.upx'
    $apack1p = Join-Path $top 'tools/apack1p-1.00.upx'
    $cabextract = Join-Path $top 'tools/cabextract-1.11.upx'
}

# extracts $name from the cabinet $cab (continued in the next ones) into $work
function Expand-Cab([string]$cab, [string]$name) {
    if ($onWindows) {
        Invoke-Tool (Join-Path $env:SystemRoot 'System32/expand.exe') @("-F:$name", $cab, $work)
    } else {
        Push-Location -LiteralPath $work
        try { Invoke-Tool $cabextract @('-q', '-F', $name, $cab) } finally { Pop-Location }
    }
    if (-not (Test-Path -LiteralPath (Join-Path $work $name))) { throw "$name not found in $cab" }
}

# runs nasm in $work (incbin paths are relative to it), with the language flags
function Invoke-Nasm([string]$source, [string]$output, [string[]]$defines = @()) {
    $flags = @('-O0', '-w+orphan-labels', '-f', 'bin')
    if ($Lang -eq 'de') { $flags += '-DLANG_DE', '-DMSDOS71', "-i$top/" }
    Push-Location -LiteralPath $work
    try { Invoke-Tool $nasm ($flags + $defines + @('-o', $output, (Join-Path $top $source))) } finally { Pop-Location }
}

# --- original io.sys ---------------------------------------------------------------

if ($Lang -eq 'de') {
    $orig = 'winboot.98d'
    foreach ($n in 'winboot.sys', 'command.com') {
        if (-not (Test-Path -LiteralPath (Join-Path $work $n))) { Expand-Cab 'PRECOPY1.CAB' $n }
    }
    Test-Sha256 (Join-Path $work 'winboot.sys') '33c946c67780f0da704128c72b733d1fc0e36132d7a7944ef2d18d635d4545b8'
    Test-Sha256 (Join-Path $work 'command.com') '47a37d865c601a9058a73f16816bb26b77b18881a2ee395290eca1d423e9dfae'
    Invoke-Nasm 'kb311561de.nasm' $orig
    Test-Sha256 (Join-Path $work $orig) 'fa2fe238ffcb30aae852a7bedae6845d55c798fec4426059e59fb540714037e6'
} else {
    $orig = 'winboot.98s'
    if (-not (Test-Path -LiteralPath (Join-Path $work $orig))) {
        $exe = Join-Path $work '311561usa8.exe'
        Get-Download 'https://web.archive.org/web/20020204073516id_/http://download.microsoft.com/download/win98/patch/22527/w98/en-us/311561usa8.exe' $exe '569ecb4fe36a7c00bf7f6d353467d8f95e4708fb8809d3e456760a8ef42be6fc'
        # the cabinet in the self-extracting .exe (also for expand.exe)
        $b = [IO.File]::ReadAllBytes($exe)
        $cab = Join-Path $work '311561usa8.cab'
        $cb = New-Object byte[] 222099
        [Array]::Copy($b, 67224, $cb, 0, $cb.Length)
        [IO.File]::WriteAllBytes($cab, $cb)
        Expand-Cab $cab $orig
        Remove-Item -LiteralPath $cab
    }
    Test-Sha256 (Join-Path $work $orig) 'd34436a7ce911ed39549fce6107f3b55ad5d413565ebabc1398e13f2df103271'
}

# --- patch ---------------------------------------------------------------------

Invoke-Nasm 'patchio98se.nasm' 'IO.SYS.win98sekb' @('-DNOPATCH')
if ([Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $work 'IO.SYS.win98sekb'))) -ne
    [Convert]::ToBase64String([IO.File]::ReadAllBytes((Join-Path $work $orig)))) {
    throw "IO.SYS.win98sekb (patchio98se.nasm -DNOPATCH) differs from $orig"
}
Invoke-Nasm 'msloadv7i.nasm' 'msloadv7is0.bin' @('-DMSLOAD_SECTOR_COUNT=0', '-DJUST_MSLOAD')
Invoke-Nasm 'patchio98se.nasm' 'IO.SYS.win98sekbp' @('-DMSLOAD_SECTOR_COUNT=0', '-DOPTIMIZE_FOR_COMPRESSION')

# --- compress: io7pack.pl --apack1p=... --ignores-logo, without MSDCM ---------------

function Get-Word([byte[]]$b, [int]$i) { return [int]$b[$i] -bor ([int]$b[$i + 1] -shl 8) }
function Set-Word([byte[]]$b, [int]$i, [int]$v) { $b[$i] = [byte]($v -band 0xff); $b[$i + 1] = [byte](($v -shr 8) -band 0xff) }
function Get-Ascii([byte[]]$b, [int]$i, [int]$n) { return [Text.Encoding]::GetEncoding(28591).GetString($b, $i, $n) }
function Find-Bytes([byte[]]$b, [byte[]]$s, [int]$limit) {
    for ($i = 0; $i -le $limit - $s.Length; $i++) {
        $j = 0
        while ($j -lt $s.Length -and $b[$i + $j] -eq $s[$j]) { $j++ }
        if ($j -eq $s.Length) { return $i }
    }
    return -1
}

$infn = Join-Path $work 'IO.SYS.win98sekbp'
$outfn = Join-Path $work 'IO.SYS.win98sekbpc'
$b = [IO.File]::ReadAllBytes($infn)
if ((Get-Ascii $b 0 2) -ne 'MZ' -or (Get-Ascii $b 0x200 2) -ne 'BJ') { throw "not an io.sys file: $infn" }
$msloadsize = if ((Get-Ascii $b (0x340 - 4) 4) -eq 'ML7I') { 0x340 } elseif ((Get-Ascii $b (0x400 - 4) 4) -eq 'ML7I') { 0x400 } else { 0 }
if (-not $msloadsize) { throw "missing ML7I msload in io.sys file: $infn" }
$h = @(for ($i = 2; $i -lt 0x18; $i += 2) { Get-Word $b $i })  # lastsize nblocks nreloc hdrsize minalloc maxalloc ss sp checksum ip cs
if ($h[2]) { throw "bad MZ nreloc: $infn" }
if ($h[1] -or $h[0] -or $h[4] -or $h[5] -or $h[6] -or $h[7] -or $h[9] -or $h[10]) { throw "MSDCM not supported: $infn" }
$hdrsize = $h[3]
if ((($b.Length + 0xf) -shr 4) -lt $hdrsize) { throw "MZ hdrsize too large: $infn" }
$insize = [Math]::Min($b.Length, $hdrsize -shl 4)
$u = New-Object byte[] $insize
[Array]::Copy($b, $u, $insize)
$msload = New-Object byte[] $msloadsize
[Array]::Copy($u, $msload, $msloadsize)
$rbsegFofs = 0x1a
if ($msload[0x18] -ne 0xfc -or $msload[0x19] -ne 0xb8) { throw "bad reloc-base-segment code: $infn" }  # cld ++ mov ax, RELOC_BASE_SEGMENT.
$rbseg = Get-Word $msload $rbsegFofs
if ($rbseg -lt 0x3400 -or $rbseg -gt 0x5000) { throw "bad reloc-base-segment value: $infn" }
$vfcsFofs = Find-Bytes $msload ([byte[]](0x5b, 0x5b, 0xeb, 0x09, 0x90)) $msloadsize  # pop bx ++ pop bx ++ jmp short initialized_data.end ++ nop.
if ($vfcsFofs -lt 0 -or $vfcsFofs -gt 0x80) { throw "initialized_data not found in msload: $infn" }
$vfcsFofs += 5 + 4 + 2
if ((Get-Word $msload $vfcsFofs) -ne $rbseg + 0xc0 - 0x10 + $(if ($msloadsize -eq 0x340) { 0x40 } else { 0 })) {
    throw "bad var_fat_cache_segment value in msload: $infn"
}
# MZ header for aPACK: no relocations, entry 0:0
for ($i = 2; $i -lt 0x18; $i += 2) { Set-Word $u $i 0 }
Set-Word $u 2 ($insize -band 0x1ff)
Set-Word $u 4 (($insize + 0x1ff) -shr 9)
Set-Word $u 8 ($msloadsize -shr 4)

# apack1p takes arguments starting with / for switches: relative names in $work
$ufn = Join-Path $work 'apack1.tmp'
$cfn = Join-Path $work 'apack2.tmp'
foreach ($f in $ufn, $cfn) { if (Test-Path -LiteralPath $f) { Remove-Item -LiteralPath $f } }
[IO.File]::WriteAllBytes($ufn, $u)
Push-Location -LiteralPath $work
try { Invoke-Tool $apack1p @('-q', '-1', 'apack1.tmp', 'apack2.tmp') } finally { Pop-Location }
if (-not (Test-Path -LiteralPath $cfn)) { throw "apack1p wrote no output" }
$c = [IO.File]::ReadAllBytes($cfn)
Remove-Item -LiteralPath $ufn, $cfn
$outsizeEstimate = $c.Length + 6 - 0xb

if ((Get-Ascii $c 0 2) -ne 'MZ' -or $c.Length -lt 0x22 + 1 + 0xb) { throw "bad compressed output" }
$ch = @(for ($i = 2; $i -lt 0x1a; $i += 2) { Get-Word $c $i })  # lastsize nblocks nreloc hdrsize minalloc maxalloc ss sp checksum ip cs relocpos
$chdrsize = $ch[3]
if ($chdrsize -ne 2 -or $ch[10] -ne 0 -or $ch[9] -ne 0) { throw "bad hdrsize, cs or ip in compressed output" }
$expectedCsize = $(if ($ch[0] -band 0x1ff) { $ch[0] -band 0x1ff } else { 0x200 }) + (($ch[1] - 1) -shl 9)
if ($c.Length -ne $expectedCsize) { throw "bad compressed output size" }
if ($ch[2] -ne 1 -or $ch[11] -ne 0x1c) { throw "bad nreloc or relocpos in compressed output" }
$relocFofs = ($chdrsize -shl 4) + ((Get-Word $c 0x1e) -shl 4) + (Get-Word $c 0x1c)
if ($expectedCsize - $relocFofs -ne 2) { throw "bad reloc0 fofs in compressed output" }  # the segment of the final `jmp 0:0'
# +0x70 is msbio base segment; +0xa is stack space (0xa0 bytes); -0x60 is
# to compensate for the offsets (+0x700 for temporary stack, +0x800 for
# relocated msload).
$minRbseg = ($ch[1] -shl 5) - $chdrsize + $ch[4] + 0x70 + 0xa - 0x60
if ($rbseg -lt $minRbseg) {
    $vfcs = (Get-Word $msload $vfcsFofs) + ($minRbseg - $rbseg)
    if ((($vfcs + 0x10) -band 0xfff) -gt 0xfe0) { $vfcs = (($vfcs + 0x10) -band (-bnot 0xfff)) + 0x20 - 0x10 }  # no sector read across a 64 KiB boundary
    Write-Host ("info: increasing rbseg: old=0x{0:x} new=0x{1:x} new_vfcs=0x{2:x}" -f $rbseg, $minRbseg, $vfcs)
    Set-Word $msload $rbsegFofs $minRbseg
    Set-Word $msload $vfcsFofs $vfcs
}
if ($c[$chdrsize -shl 4] -ne 0x1e -or $c[($chdrsize -shl 4) + 1] -ne 0x06) { throw "unexpected aPACK starter code bytes" }  # push ds ++ push es
# pop es ++ pop ds ++ mov ss, ax ++ xor sp, sp ++ jmp 0:0
$trailer = -join ($c[($c.Length - 0xb)..($c.Length - 1)] | ForEach-Object { '{0:x2}' -f $_ })
if ($trailer -ne '071f8ed033e4ea00000000') { throw "unexpected aPACK trailer code bytes: $trailer" }
$c[$chdrsize -shl 4] = 0x60; $c[($chdrsize -shl 4) + 1] = 0x90  # pusha ++ nop
$body = New-Object byte[] ($c.Length - 0xb + 6)
[Array]::Copy($c, $body, $c.Length - 0xb)
[Array]::Copy([byte[]](0x61, 0xea, 0, 0, 0x70, 0), 0, $body, $c.Length - 0xb, 6)  # popa ++ jmp 0x70:0
if ($body.Length -ne $outsizeEstimate) { throw "bad outsize estimate" }
# msload instead of the MZ header of the compressed output
$out = New-Object byte[] ($msloadsize + $body.Length - ($chdrsize -shl 4))
[Array]::Copy($msload, $out, $msloadsize)
[Array]::Copy($body, $chdrsize -shl 4, $out, $msloadsize, $body.Length - ($chdrsize -shl 4))
for ($i = 2; $i -lt 0x18; $i += 2) { Set-Word $out $i 0 }
Set-Word $out 8 (($out.Length + 0xf) -shr 4)
[IO.File]::WriteAllBytes($outfn, $out)
Write-Host ("info: compressed io.sys {0} ({1} bytes) to {2} ({3} bytes)" -f $infn, $insize, $outfn, $out.Length)
