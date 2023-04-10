function Invoke-JcPasswordRotation {
    [CmdletBinding()]
    
    param (
        [string]$Email
    )

    begin {

    }

    process {
        $JcUser = Get-JCUser | Where-Object { $_.email -eq $Email }
        $JcCompany = Get-JCOrganization | Where-Object { $_.OrgID -eq $JcUser.organization }
        $JcAgentComputer = Get-JCSystem | Where-Object { $_.hostname -eq (hostname) }
        $JcSystemUser = Get-JCSystemUser $JcAgentComputer._id
        $RemoveJcSystemUser = $false
        if (-not ($JcSystemUser.username -contains $JcUser.username)) {
            $RemoveJcSystemUser = $true
            Add-JCSystemUser -SystemID $JcAgentComputer._id -UserID $JcUser._id
            Write-Host 'Waiting 30 seconds for JumpCloud to sync the user to this computer'
            Start-Sleep 30            
            $JcUser = Get-JCUser | Where-Object { $_.email -eq $Email }
            $JcCompany = Get-JCOrganization | Where-Object { $_.OrgID -eq $JcUser.organization }
            $JcAgentComputer = Get-JCSystem | Where-Object { $_.hostname -eq (hostname) }
            $JcSystemUser = Get-JCSystemUser $JcAgentComputer._id
            if (-not ($JcSystemUser.username -contains $JcUser.username)) {
                Write-Error 'JumpCloud did not sync the user to this computer'
                exit 3
            }
        }
    
        $HuduCompany = Get-HuduCompanies | Where-Object { $_.Name -eq $JcCompany.displayName }
        $HuduPassword = Get-HuduPasswords -CompanyId $HuduCompany.id | Where-Object { $_.username -eq $Jcuser.username }
    
        Add-Type -AssemblyName System.DirectoryServices.AccountManagement
        $CredTestObj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $(hostname))
        if (-not $CredTestObj.ValidateCredentials($HuduPassword.username, $HuduPassword.password)) {
            Write-Error 'Hudu password is not valid'
            exit 4
        }
        $CredTestObj.Dispose()
        net use \\$(hostname)\IPC$ /delete

        $NewJcPassword = New-JcprPassword

        try {
            Set-HuduPassword -CompanyId $HuduCompany.id -Id $HuduPassword.id -Password $NewJcPassword -Name $HuduPassword.Name -ErrorAction Stop | Out-Null
        }
        catch {
            Write-Error $_
            exit 1
        }
        $ChangedHuduPassword = Get-HuduPasswords -CompanyId $HuduCompany.id | Where-Object { $_.username -eq $Jcuser.username }
        if ($ChangedHuduPassword.password -ne $NewJcPassword) {
            Write-Error 'Hudu password did not change'
            exit 2
        }

        Set-JCUser -UserID $JcUser.id -password $NewJcPassword | Out-Null
        Start-Sleep 30
        Get-Service 'jumpcloud-agent' | Restart-Service
        Start-Sleep 30
        $CredTestObj = New-Object System.DirectoryServices.AccountManagement.PrincipalContext('machine', $(hostname))
        if (-not $CredTestObj.ValidateCredentials($ChangedHuduPassword.username, $ChangedHuduPassword.password)) {
            Write-Error 'The new Hudu password is not valid'
            exit 5
        }
        if ($RemoveJcSystemUser) {
            Remove-JCSystemUser -SystemID $JcAgentComputer._id -UserID $JcUser._id
            Start-Sleep 30
            net user $JcUser.username /DELETE 
        }
        $CredTestObj.Dispose()
        net use \\$(hostname)\IPC$ /delete
    }

    end {

    }
}
