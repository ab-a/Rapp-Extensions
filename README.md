# Windows PowerShell Remote App Association Script
#### Sometimes, when you deploying remote application, you may want to automatically associate file with the remote application on all computers in the domain.

With this script you can deploy easily all modification to the registry to associate automatically your file with your remote app. This script is made to work with **RDSH**, normally you don't need this if you use Windows >= 8.

These functions are native :

- __`New-Item`__ 
- __`New-ItemProperty`__ 

The function `retrieveGUID` get the folder with the proper GUID in `Workspaces` folder : 

```PowerShell
$GUID = retrieveGUID -Folder "$env:USERPROFILE\AppData\Roaming\Microsoft\Workspaces"
```

The function `deployApplication` is the central function and the only you'll call in the main function. It take 4 parameters :

- __`Path`__ 
- __`Application`__ 
- __`Application Value`__ 
- __`Extension`__ 

The function `initApplication` create keys and initialize some item.

The function `deployExtensions` loop through the array to associate the extensions to the remoteapp.

This script, at first is created in order to deploy on many Windows Server in production through GPO, also fix when you have problem with the icon of your distant program.

## Starting 
> If you want to use this script you have to get some informations, example for Project 2016 :

- __`RAPP.EXAMPLE`__ - Name of the application
- __`Example 2016 (Work Resources)`__ - Alternative Name 

> If you want to do a backup before using this script : 

```PowerShell
reg export HKCU\Software\Classes $env:USERPROFILE\Desktop\rapp-backup.reg
```

#### Remember that you have to change the `-Application`, `-ApplicationValue` variables and `$extensions` array.

> On a computer who already have the remote app deployed you can find the name of the remote application in `HKEY_CURRENT_USER\Software\Classes\`, it's the folder prefixed by `RAPP`, like `RAPP.MSPROJECT`.
You can find the alternative name in `HKEY_CURRENT_USER\Software\Classes\RAPP.MSPROJECT\shell\open\command` at the end of the default item value for example.

## Manage Extensions
> You have to declare the list of wich extension you want to associate with the remote app. 

- __`$extensions = @(".jpg",".png")`__

#### Important : select wisely the extensions depending on wich remote app you wan't to deploy, or you'll have problem.

## Usage examples 
> Deploy for MSProject 2016 : 

```PowerShell
function main {
    $extensions = @(".mpd",".mpp",".mpt",".mpw",".mpx")

    deployApplication -Path "HKCU:Software\Classes\" -Application "RAPP.MSPROJECT" -ApplicationValue "Project 2016 (Work Resources)" -Extension $extensions
    return 0 | Out-Null 
}
```
> Deploy for MSAccess 2013 :

```PowerShell
function main {
    $extensions = @(".accdb",".accdc",".accde",".accdr",".accdt",".accdu",".accdw", `
    ".ade",".adn",".adp",".mad",".maf",".mag",".mam",".mar",".mas",".mau",".mav",".maw", `
    ".mdb",".mdbhtml",".mde",".mdn",".mdt",".mdw",".wizhtml")

    deployApplication -Path "HKCU:Software\Classes\" -Application "RAPP.MSACCESS" -ApplicationValue "Access 2013 (Work Resources)" -Extension $extensions

    return 0 | Out-Null 
}
```

> If you do want to see the output, uncomment `-erroraction 'silentlycontinue'` at the end of the lines.