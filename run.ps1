Get-NAVAppInfo -ServerInstance <server instance name> -Tenant <tenant ID> | % { Uninstall-NAVApp -ServerInstance <server instance name> -Tenant <tenant ID> -Name $_.Name -Version $_.Version -Force}
Get-NAVAppInfo -ServerInstance <server instance name> -Tenant <tenant ID> | % { Uninstall-NAVApp -ServerInstance <server instance name> -Tenant <tenant ID> -Name $_.Name -Version $_.Version -Force}

Get-NAVAppInfo -ServerInstance <server instance name>

Unpublish-NAVApp -ServerInstance <server instance> -Name System -version <version>


Stop-NAVServerInstance -ServerInstance <server instance>
# Install Business Central

Invoke-NAVApplicationDatabaseConversion -DatabaseServer <database server name>\<database server instance> -DatabaseName "<database name>"
Set-NAVServerConfiguration -ServerInstance <server instance> -KeyName DatabaseName -KeyValue "<database name>"
Restart-NAVServerInstance -ServerInstance <server instance>

Publish-NAVApp -ServerInstance <server instance> -Path "<path to the System.app file>" -PackageType SymbolsOnly