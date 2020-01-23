# 30.01.2019 # CL
# Constantin.Lotz@ruv-bkk.de
# Check Storage Spaces Direct Disk
#          
# Dieser Check prüft den Status aller Virtual Disks sowie des StoragePool
# Außerdem werden aktuelle StorageJobs aufgelistet
# 
# Version 0.1
#

$vdisks = Get-VirtualDisk | Select FriendlyName, OperationalStatus, HealthStatus, Size, AllocatedSize, FootprintOnPool
foreach ($vdisk in $vdisks) {
    if ($vdisk.OperationalStatus -eq "OK" -and $vdisk.HealthStatus -eq "Healthy") {
        # All good
        $status = "0"
        $statusText = "OK - " + $vdisk.Friendlyname + " is in good state. OperationalStatus:" + $vdisk.OperationalStatus + " | HealthStatus:" + $vdisk.HealthStatus
    } else {
        $status = "1"
        $statusText = "Warning - " + $vdisk.Friendlyname + " is in unusual state. OperationalStatus:" + $vdisk.OperationalStatus + " | HealthStatus:" + $vdisk.HealthStatus
    }
    $perfdataVirtualDisk = "size=" + $vdisk.Size + "|allocatedsize=" + $vdisk.AllocatedSize + "|footprintonpool=" + $vdisk.FootprintOnPool
    $stringToPost = $status + " S2D_VirtualDisk_" + $vdisk.FriendlyName + " " + $perfdataVirtualDisk + " " + $statusText
	Write-Host $stringToPost
}

# StoragePool
$pool = Get-StoragePool -FriendlyName S2D*
    if ($pool.OperationalStatus -eq "OK" -and $pool.HealthStatus -eq "Healthy") {
        # All good
        $status = "0"
        $statusText = "OK - " + $pool.Friendlyname + " is in good state. OperationalStatus:" + $pool.OperationalStatus + " | HealthStatus:" + $pool.HealthStatus
    } else {
        $status = "1"
        $statusText = "Warning - " + $pool.Friendlyname + " is in unusual state. OperationalStatus:" + $pool.OperationalStatus + " | HealthStatus:" + $pool.HealthStatus
    }
    $perfdataPool = "size=" + $pool.Size + "|allocatedsize=" + $pool.AllocatedSize
    $stringToPost = $status + " S2D_StoragePool " + $perfdataPool + " " + $statusText
	Write-Host $stringToPost

# StorageJobs
$jobs = Get-StorageJob
if (!$jobs) { 
         # All good
        $status = "0"
        $statusText = "OK - There are no StorageJobs"
} else {
        $status = "1" 
        $statusText = "Warning - There are Storagejobs running:"
        foreach ($job in $jobs) {
            $statusText += $job.Name + "," + $job.ElapsedTime + "," + $job.JobState + "," + $job.PercentComplete + "," + $job.BytesProcessed + "," + $job.BytesTotal + ";"
        } 
}
$stringToPost = $status + " S2D_StorageJobs" + " - " + $statusText
Write-Host $stringToPost

