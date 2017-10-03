function ScheduleScript()
{
    $repeat = (New-TimeSpan -Minutes 15)
    $jobname = "DonWebster"
    $script =  "D:\Downloads\DuckyPaper\duckypaper.ps1"

    Unregister-ScheduledTask -TaskName $jobname -Confirm:$false

    $scriptblock = [scriptblock]::Create($script)

    Write-Host $scriptblock

    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' 
    $trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat
    $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
    Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options
}

ScheduleScript