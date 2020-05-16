function Exit-Student {
    [CmdletBinding()]
    param (
        # Student Object
        [Parameter(Mandatory)]
        [Object]
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