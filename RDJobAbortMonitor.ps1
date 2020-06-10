<#
As of 06-2020 Rundeck does not have an event handler when the job is Killed/Canceled/Aborted by the user. 
This implementation addresses that limitation. 
You may read more about it here: https://github.com/rundeck/rundeck/issues/1606

How it works:

#Step-1
    update -> $RDServerURL Variable/Param below
        This must be your rundeck URL

    update -> $RDAuthToken Variable/param below
        Generate rundeck api token that will have access to Rundeck project/jobs to monitor


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


#>

$RDJobMonitor= {

    param(
        $rdjobID,
        $ExecJOBID,
        $CommandToExecOnAbort,
        $RDServerURL="http://rundeck:4440(this-should-be-your-rundeck-server-url)",
        $RDAPI="/api/30",
        $RDAuthToken = "xyxyxyxyxyxyxyxyxyxyx(you-use-your-rundeck-api-token)",
        $DebugMOde=$false
    )    

    $Timeout = 1800 #Monitoring will timeout/stop after this period job will resume...
    $url = "$($RDServerURL)$($RDAPI)/job/$($rdjobID)/executions?authtoken=$($RDAuthToken)"

    if($DebugMOde){
        $DebugOutFile= "c:\temp\RDJobAbortMonitor.log"
        write "PS JOB Starting" |Out-File "$DebugOutFile"  
        write "-----------------" |Out-File "$DebugOutFile"  -Append
        write "URL:$($url)" |Out-File "$DebugOutFile" -Append
        write "ExecJOBID:$($ExecJOBID)" |Out-File "$DebugOutFile" -Append
    }
    


    do
    {
        try {
            #Monitor Rundeck Job Status
            $RunningJob = (Invoke-RestMethod -uri $url  -Method get -ContentType 'application/json' -ErrorVariable RestError).executions.execution |?{$_.id -eq "$($ExecJOBID)"}    
        }
        catch {

            #Capture Rest Error, output as much as possible                
            $streamReader = [System.IO.StreamReader]::new($_.Exception.Response.GetResponseStream())
            $ErrResp = $streamReader.ReadToEnd() | ConvertFrom-Json
            $streamReader.Close()
            $ErrResp |Out-File "$DebugOutFile" -Append
            if($DebugMOde)
            {
                write "Rest Error" |Out-File "$DebugOutFile" -Append 
                write "Error: $($ErrResp.error)" |Out-File "$DebugOutFile" -Append 
                $_.exception.message |Out-File "$DebugOutFile" -Append
                if($RestError)
                {
                    $RestError.ErrorRecord.Exception.Response.StatusCode.value__ |Out-File "$DebugOutFile" -Append
                    $RestError.ErrorRecord.Exception.Response.StatusDescription    |Out-File "$DebugOutFile" -Append
                }
                write $error[0].ErrorDetails.Message |Out-File "$DebugOutFile" -Append 
            }
        }
        
        if($DebugMOde){write "PSJob RDJobID=$($rdjobID) Status:$($RunningJob.status)" |Out-File "$DebugOutFile" -Append }
        
        sleep -Seconds 3
        $Timeout--;
    }while($RunningJob.status -eq "running" -and $Timeout -gt 0)    
    
    

    
    if($RunningJob.Status -eq "aborted")
    {
        if($DebugMOde){write "Job was Canceled, executing Abort Command:$($CommandToExecOnAbort)" |Out-File "$DebugOutFile" -Append }
        try {

            Invoke-Expression  "$CommandToExecOnAbort"    
        }
        catch {
            #since this a BG job you may never see this exception unless in Debug Mode
            if($DebugMOde){
                write " Error trying to execute Abort Command:($($CommandToExecOnAbort))" |Out-File "$DebugOutFile" -Append 
                write " $($_.exception.message) " |Out-File "$DebugOutFile" -Append 
            }
        }
        
        
    }
}