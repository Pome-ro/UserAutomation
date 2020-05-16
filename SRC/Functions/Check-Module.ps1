function Check-Module {
    [CmdletBinding()]
    param (
        # Sample 
        [Parameter(Mandatory)]
        [String[]]
        $Name
    )
    
    begin {
        
    }
    
    process {
        if (!(Get-Module -Name $Name -ListAvailable)) {
            Install-Module -Name $Name -Scope CurrentUser
        }
    }
    
    end {
        
    }
}