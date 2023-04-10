function New-JcprPassword {
    [CmdletBinding()]
    param (
        [int]$WordCount = 4
    )

    begin {

    }
    process {
        $WordList = Import-Csv .\words.txt
        $i = $WordCount - 1
        $NewPasswordSeed = $WordList | Get-Random -Count $wordCount | ForEach-Object { $_.word }
        while ($i -ge 0) {
            if ($i % 2 -eq 0) {
                $NewPasswordSeed[$i] = $NewPasswordSeed[$i].ToUpper()
            }
            $i--
        }
        $NewPassword = ($NewPasswordSeed -join '-') + "$(Get-Random -Minimum 10 -Maximum 99)"
        return $NewPassword
    }
    end {
    
    }
}