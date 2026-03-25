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