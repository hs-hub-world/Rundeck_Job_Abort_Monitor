<#
    Once Rundeck Job is killed/canceled this script will execute and it will output strings into this file: c:\temp\RUNDECK_JOB_WAS_CANCELED.txt
#>

param(
    $Param1="",
    $Param2=""
)


write "Ouch! Rundeck Job Was Canceled..." |Out-File "c:\temp\RUNDECK_JOB_WAS_CANCELED.TXT"
write "Param1=$($Param1)" |Out-File "c:\temp\RUNDECK_JOB_WAS_CANCELED.TXT" -Append
write "Param2=$($Param2)" |Out-File "c:\temp\RUNDECK_JOB_WAS_CANCELED.TXT" -Append
