# BC and SQL Info
$serverInstance = "bc150"
$tenant = "default"
$databaseName = "dbname"
$applicationVersion = [Version]::new(15,3,38071,0)
$serverDatabaseInstance = "serverName\sqlinstance"
$modulePath = Join-Path -Path "C:\Program Files\Microsoft Dynamics 365 Business Central\150\Service\NavAdminTool.ps1" -ChildPath ""

# System and Base App
$systemPath  = Join-Path -Path "C:\Program Files (x86)\Microsoft Dynamics 365 Business Central\150\AL Development Environment\System.app" -ChildPath ""

$systemAppName = "System Application"
$systemAppPath = Join-Path -Path "C:\temp\installs\BC 15.3\Applications\System Application\Source\Microsoft_System Application.app" -ChildPath ""
$systemAppVersionNew = [Version]::new(15,3,38071,0)

$baseAppName = "Base Application"
$baseAppPath = Join-Path -Path "C:\temp\installs\BC 15.3\Applications\BaseApp\Source\Microsoft_Base Application.app" -ChildPath ""
$baseAppVersionNew = [Version]::new(15,3,38071,0)

# Custom App
$customAppName = "CustomApp"
$customAppPath = Join-Path -Path "C:\temp\BC150-3\Company_CustomApp_15.3.0.0.app" -ChildPath ""
$customAppVersion = [Version]::new(15,3,0,0)

If (Test-Path -Path $modulePath) { } else { break 'modulePath failed' }
If (Test-Path -Path $systemPath) { } else { break 'systemPath failed' }
If (Test-Path -Path $systemAppPath) { } else { break 'systemAppPath failed' }
If (Test-Path -Path $baseAppPath) { } else { break 'baseAppPath failed' }
If (Test-Path -Path $customAppPath) { } else { throw 'customAppPath failed' }

break
# Module
Import-Module -name $modulePath

# uninstall apps
Get-NAVAppInfo -ServerInstance $serverInstance -Tenant $tenant | % { Uninstall-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $_.Name -Version $_.Version -Force}
Get-NAVAppInfo -ServerInstance $serverInstance -Tenant $tenant | % { Unpublish-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $_.Name -Version $_.Version -Force}
Uninstall-NAVApp -ServerInstance $serverInstance -Name $baseAppName -Version $baseAppVersionOld
Unpublish-NAVApp -ServerInstance $serverInstance -Name $baseAppName -Version $baseAppVersionOld
Uninstall-NAVApp -ServerInstance $serverInstance -Name $systemAppName -Version $systemAppVersionOld
Unpublish-NAVApp -ServerInstance $serverInstance -Name $systemAppName -Version $systemAppVersionOld

Get-NAVAppInfo -ServerInstance $serverInstance

Unpublish-NAVApp -ServerInstance $serverInstance -Name System
Stop-NAVServerInstance -ServerInstance $serverInstance

# Install Business Central

Invoke-NAVApplicationDatabaseConversion -DatabaseServer $serverDatabaseInstance -DatabaseName $databaseName
Set-NAVServerConfiguration -ServerInstance $serverInstance -KeyName DatabaseName -KeyValue $databaseName
Restart-NAVServerInstance -ServerInstance $serverInstance

Publish-NAVApp -ServerInstance $serverInstance -Path $systemPath -PackageType SymbolsOnly

# Recompile app if you dont have new version

Sync-NAVTenant -ServerInstance $serverInstance -Tenant $tenant -Mode Sync

# System app
Publish-NAVApp -ServerInstance $serverInstance -Path $systemAppPath
Sync-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $systemAppName -Version $systemAppVersionNew
Start-NAVAppDataUpgrade -ServerInstance $serverInstance -Tenant $tenant -Name $systemAppName -Version $systemAppVersionNew

# Base app
Publish-NAVApp -ServerInstance $serverInstance -Path $baseAppPath
Sync-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $baseAppName -Version $baseAppVersionNew
Start-NAVAppDataUpgrade -ServerInstance $serverInstance -Tenant $tenant -Name $baseAppName -Version $baseAppVersionNew

# Any custom app
Publish-NAVApp -ServerInstance $serverInstance -Path $customAppPath
Sync-NavApp -ServerInstance $serverInstance -Tenant $tenant -Name $customAppName -Version $customAppVersion
Start-NAVAppDataUpgrade -ServerInstance $serverInstance -Tenant $tenant -Name $customAppName -Version $customAppVersion

Set-NAVApplication -ServerInstance BC150 -ApplicationVersion $applicationVersion -Force

Sync-NAVTenant -ServerInstance $serverInstance -Mode Sync -Tenant $tenant
Start-NAVDataUpgrade -ServerInstance $serverInstance -Tenant $tenant
Restart-NAVServerInstance -ServerInstance $serverInstance
