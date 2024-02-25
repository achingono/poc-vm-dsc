Configuration ServerConfiguration {

    param (
        [Parameter(Mandatory = $true)]
        [string] $siteName,
        [Parameter(Mandatory = $true)]
        [string] $applicationPool,
        [Parameter(Mandatory = $true)]
        [string] $packageUrl,
        [Parameter(Mandatory = $true)]
        [string] $packageName,
        [Parameter(Mandatory = $true)]
        [string] $decryptionKey,
        [Parameter(Mandatory = $true)]
        [string] $validationKey,
        [Parameter(Mandatory = $false)]
        [string] $downloadPath = "C:\Deploy\Packages"
    )

    Import-DscResource -ModuleName PSDesiredStateConfiguration, xWebAdministration

    Node localhost {

        # Install required Windows features
        WindowsFeature IIS {
            Ensure = "Present"
            Name   = "Web-Server"
        }

        WindowsFeature  NETFramework45 {
            Ensure = "Present"
            Name   = "NET-Framework-45-ASPNET"
        }

        WindowsFeature ASPNET45 {
            Ensure = "Present"
            Name   = "Web-Asp-Net45"
        }

        Script NgenUpdate {
            DependsOn  = "[WindowsFeature]IIS", "[WindowsFeature]NETFramework45", "[WindowsFeature]ASPNET45"
            GetScript  = { return @{ Result = "Installed" } }
            SetScript  = {
                &$Env:windir\Microsoft.NET\Framework64\v4.0.30319\ngen update; 
                &$Env:windir\Microsoft.NET\Framework\v4.0.30319\ngen update;
            }
            TestScript = {
                # Test if NgenUpdate has been run
                return $false
            }
        }

        WindowsFeature WebASP {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-ASP"
        }

        WindowsFeature WebCGI {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-CGI"
        }

        WindowsFeature WebISAPIExt {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-ISAPI-Ext"
        }

        WindowsFeature WebISAPIFilter {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-ISAPI-Filter"
        }

        WindowsFeature WebIncludes {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Includes"
        }

        WindowsFeature WebHTTPErrors {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-HTTP-Errors"
        }

        WindowsFeature WebCommonHTTP {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Common-HTTP"
        }

        WindowsFeature WebPerformance {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Performance"
        }

        WindowsFeature WAS {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "WAS"
        }

        WindowsFeature WebMgmtConsole {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Mgmt-Console"
        }

        WindowsFeature WebMgmtService {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Mgmt-Service"
        }

        WindowsFeature WebScriptingTools {
            DependsOn = "[Script]NgenUpdate"
            Ensure    = "Present"
            Name      = "Web-Scripting-Tools"
        }

        WindowsOptionalFeature IISDefaultDocument {
            DependsOn = "[WindowsFeature]IIS"
            Ensure    = "Enable"
            Name      = "IIS-DefaultDocument"
        }

        WindowsOptionalFeature IISHttpErrors {
            DependsOn = "[WindowsFeature]IIS"
            Ensure    = "Enable"
            Name      = "IIS-HttpErrors"
        }

        WindowsOptionalFeature IISManagementService {
            DependsOn = "[WindowsFeature]IIS"
            Ensure    = "Enable"
            Name      = "IIS-ManagementService"
        }

        # Enable remote management for IIS
        Registry EnableRemoteManagement {
            DependsOn = "[WindowsOptionalFeature]IISManagementService"
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WebManagement\Server"
            ValueName = "EnableRemoteManagement"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        Registry EnableLogging {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WebManagement\Server"
            ValueName = "EnableLogging"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        Registry TracingEnabled {
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\WebManagement\Server"
            ValueName = "TracingEnabled"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        # Set IIS Remote Management Service to start automatically and start it
        Service WMSVC {
            Name        = "WMSVC"
            StartupType = "Automatic"
            State       = "Running"
            DependsOn   = @("[Registry]EnableRemoteManagement", "[Registry]EnableLogging", "[Registry]TracingEnabled")
        }

        # Install C++ 2017 distributions
        Package VCRedist2017x64 {
            Ensure    = "Present"
            Path      = "https://aka.ms/vs/17/release/vc_redist.x64.exe"
            Name      = "Microsoft Visual C++ 2017 Redistributable (x64)"
            ProductId = "{74d0e5db-b326-4dae-a6b2-9d6e5a6097d1}"
            Arguments = "/install /quiet /norestart"
        }

        Package VCRedist2017x86 {
            Ensure    = "Present"
            Path      = "https://aka.ms/vs/17/release/vc_redist.x86.exe"
            Name      = "Microsoft Visual C++ 2017 Redistributable (x86)"
            ProductId = "{e2803110-78b3-4664-a479-3611a381656a}"
            Arguments = "/install /quiet /norestart"
        }

        # Install ODBC Driver
        Package ODBCDriver {
            Ensure    = "Present"
            Path      = "https://download.microsoft.com/download/f/1/3/f13ce329-0835-44e7-b110-44decd29b0ad/en-US/19.3.1.0/x64/msoledbsql.msi"
            Name      = "Microsoft ODBC Driver 17 for SQL Server"
            ProductId = "{4F7D2B1E-4B6B-4A1A-B50A-7A449A6EE5B3}"
            Arguments = "IACCEPTMSOLEDBSQLLICENSETERMS=YES /quiet /norestart"
        }

        # Install IIS Rewrite Module
        Package IISRewrite {
            Ensure    = "Present"
            Path      = "https://download.microsoft.com/download/1/2/8/128E2E22-C1B9-44A4-BE2A-5859ED1D4592/rewrite_amd64_en-US.msi"
            Name      = "IIS URL Rewrite Module 2"
            ProductId = "{C7C3A5D6-8F8D-44B6-8C2E-4E9CD7B2E5A7}"
            Arguments = "/quiet /norestart"
            DependsOn = "[WindowsFeature]IIS"
        }

        # Install Web Deploy
        Package InstallWebDeploy {
            Ensure    = "Present"  
            Path      = "https://download.microsoft.com/download/0/1/D/01DC28EA-638C-4A22-A57B-4CEF97755C6C/WebDeploy_amd64_en-US.msi"
            Name      = "Microsoft Web Deploy 3.6"
            ProductId = "{6773A61D-755B-4F74-95CC-97920E45E696}"
            Arguments = "ADDLOCAL=ALL /quiet /norestart"
            DependsOn = "[WindowsOptionalFeature]IISManagementService"
        }

        # Unlock the IIS configuration
        Script UnlockASPConfig {
            GetScript  = { return @{ Result = "Unlocked" } }
            SetScript  = { & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/asp }
            TestScript = { return $false }
            DependsOn  = "[WindowsFeature]IIS"
        }

        Script UnlockHandlersConfig {
            GetScript  = { return @{ Result = "Unlocked" } }
            SetScript  = { & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/handlers }
            TestScript = { return $false }
            DependsOn  = "[WindowsFeature]IIS"
        }

        Script UnlockModulesConfig {
            GetScript  = { return @{ Result = "Unlocked" } }
            SetScript  = { & c:\windows\system32\inetsrv\appcmd.exe unlock config /section:system.webServer/modules }
            TestScript = { return $false }
            DependsOn  = "[WindowsFeature]IIS"
        }

        # Enable Fusion Logs
        Registry EnableFusionForceLogs {
            DependsOn = "[WindowsFeature]IIS"
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion"
            ValueName = "ForceLog"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        Registry EnableFusionLogFailures {
            DependsOn = "[WindowsFeature]IIS"
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion"
            ValueName = "LogFailures"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        Registry EnableFusionLogResourceBinds {
            DependsOn = "[WindowsFeature]IIS"
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion"
            ValueName = "LogResourceBinds"
            ValueType = "Dword"
            ValueData = "1"
            Force     = $true
            Ensure    = "Present"
        }

        Registry SetFusionLogPath {
            DependsOn = "[WindowsFeature]IIS"
            Key       = "HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Fusion"
            ValueName = "LogPath"
            ValueType = "String"
            ValueData = "C:\inetpub\logs\fusionlogs"
            Force     = $true
            Ensure    = "Present"
        }

        # Update Default IISSite
        xWebsite DefaultSite {
            Ensure       = "Present"
            Name         = "Default Web Site"
            State        = "Started"
            PhysicalPath = "C:\inetpub\wwwroot"
            BindingInfo  = @(
                MSFT_xWebBindingInformation {
                    Protocol  = "http"
                    Port      = "8080"
                    IPAddress = "*"
                }
            )
        }

        # Create Application Pool
        xWebAppPool $applicationPool {
            Ensure                = "Present"
            Name                  = $applicationPool
            State                 = "Started"
            ManagedRuntimeVersion = "v4.0"
            ManagedPipelineMode   = "Integrated"
            Enable32BitAppOnWin64 = $false
            AutoStart             = $true
        }

        # Create IISSite
        xWebsite $siteName {
            Ensure          = "Present"
            Name            = $siteName
            State           = "Started"
            PhysicalPath    = "C:\inetpub\$siteName"
            ApplicationPool = $applicationPool
            BindingInfo     = @(
                MSFT_xWebBindingInformation {
                    Protocol  = "http"
                    Port      = "80"
                    IPAddress = "*"
                }
            )
        }

        # Download the package
        Script DownloadWebPackage {
            GetScript  = {
                @{
                    Result = ""
                }
            }
            TestScript = {
                $false
            }
            SetScript  = {
                Invoke-WebRequest -Uri $using:packageUrl -OutFile "$using:downloadPath\$using:packageName" -Verbose
            }
        }

        # Create the parameters file
        Script CreateParametersFile {
            GetScript  = {
                @{
                    Result = ""
                }
            }
            TestScript = {
                $false
            }
            SetScript  = {
                # Create an instance of the XmlDocument class
                $xmlDoc = New-Object System.Xml.XmlDocument;

                # Create the XML declaration
                $xmlDeclaration = $xmlDoc.CreateXmlDeclaration("1.0", "UTF-8", $null);
                $xmlDoc.AppendChild($xmlDeclaration);

                # Create the root element
                $parametersElement = $xmlDoc.CreateElement("parameters");
                $xmlDoc.AppendChild($parametersElement);

                # Helper function to create and append a parameter element
                Function AddParameterElement($name, $value) {
                    $parameterElement = $xmlDoc.CreateElement("setParameter");
                    $nameAttribute = $xmlDoc.CreateAttribute("name");
                    $valueAttribute = $xmlDoc.CreateAttribute("value");

                    $nameAttribute.Value = $name;
                    $valueAttribute.Value = [System.Security.SecurityElement]::Escape($value);

                    $parameterElement.Attributes.Append($nameAttribute);
                    $parameterElement.Attributes.Append($valueAttribute);

                    $parametersElement.AppendChild($parameterElement);
                }

                # Add parameters
                AddParameterElement "Decryption Key" $decryptionKey;
                AddParameterElement "Validation Key" $validationKey;

                # Save the parameters XML file
                $parametersFile = $packageName -replace ".zip", ".xml";
                $xmlDoc.Save("$using:downloadPath\$parametersFile");
            }
        }

        # Deploy the package
        Script DeployWebPackage {
            DependsOn = "[Script]DownloadWebPackage", "[Script]CreateParametersFile", "[Package]InstallWebDeploy"
            GetScript  = {
                @{
                    Result = ""
                }
            }
            TestScript = {
                $false
            }
            SetScript  = {
                $packagePath = "$using:downloadPath\$using:packageName";
                $msDeployPath = (Get-ChildItem "HKLM:\SOFTWARE\Microsoft\IIS Extensions\MSDeploy" | Select -Last 1).GetValue("InstallPath");
                $parametersFile = $using:packageName -replace ".zip", ".xml";
                $arguments = "-source:package=$packagePath -dest:iisApp=$using:siteName -setParamFile=$using:downloadPath\$parametersFile -verbose -debug";

                # Deploy the package to the Site
                Start-Process "$msDeployPath\msdeploy.exe" $arguments -Verb runas;            
            }
        }    
    }            
}
