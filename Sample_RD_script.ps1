<#
    This sample script will be execute by Rundeck Job using workflow Command Step
    example:
    C:\RDExec_Scripts\Sample_RD_script.ps1


#>

param(
    $RDJobID   = "",
    $ExecJOBID = ""
)

#Dot source the $RDJobMonitor function
. "C:\RDExec_Scripts\RDJobAbortMonitor.ps1"  -ErrorAction Stop


#Start the Abort Monitor job in case user canceles rundeck jobs
$CommandToExecOnAbort = "C:\RDExec_Scripts\rundeck_CancelJob.ps1"
$JobName="RDJobMonitor_$($ExecJOBID)"


#NOTE You can't use start-job or any other method other than invoke-command because we need to spawn up completely separate process from current process so it does not terminate with the current process
Invoke-Command -JobName "$JobName" -ComputerName . -AsJob    -ScriptBlock $RDJobMonitor  -ArgumentList $RDJobID, $ExecJOBID, $CommandToExecOnAbort |Out-Null

write "Rundeck Job is Running..."
write " This job will sleep for 60-seconds"
write " If you Kill/Cancel this job this script will execute:$($CommandToExecOnAbort)"

sleep -Seconds 60


write "Script finished successfully, it was not canceled."
