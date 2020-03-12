Import-Module -name "C:\Program Files\Microsoft Dynamics 365 Business Central\150\Service\NavAdminTool.ps1"
$serverInstance = "bc150"
$tenant = "default"
$databaseName = "BC-Maia365-D0"
$serverName = ""
$instance = ""

Get-NAVAppInfo -ServerInstance $serverInstance -Tenant $tenant | % { Uninstall-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $_.Name -Version $_.Version -Force}
Get-NAVAppInfo -ServerInstance $serverInstance -Tenant $tenant | % { Uninstall-NAVApp -ServerInstance $serverInstance -Tenant $tenant -Name $_.Name -Version $_.Version -Force}

Get-NAVAppInfo -ServerInstance $serverInstance

Unpublish-NAVApp -ServerInstance $serverInstance -Name System -version <version>


Stop-NAVServerInstance -ServerInstance $serverInstance
# Install Business Central

Invoke-NAVApplicationDatabaseConversion -DatabaseServer <database server name>\<database server instance> -DatabaseName $databaseName
Set-NAVServerConfiguration -ServerInstance $serverInstance -KeyName DatabaseName -KeyValue $databaseName
Restart-NAVServerInstance -ServerInstance $serverInstance

Publish-NAVApp -ServerInstance $serverInstance -Path "<path to the System.app file>" -PackageType SymbolsOnly

