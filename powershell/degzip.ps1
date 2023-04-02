# original code from cosial.technet.microsoft.com.
# https://social.technet.microsoft.com/Forums/windowsserver/en-US/5aa53fef-5229-4313-a035-8b3a38ab93f5/unzip-gz-files-using-powershell?forum=winserverpowershell

$infile = $args[0]
$outfile = ($infile -replace '\.gz$', '')

$input = New-Object System.IO.FileStream $inFile, ([IO.FileMode]::Open), ([IO.FileAccess]::Read), ([IO.FileShare]::Read)
$output = New-Object System.IO.FileStream $outFile, ([IO.FileMode]::Create), ([IO.FileAccess]::Write), ([IO.FileShare]::None)
$gzipStream = New-Object System.IO.Compression.GzipStream $input, ([IO.Compression.CompressionMode]::Decompress)

$buffer = New-Object byte[](1024)
while($true) {
    $read = $gzipstream.Read($buffer, 0, 1024)
    if ($read -le 0){break}
    $output.Write($buffer, 0, $read)
}

$gzipStream.Close()
$output.Close()
$input.Close()
