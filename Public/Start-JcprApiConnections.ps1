function Start-JcprApiConnections {
    [CmdletBinding()]
    param (
        [string]$HuduBaseUrl,
        [string]$JcOrgId
    )

    begin {

        $RequiredAssemblies = @(
            'System.Windows.Forms',
            'System.Drawing'
        )

        $RequiredAssemblies | ForEach-Object {
            if (-not (Get-Command $_ -ErrorAction SilentlyContinue)) {
                Add-Type -AssemblyName $_
            }
        }

        $RequiredPsModules = @(
            'HuduApi',
            'JumpCloud',
            'TUN.CredentialManager'
        )

        $RequiredPsModules | ForEach-Object {
            if (-not (Get-Module $_ -ListAvailable -ErrorAction SilentlyContinue)) {
                Install-Module $_ -Force
            }
            Import-Module $_
        }
    }

    process {
        
        # Get existing credentials from the credential manager
        $HuduApi = Get-StoredCredential -Target 'JCPR/HuduApi'
        $JcApi = Get-StoredCredential -Target 'JCPR/JcApi'

        # If the credentials don't exist, prompt the user for them
        if ($null -eq $HuduApi) {
            $HuduCreds = Get-Credential -Message 'Enter your Hudu API Key'
            New-StoredCredential -Target 'JCPR/HuduApi' -Credential $HuduCreds -Type Generic -Persist LocalMachine
            $HuduApi = Get-StoredCredential -Target 'JCPR/HuduApi'
        }
        if ($null -eq $JcApi) {
            $JcCreds = Get-Credential -Message 'Enter your JumpCloud API Key'
            New-StoredCredential -Target 'JCPR/JcApi' -Credential $JcCreds -Type Generic -Persist LocalMachine
            $JcApi = Get-StoredCredential -Target 'JCPR/JcApi'
        }

        # Connect to the APIs
        New-HuduAPIKey -ApiKey (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/HuduApi').Password -AsPlainText)
        New-HuduBaseURL -BaseURL $HuduBaseUrl
        Connect-JCOnline -JumpCloudAPIKey (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/JcApi').Password -AsPlainText) -JumpCloudOrgID $JcOrgId

    }
    end {

    }
}