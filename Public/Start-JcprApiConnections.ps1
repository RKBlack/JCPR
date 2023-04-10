function Start-JcprApiConnections {
    param (
        [string]$HuduBaseUrl,
        [string]$JcOrgId
    )
    
    Import-Module HuduApi
    Import-Module JumpCloud
    Import-Module TUN.CredentialManager

    $HuduApi = Get-StoredCredential -Target 'JCPR/HuduApi'
    $JcApi = Get-StoredCredential -Target 'JCPR/JcApi'

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

    New-HuduAPIKey -ApiKey (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/HuduApi').Password -AsPlainText)
    New-HuduBaseURL -BaseURL $HuduBaseUrl
    Connect-JCOnline -JumpCloudAPIKey (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/JcApi').Password -AsPlainText) -JumpCloudOrgID $JcOrgId

}