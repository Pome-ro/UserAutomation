function Exit-Student {
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
        Write-Host "Exiting Student..."
    }
    
    end {
        
    }
}