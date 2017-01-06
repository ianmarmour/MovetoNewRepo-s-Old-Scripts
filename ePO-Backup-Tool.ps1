#CREATE backup of SQL Audit Log and Table
New-Item C:\Backups\DB-Logs -type Directory
New-Item C:\Backups\MSQL-Logs -type Directory
New-Item C:\Backups\MSQL-TableBackup -type Directory
New-Item C:\Backups\EventLogs -type Directory
Copy-Item 'D:\Program Files (x86)\McAfee\ePolicy Orchestrator\DB\Logs\*' C:\Backups\DB-Logs
Copy-Item 'F:\Program Files\Microsoft SQL Server\MSSQL12.HBSSEPO\MSSQL\Log\*' C:\Backups\MSQL-Logs
sqlcmd -U EPOSQLUSERNAME -P "EPOSQLPASSWORD" -S LOCALHOST\HBSSEPO -Q "SELECT * FROM ePO_HBSSEPO.dbo.orionAuditLog" -o C:\Backups\MSQL-TableBackup\dboorionAuditLog.txt

#EventlogBackups
$logFileName = "Application"
$path = "C:\Backups\Eventlogs\"

$exportFileName = $logFileName + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName}
$logFile.backupeventlog($path + $exportFileName)

$logFileName2 = "Security"
$exportFileName2 = $logFileName2 + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName2}
$logFile.backupeventlog($path + $exportFileName2)

$logFileName4 = "System"
$exportFileName4 = $logFileName4 + (get-date -f yyyyMMdd) + ".evt"
$logFile = Get-WmiObject Win32_NTEventlogFile | Where-Object {$_.logfilename -eq $logFileName4}
$logFile.backupeventlog($path + $exportFileName4)

$date = get-date
$date = $date.ToString("mm-hh-MM-dd-yyyy")

#Creates a secured password, stored against your windows local credential store
#$password = "YOURPASSWORDHERE"
#$securestring = convertto-securestring -string $password -asplaintext -force | convertfrom-securestring
#write-host $securestring 
$securestring = ""
$securestring = convertto-securestring -string $securestring
$bstr = [System.Runtime.InteropServices.Marshal]::SecureStringToBSTR($securestring)
$password = [System.Runtime.InteropServices.Marshal]::PtrToStringAuto($bstr)

#Create an encrypted AES256 Archieve
cd 'C:\Program Files\7-Zip\'
.\7z.exe a -t7z C:\Backups\backup-$date.7z "C:\Backups" -p"$password" -mhe -mx9

#Creates a secured password, stored against your windows local credential store
#$password2 = "YOURPASSWORDHERE"
#$securestring2 = convertto-securestring -string $password2 -asplaintext -force | convertfrom-securestring
#write-host $securestring 
#Connect to remote share.
$Username = "REMOTESHAREUSERNAME"
$securestring2 = ""
$securestring2 = convertto-securestring -string $securestring2

$mycreds = New-Object System.Management.Automation.PSCredential($Username,$securestring2)

#Create a temporary drive and copy backup to remote share.
$dest = "\\SHAREIPADDRESS\PATH\TO\THE\FOLDER"
New-PSDrive -Name L -PSProvider FileSystem -Root $dest -Credential $mycreds
Copy-Item "C:\Backups\backup-$date.7z" -Destination "L:\backup-$date.7z"

Remove-Item C:\Backups\* -recurse
Clear-Eventlog "Application"
Clear-Eventlog "Security"
Clear-Eventlog "System"
