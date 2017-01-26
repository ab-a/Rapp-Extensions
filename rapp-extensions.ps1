#
# Made by Antoine Bayard
# 2017
#

function retrieveGUID {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Folder
    )
    if(Test-Path -Path $folder) {
        $GUID = Get-ChildItem -Path $Folder -Recurse | Select-Object FullName | Select-Object -first 1
        $GUID = $GUID.FullName
        return $GUID
    }
    else {
        $Host.UI.WriteErrorLine("Error : wrong folder, impossible to retrieve GUID")
    }
}

function initApplication {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Application,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ApplicationValue

    )
    New-Item -Path $Path$Application #-erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\shell" #-erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\shell\open" #-erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\shell\open\command" #-erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\DefaultIcon"# -erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\DefaultIcon" #-erroraction 'silentlycontinue'

    New-ItemProperty -Path $Path$Application -Name "AppUserModelId" -PropertyType "String" -Value "Microsoft.Windows.RemoteDesktop" # -erroraction 'silentlycontinue'
    New-ItemProperty -Path $Path$Application -Name "EditFlags" -PropertyType "DWord" -Value 00100000 #-erroraction 'silentlycontinue'

    $GUID = retrieveGUID -Folder "$env:USERPROFILE\AppData\Roaming\Microsoft\Workspaces"
    $value = '@="' + $GUID + '\Icons\' + $ApplicationValue + '.ico,0"'    
    New-ItemProperty -Path "$Path$Application\DefaultIcon" -Name "(Default)" -Type "String" -Value $value #-erroraction 'silentlycontinue'
        
    $GUID = retrieveGUID -Folder "$env:USERPROFILE\AppData\Roaming\Microsoft\Workspaces"
    $value = '@="\"mstsc.exe\" /REMOTEFILE:\"%1\" \"' + $GUID + '\Resource\' + $ApplicationValue + '.rdp\""'
    New-ItemProperty -Path "$Path$Application\shell\open\command" -Name "(Default)" -Type "String" -Value $value # -erroraction 'silentlycontinue'
}

function deployExtensions {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Extension,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Application
    )
    $app = '@="' + $Application + '"'
    New-Item -Path "$Path$Application\$Extension" #-erroraction 'silentlycontinue'
    New-Item -Path "$Path$Application\$Extension\$Application" #-erroraction 'silentlycontinue'
    New-ItemProperty -Path $Path$Application\$Extension -Name "(Default)" -Type "String" -Value $app #-erroraction 'silentlycontinue'
}

function deployApplication {
    param (
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Path,        
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Application,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$ApplicationValue,
        [parameter(Mandatory=$true)]
        [ValidateNotNullOrEmpty()]$Extension
    )
    initApplication -Path $path -Application $application -ApplicationValue $applicationValue
    for ($i = 0; $i -le $extensions.length -1; $i++) {
      deployExtensions -Path $path -Extension $extensions[$i] -Application $application      
    }
}

function main {
    $extensions = @(".jpg",".png")
    
    deployApplication -Path "HKCU:Software\Classes\" -Application "RAPP.EXAMPLE" -ApplicationValue "Example 2000 (Work Resources)" -Extension $extensions

    return 0 | Out-Null 
}

main