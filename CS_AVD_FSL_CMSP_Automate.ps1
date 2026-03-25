Invoke-WebRequest -Uri "https://aka.ms/fslogix_download" -OutFile "$env:TEMP\fslogix.zip"
Expand-Archive "$env:TEMP\fslogix.zip" -DestinationPath "$env:TEMP\fslogix" -Force
Start-Process "$env:TEMP\fslogix\x64\Release\FSLogixAppsSetup.exe" -ArgumentList "/install /quiet /norestart" -Wait

New-Item -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Force | Out-Null

New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name Enabled -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name DeleteLocalProfileWhenVHDShouldApply -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name FlipFlopProfileDirectoryName -Value 0 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name PreventLoginWithFailure -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name PreventLoginWithTempProfile -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name RoamIdentity -Value 1 -PropertyType DWORD -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name VolumeType -Value "vhdx" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name VHDLocations -Value "\\csflogixsa.file.core.windows.net\avdusersvhdx" -PropertyType String -Force | Out-Null
New-ItemProperty -Path "HKLM:\SOFTWARE\FSLogix\Profiles" -Name FoldersToRemove -Value @("AppData\Local\Temp") -PropertyType MultiString -Force | Out-Null

Set-Service -Name frxsvc -StartupType Automatic
Restart-Service frxsvc

# Set PowerShell Execution Policy to RemoteSigned
Set-ExecutionPolicy RemoteSigned -Scope Process -Force

# Define URLs for the files hosted in your new GitHub repository
$repoUrl = "https://raw.githubusercontent.com/control-supply/cs-cmsp-automate-agent/main/"
$files = @(
    "Agent_Install.msi",
    "Agent_Install.mst",
    "install.bat"
)

# Define a folder to download the files to
$destinationFolder = "$env:TEMP\Control_Supply_Agent_Files"
if (!(Test-Path -Path $destinationFolder)) {
    New-Item -ItemType Directory -Path $destinationFolder | Out-Null
}

# Download each file from the repository
foreach ($file in $files) {
    $fileUrl = "$repoUrl$file"
    $destinationPath = Join-Path -Path $destinationFolder -ChildPath $file

    Write-Output "Downloading $fileUrl to $destinationPath"
    try {
        Invoke-WebRequest -Uri $fileUrl -OutFile $destinationPath -ErrorAction Stop
    } catch {
        Write-Output "Failed to download $file. Error: $_"
        exit 1
    }
}

# Perform a silent installation using msiexec
$msiFile = Join-Path $destinationFolder "Agent_Install.msi"
$mstFile = Join-Path $destinationFolder "Agent_Install.mst"

if ((Test-Path $msiFile) -and (Test-Path $mstFile)) {
    Write-Output "Performing silent installation of ConnectWise Automate Agent..."
    $installCommand = "msiexec /i `"$msiFile`" TRANSFORMS=`"$mstFile`" /quiet /norestart"
    try {
        Invoke-Expression $installCommand
        Write-Output "Installation completed successfully."
    } catch {
        Write-Output "Error during silent installation. Error: $_"
    }
} else {
    Write-Output "Error: Required files not found in $destinationFolder"
    exit 1
}