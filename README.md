# VBoxRegistryHide

VBoxRegistryHide is a Powershell script to quickly help you change the hardware that is shown in Device Manager, MSINFO32, and DxDiag that is shown in a Virtualbox VM.  

This is primarily useful for Scambaiting, and to a lesser extent malware analysis which has sandbox checks.

To use the tool, download the ps1 file into the VirtualBox VM. Then, from an elevated prompt run it: powershell "gc .\VBoxRegistryHide.ps1 | iex"

Follow the prompts to provide the spoofed hardware.  

This tool can only hide so much.  It will still be possible to determine the VM is a Virtual Machine, but it will survive cursory review.  For more information, including other tools and tricks, please see <TODO Provide Link>
