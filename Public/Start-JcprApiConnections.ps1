function Start-JcprApiConnections {
    [CmdletBinding()]
    param (
        [switch]$Silent
    )

    begin {

        $RequiredAssemblies = @(
            'System.Windows.Forms',
            'System.Drawing',
            'PresentationFramework'
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
        
        $UpdateStoredCredentials = $false

        $HuduBaseUrl = Get-StoredCredential -Target 'JCPR/HuduBaseUrl' -ErrorAction SilentlyContinue
        $HuduApi = Get-StoredCredential -Target 'JCPR/HuduApi' -ErrorAction SilentlyContinue
        $JcOrgId = Get-StoredCredential -Target 'JCPR/JcOrgId' -ErrorAction SilentlyContinue
        $JcApi = Get-StoredCredential -Target 'JCPR/JcApi' -ErrorAction SilentlyContinue

        if (($null -ne $HuduBaseUrl) -or ($null -ne $HuduApi) -or ($null -ne $JcOrgId) -or ($null -ne $JcApi) -and -not $Silent) {
            Write-Verbose 'All API Connection Information is stored in the Credential Manager.'

            $ReplaceMessage = 'Would  you like to replace the existing stored API connection information?'
            $ReplaceTitle = 'Replace Stored Credentials?'
            $ReplaceType = 'YesNo'
            $ReplaceResult = [System.Windows.MessageBox]::Show($ReplaceMessage, $ReplaceTitle, $ReplaceType)

            if ($ReplaceResult -eq 'Yes') {
                Remove-StoredCredential -Target 'JCPR/HuduBaseUrl' -ErrorAction SilentlyContinue
                Remove-StoredCredential -Target 'JCPR/HuduApi' -ErrorAction SilentlyContinue
                Remove-StoredCredential -Target 'JCPR/JcOrgId' -ErrorAction SilentlyContinue
                Remove-StoredCredential -Target 'JCPR/JcApi' -ErrorAction SilentlyContinue
                $UpdateStoredCredentials = $true
            }
        }
        
        if (($null -eq $HuduBaseUrl) -or ($null -eq $HuduApi) -or ($null -eq $JcOrgId) -or ($null -eq $JcApi) -or $UpdateStoredCredentials) {

            if ($Silent) {
                Write-Error 'API Connection Information is not stored in the Credential Manager. Please run the script without the -Silent switch.'
                return
            }

            $ApiForm = New-Object Windows.Forms.Form
            $ApiForm.Text = 'Enter your API Connection Information'
            $ApiForm.Size = New-Object System.Drawing.Size(400, 320)
            $ApiForm.StartPosition = 'CenterScreen'

            $HuduBaseUrlLabel = New-Object System.Windows.Forms.Label
            $HuduBaseUrlLabel.Location = New-Object System.Drawing.Point(10, 10)
            $HuduBaseUrlLabel.Size = New-Object System.Drawing.Size(340, 20)
            $HuduBaseUrlLabel.Text = 'Enter the Hudu BaseUrl:'
            $ApiForm.Controls.Add($HuduBaseUrlLabel)

            $HuduBaseUrlForm = New-Object Windows.Forms.TextBox
            $HuduBaseUrlForm.Location = New-Object System.Drawing.Point(10, 30)
            $HuduBaseUrlForm.Size = New-Object System.Drawing.Size(340, 20)
            $HuduBaseUrlForm.Height = 80
            $ApiForm.Controls.Add($HuduBaseUrlForm)        
            
            $HuduApiLabel = New-Object System.Windows.Forms.Label
            $HuduApiLabel.Location = New-Object System.Drawing.Point(10, 60)
            $HuduApiLabel.Size = New-Object System.Drawing.Size(340, 20)
            $HuduApiLabel.Text = 'Enter the Hudu API Key:'
            $ApiForm.Controls.Add($HuduApiLabel)

            $HuduApiForm = New-Object Windows.Forms.MaskedTextBox
            $HuduApiForm.PasswordChar = '*'
            $HuduApiForm.Location = New-Object System.Drawing.Point(10, 80)
            $HuduApiForm.Size = New-Object System.Drawing.Size(340, 20)
            $HuduApiForm.Height = 80
            $ApiForm.Controls.Add($HuduApiForm)        

            $JcOrgIdLabel = New-Object System.Windows.Forms.Label
            $JcOrgIdLabel.Location = New-Object System.Drawing.Point(10, 110)
            $JcOrgIdLabel.Size = New-Object System.Drawing.Size(340, 20)
            $JcOrgIdLabel.Text = 'Enter the JumpCloud Org Id:'
            $ApiForm.Controls.Add($JcOrgIdLabel)
         
            $JcOrgIdForm = New-Object Windows.Forms.TextBox
            $JcOrgIdForm.Location = New-Object System.Drawing.Point(10, 130)
            $JcOrgIdForm.Size = New-Object System.Drawing.Size(340, 20)
            $JcOrgIdForm.Height = 80
            $ApiForm.Controls.Add($JcOrgIdForm)

            $JcApiLabel = New-Object System.Windows.Forms.Label
            $JcApiLabel.Location = New-Object System.Drawing.Point(10, 160)
            $JcApiLabel.Size = New-Object System.Drawing.Size(340, 20)
            $JcApiLabel.Text = 'Enter the JumpCloud API Key:'
            $ApiForm.Controls.Add($JcApiLabel)
         
            $JcApiForm = New-Object Windows.Forms.MaskedTextBox
            $JcApiForm.PasswordChar = '*'
            $JcApiForm.Location = New-Object System.Drawing.Point(10, 180)
            $JcApiForm.Size = New-Object System.Drawing.Size(340, 20)
            $JcApiForm.Height = 80
            $ApiForm.Controls.Add($JcApiForm)        
        
            $ApiFormOkButton = New-Object System.Windows.Forms.Button
            $ApiFormOkButton.Location = New-Object System.Drawing.Point(115, 240)
            $ApiFormOkButton.Size = New-Object System.Drawing.Size(75, 23)
            $ApiFormOkButton.Text = 'OK'
            $ApiFormOkButton.DialogResult = [System.Windows.Forms.DialogResult]::OK
            $ApiForm.AcceptButton = $ApiFormOkButton
            $ApiForm.Controls.Add($ApiFormOkButton)

            $ApiFormCancelButton = New-Object System.Windows.Forms.Button
            $ApiFormCancelButton.Location = New-Object System.Drawing.Point(210, 240)
            $ApiFormCancelButton.Size = New-Object System.Drawing.Size(75, 23)
            $ApiFormCancelButton.Text = 'Cancel'
            $ApiFormCancelButton.DialogResult = [System.Windows.Forms.DialogResult]::Cancel
            $ApiForm.CancelButton = $ApiFormCancelButton
            $ApiForm.Controls.Add($ApiFormCancelButton)

            $ApiForm.ShowDialog()
        
            $null = New-StoredCredential -Target 'JCPR/HuduBaseUrl' -UserName 'HuduBaseUrl' -Password $HuduBaseUrlForm.Text -Type Generic -Persist LocalMachine
            $HuduApi = Get-StoredCredential -Target 'JCPR/HuduBaseUrl'

            $null = New-StoredCredential -Target 'JCPR/HuduApi' -UserName 'HuduAPI' -Password $HuduApiForm.Text -Type Generic -Persist LocalMachine
            $HuduApi = Get-StoredCredential -Target 'JCPR/HuduApi'

            $null = New-StoredCredential -Target 'JCPR/JcOrgId' -UserName 'JcOrgId' -Password $JcOrgIdForm.Text -Type Generic -Persist LocalMachine
            $JcOrgId = Get-StoredCredential -Target 'JCPR/JcOrgId'

            $null = New-StoredCredential -Target 'JCPR/JcApi' -UserName 'JcAPI' -Password $JcApiForm.Text -Type Generic -Persist LocalMachine
            $JcApi = Get-StoredCredential -Target 'JCPR/JcApi'

        }

        New-HuduAPIKey -ApiKey (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/HuduApi').Password -AsPlainText)
        New-HuduBaseURL -BaseURL (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/HuduBaseUrl').Password -AsPlainText)
        $JCOnlineParams = @{
            JumpCloudAPIKey = (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/JcApi').Password -AsPlainText)
            JumpCloudOrgID = (ConvertFrom-SecureString (Get-StoredCredential -Target 'JCPR/JcOrgId').Password -AsPlainText)
        }
        Connect-JCOnline @JCOnlineParams | Out-Null

    }
    
    end {

    }
}
