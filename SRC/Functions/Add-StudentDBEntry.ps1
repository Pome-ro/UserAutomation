function Add-StudentDBEntry {
    [CmdletBinding()]
    param (
        # Student Object
        [Parameter(Mandatory)]
        [PSCustomObject[]]
        $Student
    )
    
    begin {
        
    }
    
    process {
        $Entry = "`"$($Student.Guid)`",`"$($Student.SamAccountName)`",`"$($Student.OU)`",`"$($Student.PasswordAsPlainText)`",`"$($Student.Email)`""
        Write-Host "Writing to DB: $Entry"
        Add-Content -Path $StudentDBPath -Value $Entry
    }
    
    end {
        
    }
}