Import-Module Hyper-V

$ethernet = Get-NetAdapter -Name ethernet
New-VMSwitch -Name virtualPFC -NetAdapterName $ethernet.Name -AllowManagementOS $true -Notes 'Virtual switch for thesis development'



#Import-Module Hyper-V
#Remove-VMSwitch "virtualPFC"
