# Partially based off https://github.com/d4rksystem/VBoxCloak/blob/master/VBoxCloak.ps1

function Test-Administrator  
{  
    $user = [Security.Principal.WindowsIdentity]::GetCurrent();
    (New-Object Security.Principal.WindowsPrincipal $user).IsInRole([Security.Principal.WindowsBuiltinRole]::Administrator)  
}

function Get-ItemProperty2 {
  #https://stackoverflow.com/a/54618711/315482
  param([parameter(ValueFromPipeline)]$key)
  process {
    $key.getvaluenames() | foreach-object {
      $value = $_
      [pscustomobject] @{
        Path = $Key -replace 'HKEY_CURRENT_USER',
          'HKCU:' -replace 'HKEY_LOCAL_MACHINE','HKLM:'
        Name = $Value
        Value = $Key.GetValue($Value)
        Type = $Key.GetValueKind($Value)
      }
    }
  }
}


function GetUserInputandVerify {
	[CmdletBinding()]
    param (
        [string]$Prompt,
        [string]$Default
    )
    
	$ok = "n"

    if($Default.Length -gt 0){
        $Prompt += " ($Default)"
    }
	
	while($ok -ne "y")
	{

		$result = Read-Host -Prompt $Prompt
		
        if($result.Length -eq 0 -and $Default.Length -gt 0){
            $result = $Default
        }

		$ok = Read-Host -Prompt "You entered: $result`nDoes this look right (y/n)"
	}

	return $result
}

if ( -not (Test-Administrator) )
{
	Write-Host "You must run this script as an Admin"
	[Environment]::Exit(1)
}

Write-Host "Please answer the follwing questions (Blank for shown default):"


$ComputerCompany = GetUserInputandVerify -Prompt "Enter PC Company" -Default "Hewlett-Packard"
$ComputerModel = GetUserInputandVerify -Prompt "Enter PC Model" -Default "M01-F0033w"
$BIOSVersion = GetUserInputandVerify -Prompt "Enter Full BIOS Company and Version String" -Default "Phoenix Technologies LTD MP11.88z.005C.B09.0707251237"
$BIOSDate = GetUserInputandVerify -Prompt "Enter BIOS Date (MM/DD/YY)" -Default "09/01/18"
$ProcessorCompany = GetUserInputandVerify -Prompt "Enter Processor Company Name" -Default "AMD"
$ProcessorVersion = GetUserInputandVerify -Prompt "Enter Full Processor Company and Version String" -Default "AMD Ryzen 3 3100"
$VideoCardCompany = GetUserInputandVerify -Prompt "Enter Video Card Company Name" -Default "Intel"
$VideoCardVersion = GetUserInputandVerify -Prompt "Enter Full Video Card Company and Version String" -Default "Intel UHD Graphics 620"
$HardriveVersion = GetUserInputandVerify -Prompt "Enter Hardrive Company and Version String" -Default "SONY SATA 128GB"
$DVDVersion = GetUserInputandVerify -Prompt "Enter DVD Drive Company and Version String" -Default "Liteon DVD-RW 320G"
$MouseVersion = GetUserInputandVerify -Prompt "Enter Full Mouse Company and Version String" -Default "Razer G690"


<#
$ComputerCompany = "Hewlett-Packard"
$ComputerModel = "M01-F0033w"
$BIOSVersion = "Phoenix Technologies LTD MP11.88z.005C.B09.0707251237"
$BIOSDate = "09/01/18"
$ProcessorCompany = "AMD"
$ProcessorVersion = "AMD Ryzen 3 3100"
$VideoCardCompany = "Intel"
$VideoCardVersion = "Intel UHD Graphics 620"
$HardriveVersion =  "SONY SATA 128GB"
$DVDVersion = "Liteon DVD-RW 320G"
$MouseVersion = "Razer G690"
#>


if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosVersion" -ErrorAction SilentlyContinue) {
	Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\SystemBiosVersion..."
	Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosVersion" -Value $BIOSVersion
}

if (Get-Item -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -ErrorAction SilentlyContinue) {
	Write-Output "[*] Modifying Reg Key Values in HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation..."
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSVersion" -Value $BIOSVersion
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSReleaseDate" -Value $BIOSDate
	Set-ItemProperty -Path "HKLM:\SYSTEM\CurrentControlSet\Control\SystemInformation" -Name "BIOSProductName" -Value $BIOSVersion
}

if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosDate" -ErrorAction SilentlyContinue) {
	Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\SystemBiosDate"
	Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "SystemBiosDate" -Value $BIOSDate
}

if (Get-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "VideoBiosVersion" -ErrorAction SilentlyContinue) {
	Write-Output "[*] Modifying Reg Key HKLM:\HARDWARE\Description\System\VideoBiosVersion"
	Set-ItemProperty -Path "HKLM:\HARDWARE\Description\System" -Name "VideoBiosVersion" -Value $VideoCardVersion
}

ls -r "HKLM:\SYSTEM\ControlSet001\Enum" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where value -eq '{4d36e967-e325-11ce-bfc1-08002be10318}' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "FriendlyName" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\FriendlyName"
		Set-ItemProperty -Path $key -Name "FriendlyName" -Value $HardriveVersion
	}
}

ls -r "HKLM:\SYSTEM\ControlSet001\Enum" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where value -eq '{4d36e968-e325-11ce-bfc1-08002be10318}' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "DeviceDesc" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\DeviceDesc"
		Set-ItemProperty -Path $key -Name "DeviceDesc" -Value $VideoCardVersion
	}
}

ls -r "HKLM:\SYSTEM\ControlSet001\Enum" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where value -eq '{4d36e965-e325-11ce-bfc1-08002be10318}' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "DeviceDesc" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\DeviceDesc"
		Set-ItemProperty -Path $key -Name "DeviceDesc" -Value $DVDVersion
	}
	
	if (Get-ItemProperty -Path $key -Name "FriendlyName" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\FriendlyName"
		Set-ItemProperty -Path $key -Name "FriendlyName" -Value $DVDVersion
	}
}

ls -r "HKLM:\HARDWARE\DESCRIPTION\System\CentralProcessor" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where name -eq 'ProcessorNameString' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "ProcessorNameString" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\ProcessorNameString"
		Set-ItemProperty -Path $key -Name "ProcessorNameString" -Value $ProcessorVersion
	}
}

ls -r "HKLM:\SYSTEM\ControlSet001\Enum" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where value -eq '{50127dc3-0f36-415e-a6cc-4cb3be910b65}' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "DeviceDesc" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\DeviceDesc"
		Set-ItemProperty -Path $key -Name "DeviceDesc" -Value $ProcessorVersion
	}
	
	if (Get-ItemProperty -Path $key -Name "FriendlyName" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\FriendlyName"
		Set-ItemProperty -Path $key -Name "FriendlyName" -Value $ProcessorVersion
	}
}

ls -r "HKLM:\SYSTEM\ControlSet001\Enum" -ErrorAction SilentlyContinue | Get-ItemProperty2 | where value -eq '{4d36e96f-e325-11ce-bfc1-08002be10318}' | foreach-object {
	$key = $_.Path.ToString()
	
	if (Get-ItemProperty -Path $key -Name "DeviceDesc" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\DeviceDesc"
		Set-ItemProperty -Path $key -Name "DeviceDesc" -Value $MouseVersion
	}
	
	if (Get-ItemProperty -Path $key -Name "FriendlyName" -ErrorAction SilentlyContinue) {
		Write-Output "[*] Modifying Reg Key $key\FriendlyName"
		Set-ItemProperty -Path $key -Name "FriendlyName" -Value $MouseVersion
	}
}