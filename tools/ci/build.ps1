if(!(Test-Path -Path "C:/byond")){
    bash tools/ci/download_byond.sh
    [System.IO.Compression.ZipFile]::ExtractToDirectory("C:/byond.zip", "C:/")
    Remove-Item C:/byond.zip
}

bash tools/ci/install_node.sh
bash tgui/bin/tgui --build

&"C:/byond/bin/dm.exe" -max_errors 0 tgstation.dme
exit $LASTEXITCODE
