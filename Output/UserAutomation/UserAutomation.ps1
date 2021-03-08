
<#PSScriptInfo

.VERSION 1.0.13

.GUID 539d6a11-ba99-4fb0-9f51-d5a8c8c6ba93

.AUTHOR Mansfield Public Schools

.COMPANYNAME Mansfield Public Schools

.COPYRIGHT

.TAGS

.LICENSEURI

.PROJECTURI

.ICONURI

.EXTERNALMODULEDEPENDENCIES 

.REQUIREDSCRIPTS

.EXTERNALSCRIPTDEPENDENCIES

.RELEASENOTES


.PRIVATEDATA

#>

<# 

.DESCRIPTION 
 Automates Users 

#> 
Param()


Function Remove-Symbols {
    param(
        [string]
        $string
    )
    [regex]$reg = "[^\p{L}\p{Nd}]"
    return $string -replace $reg
}

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
        $Student | Add-Member -MemberType NoteProperty -Name "CalcGradYear" -Value (Get-GradYear -GradeLevel $Student.Grade_Level)
        $Student | Add-Member -MemberType NoteProperty -Name "CalcGradYear2digit" -Value $(Get-GradYear -GradeLevel $Student.Grade_Level -TwoDigit)
        $Lname = Remove-Symbols -string $Student.Last_Name
        $Finit = $student.First_Name.SubString(0,$curSubString)

        $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
        
        If($SamAccountName.Length -gt 20){
            Write-host "Name To Long" -ForegroundColor Red
            do {
                $lname = $lname.substring($Lname.length - 1)
                $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
            } until ($SamAccountName.length -lt 21)
        }
        
        $Duplicates = Get-ADUser -Filter "SamAccountName -like '$($SamAccountName)*'"
        
        if ($Null -ne $Duplicates) {
            Write-Host "Duplicates Found" -ForegroundColor Red
            
            do {
                $CurSubString = $CurSubString + 1 
                $Finit = $student.First_Name.SubString(0,$curSubString)
                $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
            } until ($null -eq $($Duplicates | Where-Object {$_.SamAccountName -eq $SamAccountName}))
        }

        $Student | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $SamAccountName
        $Student
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
        $SchoolID = [string]$Student.SchoolID
        $SchoolData = $DataBlob.School.$SchoolID

        if ($Student.SchoolID -ne '51') {
            $Birthday = Get-Date $student.dob -format Mdyyyy
            $Password = $student.First_Name.ToLower().substring(0, 1) + $student.Last_Name.ToLower().Substring(0, 1) + $Birthday
            $Student | Add-Member -MemberType NoteProperty -Name "PasswordAsPlainText" -Value $Password
            $Student
        }

        if ($Student.SchoolID -eq '51') {
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
        $SchoolID = [string]$Student.SchoolID
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
function Generate-StudentADGroups {
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
        
        $MidleSchoolGroups = "G$($Student.GradYear),AD-MMS-Print-Students,InetFilter-5-8"
        $ElementaryGrups = "AD-Pk4-Student-Print,Students,$($SchoolData.Initials)Students"

        switch ($schoolid) {
            '51' { $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $MidleSchoolGroups -force }
            {$_ -eq'2' -or '4' -or '5'} { $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $ElementaryGrups -force }
            Default {}
        }

        $Student

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
        $Student, 
        # Path
        [Parameter(Mandatory)]
        [String]
        $Path
    )
    
    begin {
        
    }
    
    process {
        $StudentObj = New-Object -TypeName psobject

        $StudentObj | Add-Member -MemberType NoteProperty -Name GUID  -Value $Student.GUID
        $StudentObj | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $Student.SamAccountName
        $StudentObj | Add-Member -MemberType NoteProperty -Name OU  -Value $Student.OU
        $StudentObj | Add-Member -MemberType NoteProperty -Name SchoolID  -Value $Student.SchoolID
        $StudentObj | Add-Member -MemberType NoteProperty -Name ADGroups  -Value $Student.ADGroups
        $StudentObj | Add-Member -MemberType NoteProperty -Name PasswordAsPlainText  -Value $Student.PasswordAsPlainText
        $StudentObj | Add-Member -MemberType NoteProperty -Name Email  -Value $Student.Email
        $StudentObj | Add-Member -MemberType NoteProperty -Name GradYear  -Value $Student.CalcGradYear
        $StudentObj | Add-Member -MemberType NoteProperty -Name DateCreated  -Value (Get-Date)
        $StudentObj | Add-Member -MemberType NoteProperty -Name DateModified  -Value (Get-Date)
        
        #$Entry = "`"$($Student.Guid)`",`"$($Student.SamAccountName)`",`"$($Student.OU)`",`"$($Student.PasswordAsPlainText)`",`"$($Student.Email)`",`"$($Student.CalcGradYear)`",`"$(Get-Date)`",`"$(Get-Date)`""
        #Write-Host "Writing to DB: $Entry"
        #Add-Content -Path $Path -Value $Entry

        $StudentOBJ
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
$PSStudents = $PSStudents | where-object {$_.EnrollStatus -eq -1 -or $_.EnrollStatus -eq 0}
$StudentDBPath = (Join-Path -Path $Data.rootPath -ChildPath $Data.fileNames.studentAccountDB)
$StudentDB = Import-CSV -Path $StudentDBPath

# Filter out Outplaced students

$Dif = Compare-Object -ReferenceObject ($PSStudents.GUID) -DifferenceObject ($StudentDB.GUID)

$OnboardingStudents = $Dif | Where-Object {$_.SideIndicator -eq "<="}
$OffboardingStudents = $Dif | Where-Object {$_.SideIndicator -eq "=>"}

$ConfirmedUniqueUsernames = @()

$ADUsers = Get-ADUser -Filter "*" -Properties distinguishedname,SamAccountName,UserPrincipalName,Employeenumber

##########################
# Create New Students Begin

ForEach ($ID in $OnboardingStudents){
    $NewStudent = $PSStudents | Where-Object {$_.GUID -eq $ID.InputObject}
    $exactMatch = $ADUsers | Where-Object {$_.Employeenumber -eq $NewStudent.GUID}

    if ($null -ne $exactMatch) {
    
    
        Write-Host "Found in AD" -ForegroundColor Yellow
        $DNArry = $exactMatch.distinguishedname -split ","
        $OU = $DNArry[2..$DNArry.length] -join ","
    
        $NewStudent | Add-Member -memberType NoteProperty -Name "SamAccountName" -Value $exactMatch.SamAccountName
        $NewStudent | Add-Member -MemberType NoteProperty -Name "OU" -Value $OU
        $NewStudent | Add-Member -MemberType NoteProperty -Name "Email" -Value $ExactMatch.UserPrincipalName
        $NewStudent = Generate-StudentPassword -Student $NewStudent

        $StudentData = Add-StudentDBEntry -student $NewStudent -Path $StudentDBPath
        $StudentDB += $StudentData
    

    } else {
        Write-Host "Not Found In AD" -ForegroundColor Green

        $NewStudent = Generate-StudentUserName -Student $NewStudent
        Write-Host $NewStudent.SamAccountName
        $NewStudent = Generate-StudentPassword -Student $NewStudent
        $NewStudent = Generate-StudentADProperties -Student $NewStudent -DataBlob $data
        $NewStudent = Generate-StudentADGroups -Student $NewStudent -DataBlob $data
        #$NewStudent = Generate-StudentHomeDirPath -Student $NewStudent -DataBlob $data

        $StudentData = Add-StudentDBEntry -student $NewStudent -Path $StudentDBPath
        $StudentDB += $StudentData
    }
}

$MMS5thGrade =  $ADUsers | Where-Object {$_.distinguishedname -like "*OU=2024,OU=OUstudents,OU=All-Users,OU=_MMS,DC=mps,DC=mansfieldct,DC=net"}

foreach ($Student in $MMS5thGrade) {
    Write-Host $Student.distinguishedname
}

$BackupName = $Data.fileNames.studentAccountDB + ".$(Get-Date -format MM.dd.yyyy.HH.mm)" + ".backup"
Rename-Item -Path $StudentDBPath -NewName $BackupName
$StudentDB | ConvertTo-Csv -NoTypeInformation | Out-File $StudentDBPath

# Create New Students End
##########################









