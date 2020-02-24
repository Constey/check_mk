# 30.01.2019 # CL
# Constantin.Lotz@ruv-bkk.de
# Check Storage Spaces Direct Disk
#          
# Dieser Check prüft den Status aller Physical Disks
# und liefert die Summe der gesamten Festplatten
#
# Version 0.2
#
# Changelog: 24.02.2020 -Remove Whitespaces from SerialNumber (by Andreas, afaassl)
# 

# PhysicalDisk
$pdisks = Get-PhysicalDisk | Where { $_.FriendlyName -ne "HP LOGICAL VOLUME" } | Select FriendlyName, SerialNumber, OperationalStatus, HealthStatus, Usage, Size, AllocatedSize, VirtualDiskFootprint
foreach ($pdisk in $pdisks) {
    if ($pdisk.OperationalStatus -eq "OK" -and $pdisk.HealthStatus -eq "Healthy") {
        # All good
        $status = "0"
        #Remove Whitespaces
		$serial=$pdisk.SerialNumber.replace(' ','') #afassl
        $diskname = $pdisk.Friendlyname -replace '\s',''
        $diskname = $pdisk.Friendlyname -replace '/',''
        $statusText = "OK - " + $diskname + " is in good state. OperationalStatus:" + $pdisk.OperationalStatus + " | HealthStatus:" + $pdisk.HealthStatus + " | Usage: " + $pdisk.Usage + " | Size:" + $pdisk.Size + " | SN:" + $serial
    } else {
        $status = "1"
        $statusText = "Warning - " + $diskname + " is in unusual state. OperationalStatus:" + $pdisk.OperationalStatus + " | HealthStatus:" + $pdisk.HealthStatus + " | Usage: " + $pdisk.Usage + " | Size:" + $pdisk.Size + " | SN:" + $serial
    }
    $perfdataVirtualDisk = "size=" + $pdisk.Size + "|allocatedsize=" + $pdisk.AllocatedSize + "|virtualdiskfootprint=" + $pdisk.VirtualDiskFootprint
    $stringToPost = $status + " S2D_PhysicalDisk_" + $serial + " " + $perfdataVirtualDisk + " " + $statusText
	Write-Host $stringToPost
}

# Count of Physical Disks
$status = "0"
$stringToPost = $status + " S2D_SUM_PhysicalDisk count=" + $pdisks.Count + " Insgesamt " + $pdisks.Count + " Festplatten im System vorhanden."
Write-Host $stringToPost
