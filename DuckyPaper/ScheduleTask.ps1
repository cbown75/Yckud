function ScheduleScript()
{
    $repeat=(New-TimeSpan -Minutes 2)
    $jobname="DonWebster"
    $script="D:\Git\Yckud\DuckyPaper\duckypaper.ps1"

    try
    {
    Unregister-ScheduledJob -Name $jobname -Force
    }
    catch
    {
        Write-Host "Job not found"
    }

    $scriptblock = [scriptblock]::Create($script)

    Write-Host $scriptblock

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' 
    $trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat
    $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
    #Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options -RunNow -RunEvery $repeat
    Register-ScheduledJob -Name $jobname -FilePath $script -Trigger $trigger -ScheduledJobOption $options -RunNow -RunEvery $repeat
}

ScheduleScript