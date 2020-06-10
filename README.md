# Rundeck_Job_Abort_Monitor

This repo contains the PowerShell script/module that can be used with Rundeck to trigger a command when RD Job is Killed/Canceled/Aborted

Since Rundeck does not have an event handler when a job is Killed/Canceled/Aborted by the user this implementation addresses that limitation. This refers to: https://github.com/rundeck/rundeck/issues/1606

How it works:

#Step-1
    update -> $RDServerURL Variable/Param in the RDJobAbortMonitor.ps1
        This must be your rundeck URL

    update -> $RDAuthToken Variable/param in the RDJobAbortMonitor.ps1
        Generate rundeck api token that has access to Rundeck project/jobs

#Step-2
	Load this module from the executing script by Dot sourcing
		. "C:\RDExec_Scripts\RDJobAbortMonitor.ps1"  -ErrorAction Stop

#Step-3
	Prepare the Abort script. This script will execute when RD Job is aborted
		#Sample-1 (without arguments)
		$CommandToExecOnAbort = "C:\RDExec_Scripts\rundeck_CancelJob.ps1"

		#Sample-2 (with argumetns)
    $CommandToExecOnAbort = "C:\RDExec_Scripts\rundeck_CancelJob.ps1 -Param1 $($Value1) -Param2 $($Value2)"


#Step-4
	Start the Abort Monitoring job with your execution
		#NOTE The "invoke-command" process will spawn-up a completely separate process from the current process so it does not inherit/become child of current process - thus will not terminate with the current process.
		$JobName="RDJobMonitor_$($ExecJOBID)"
		Invoke-Command -JobName "$JobName" -ComputerName . -AsJob    -ScriptBlock $RDJobMonitor  -ArgumentList $RDJobID, $ExecJOBID, $CommandToExecOnAbort |Out-Null


That's all.

