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
function Create-Student {
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
        Write-Host "Creating Student..."
    }
    
    end {
        
    }
}
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

# ---------------- Start Script ---------------- #


$Config = Import-PowershellDataFile -Path "$PSScriptRoot\Config.psd1"
$Data = Import-PowershellDataFile -Path (Join-Path -Path $Config.BaseDirectory -ChildPath $Config.DataBlobFileName)
Import-Module -Name $Config.RequiredModules

$PSStudents = Get-MPSAStudent -filter {$_.Name -like "*"} -DataBlob $Data
$StudentDB = Import-CSV -Path (Join-Path -Path $Data.rootPath -ChildPath $Data.fileNames.studentAccountDB)

$Dif = Compare-Object -ReferenceObject ($PSStudents.GUID) -DifferenceObject ($StudentDB.GUID)

$ItemsNotInDB = $Dif | Where-Object {$_.SideIndicator -eq "<="}
$ItemsNotInPS = $Dif | Where-Object {$_.SideIndicator -eq "=>"}


$NewStudentResults = ForEach ($NewStudent in $ItemsNotInDB){
    Create-Student -Student $NewStudent
}

$ExitedStudentResults = ForEach ($LeavingStudent in $ItemsNotInPS) {
    Exit-Student -Student $LeavingStudent
}



