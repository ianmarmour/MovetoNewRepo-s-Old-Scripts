if ( !(Get-Module -Name VMware.VimAutomation.Core -ErrorAction SilentlyContinue) ) {
. "C:\Program Files (x86)\VMware\Infrastructure\PowerCLI\Scripts\Initialize-PowerCLIEnvironment.ps1"
}

$securepassword = ConvertTo-SecureString "VMWAREPASSWORDGOESHERE" -AsPlainText -Force
$mycreds = New-Object System.Management.Automation.PScredential("VMWAREvCENTERUSERNAMEandDOMAINHERE",$securepassword)
Connect-VIServer -Server 151.1.193.88 -Credential $mycreds

$oneWeekAgo = (Get-Date).AddDays(-7)
$HBSSVM = Get-VM -Name "YOURHBSSVMNAMEHERE"
Get-Snapshot -VM $HBSSVM | Foreach-Object {
  if($_.Created -gt $oneWeekAgo) {
    Remove-Snapshot $_ -Confirm:$false
    }
}
