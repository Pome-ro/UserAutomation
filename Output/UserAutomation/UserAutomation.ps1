Function Get-GradYear {

    [CmdletBinding()]
    param
    (
        [int]$GradeLevel,
        [Switch]$TwoDigit
    )
    # this function calculates the Grad Year by taking the Grade_Level as input
    # and counting, starting at Grade_Level till 8 (which is when students graduate)
    # and adding that ammount to the current year.
    # it then returns that value so we can store it later.

    $month = 7, 8, 9, 10, 11, 12
    $curMonth = (Get-Date).Month
    if ($month -contains $curMonth) {
        $SchoolYear = $(get-date).year + 1
    } else {
        $SchoolYear = $(get-date).year
    }

    $yeartilgrad = 8 - $GradeLevel
    [string]$gradyear = $SchoolYear + $yeartilgrad

    if ($TwoDigit) {
        return $gradyear.Substring(2, 2)
    } else {
        return $gradyear
    }
}
function Generate-StudentUsername {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $Student
    )
    
    begin {

    }
    
    process {
        Write-Host "Processing $($student.guid)" -ForegroundColor Green
        $CurSubString = 1
        $GradYear = Get-GradYear -GradeLevel $Student.Grade_Level -TwoDigit
        $Student | Add-Member -MemberType NoteProperty -Name "CalcGradYear" -Value $GradYear
        $SamAccountName = $student.Last_name + $student.First_Name.SubString(0,$curSubString) + $Student.CalcGradYear

        $Duplicates = Get-ADUser -Filter "SamAccountName -like '$($SamAccountName)*'"
    
        if ($Null -eq $Duplicates) {
            Write-Host "No Duplicates Found" -ForegroundColor Green
            $Student | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $SamAccountName
            $Student
        } 

        if ($Null -ne $Duplicates) {
            Write-Host "Duplicates Found" -ForegroundColor Red
            $SamAccountName
            $Duplicates.SamAccountName
            
            do {
                $CurSubString = $CurSubString + 1
                $SamAccountName = $student.last_name + $student.First_Name.SubString(0,$curSubString) + $Student.CalcGradYear
            } until ($null -eq $($Duplicates | Where-Object {$_.SamAccountName -eq $SamAccountName}))

            $Student | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $SamAccountName
            $Student
        }
    }
    
    end {
        
    }
}
function Generate-StudentPassword {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $Student,
        
        [Parameter()]
        [PSCustomObject]
        $Datablob
    )
    
    begin {

    }
    
    process {
        $MiddleSchool = $False
        if ($Student.schoolid -eq $Datablob.School.ID.MMS) {
            $MiddleSchool = $True
        } else {
            $MiddleSchool = $False
        }

        if ($MiddleSchool -eq $False) {
            $Birthday = Get-Date $student.dob -format Mdyyyy
            $Password = $student.First_Name.ToLower().substring(0, 1) + $student.Last_Name.ToLower().Substring(0, 1) + $Birthday
            $Student | Add-Member -MemberType NoteProperty -Name "PasswordAsPlainText" -Value $Password
            $Student
        }

        if ($MiddleSchool -eq $True) {
            # return Get-Random -Minimum 10000000 -Maximum 99999999
            $password = -join (((50..57) + (97..104) + (106..107) + (109..110) + (112..122))  | Get-Random -Count 8 | ForEach-Object {[char]$_})
            $Student | Add-Member -MemberType NoteProperty -Name "PasswordAsPlainText" -Value $Password
            $Student
        }
    }

    
    end {
        
    }
}
function Generate-StudentADProperties {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $Student,
        # Parameter help description
        [Parameter()]
        [PSCustomObject]
        $DataBlob
    )
    
    begin {

    }
    
    process {
        $SchoolID = $Student.SchoolID
        $SchoolData = $DataBlob.School.$SchoolID
        $OU = "OU=" + $Student.CalcGradYear + "," + $SchoolData.ou.students
        $description = $SchoolData.Shortname + " Student"
        $DisplayName = $Student.Last_name + ", " + $Student.First_Name
        $scriptPath = "Student" + $SchoolData.Initials + ".bat"
        $Student | Add-Member -memberType NoteProperty -Name "OU" -Value $OU
        $Student | Add-Member -MemberType NoteProperty -Name "Email" -Value ($Student.SamAccountName + "@mpssites.org")
        $Student | Add-Member -MemberType NoteProperty -Name "Pager" -Value $Student.StudentNumber
        $Student | Add-Member -MemberType NoteProperty -Name "Description" -Value $description
        $Student | Add-Member -MemberType NoteProperty -Name "DisplayName" -Value $DisplayName
        $Student | Add-Member -MemberType NoteProperty -Name "scriptPath" -Value $scriptPath
        $Student

    }

    
    end {
        
    }
}
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

# ---------------- Start Script ---------------- #
$Config = Import-PowershellDataFile -Path "$PSScriptRoot\Config.psd1"
$Data = Import-PowershellDataFile -Path (Join-Path -Path $Config.BaseDirectory -ChildPath $Config.DataBlobFileName)
Import-Module -Name $Config.RequiredModules

$OutplacedID = $Data.School.ID.Outplaced
$PSStudents = Get-MPSAStudent -filter {$_.SchoolID -ne $OutplacedID} -DataBlob $Data
$StudentDBPath = (Join-Path -Path $Data.rootPath -ChildPath $Data.fileNames.studentAccountDB)
$StudentDB = Import-CSV -Path $StudentDBPath

# Filter out Outplaced students

$Dif = Compare-Object -ReferenceObject ($PSStudents.GUID) -DifferenceObject ($StudentDB.GUID)

$OnboardingStudents = $Dif | Where-Object {$_.SideIndicator -eq "<="}
$OffboardingStudents = $Dif | Where-Object {$_.SideIndicator -eq "=>"}
$ADUsers = Get-ADUser -filter "EmployeeNumber -like '*'" -Properties EmployeeNumber,displayname,distinguishedname

$ConfirmedUniqueUsernames = @()
$ExistingUsers = @()

ForEach ($ID in $OnboardingStudents){
    $NewStudent = $PSStudents | Where-Object {$_.GUID -eq $ID.InputObject}
    $exactMatch = $ADUsers | Where-Object {$_.Employeenumber -eq $NewStudent.GUID}

    if ($null -ne $exactMatch) {
        
        <#
        Write-Host "Found in AD"
        $DNArry = $exactMatch.distinguishedname -split ","
        $OU = $DNArry[2..$DNArry.length] -join ","
        
        $NewStudent | Add-Member -memberType NoteProperty -Name "SamAccountName" -Value $exactMatch.SamAccountName
        $NewStudent | Add-Member -MemberType NoteProperty -Name "OU" -Value $OU
        $NewStudent | Add-Member -MemberType NoteProperty -Name "Exists" -Value $TRUE
        $NewStudent | Add-Member -MemberType NoteProperty -Name "Email" -Value $ExactMatch.UserPrincipalName
        $NewStudent = Generate-StudentPassword -Student $NewStudent

        $ExistingUsers += $NewStudent
        #>

    } else {
        Write-Host "Not Found In AD"
        $NewStudent.schoolid

        $NewStudent = Generate-StudentUserName -Student $NewStudent
        $NewStudent = Generate-StudentPassword -Student $NewStudent
        $NewStudent = Generate-StudentADProperties -Student $NewStudent

        $ConfirmedUniqueUsernames += $NewStudent
    }

}

ForEach ($Student in $ConfirmedUniqueUsernames) {
    $Student.schoolid
    Add-StudentDBEntry -student $Student
    New-ADUser -Name $student.displayname -SamAccountName $student.SamAccountName -Path $student.ou -ScriptPath $student.scriptpath -DisplayName $student.displayname -Description $student.Description -mail $student.email -WhatIf
}










