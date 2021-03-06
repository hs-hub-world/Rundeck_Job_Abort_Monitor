# Rundeck_Job_Abort_Monitor

This repo contains the PowerShell script/module that can be used with Rundeck to trigger a command when RD Job is Killed/Canceled/Aborted

Since Rundeck does not have an event handler when a job is Killed/Canceled/Aborted by the user this implementation addresses that limitation. This refers to: https://github.com/rundeck/rundeck/issues/1606

How it works:

#Step-1  
	- on the target node create foders: C:\Temp and C:\RDExec_Scripts  
	- download all ps1 files into C:\RDExec_Scripts  
	- using Rundeck WinRM project create a job targeting the selected Node from above steps.  
		- Rundeck Job should have a workflow command step with command:  
		 C:\RDExec_Scripts\Sample_RD_script.ps1 -RDJobID ${job.id} -ExecJOBID ${job.execid}  
		- Save the Rundeck Job  

#Step-2  
    - update *$RDServerURL* Variable/Param in the RDJobAbortMonitor.ps1  
    - update *$RDAuthToken* Variable/param in the RDJobAbortMonitor.ps1  with api token that has access to Rundeck project/jobs  

#Step-3  
	- Run the Rundeck Job. The job should output:  
		 "Rundeck Job is Running...  
		 This job will sleep for 60-seconds  
		 If you Kill/Cancel this job this script will execute: rundeck_CancelJob.ps1  "  
	 

Optional:  
	- In case it's not working set the $DebugMOde=$true in the RDJobAbortMonitor.ps1 script it will generate this file: "C:\Temp\RDJobAbortMonitor.log"  
	-  Ensure the URL is correct  
	-  Ensure the JobID and ExecJobID's are being passed correctly  
	


