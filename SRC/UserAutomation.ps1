# ---------------- Start Script ---------------- #
$Config = Import-PowershellDataFile -Path ".\Config.psd1"
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
        #$NewStudent = Generate-StudentADGroups -Student $NewStudent -DataBlob $data
        #$NewStudent = Generate-StudentHomeDirPath -Student $NewStudent -DataBlob $data

        $StudentData = Add-StudentDBEntry -student $NewStudent -Path $StudentDBPath
        $StudentDB += $StudentData
    }
}
$BackupName = $Data.fileNames.studentAccountDB + ".$(Get-Date -format MM.dd.yyyy.HH.mm)" + ".backup"
Rename-Item -Path $StudentDBPath -NewName $BackupName
$StudentDB | ConvertTo-Csv -NoTypeInformation | Out-File $StudentDBPath

# Create New Students End
##########################

##########################
# Update Student Information Start

<#
$StudentDB = foreach ($Student in $StudentDB) {
    $PSObj = $PSStudents | Where-Object {$_.GUID -eq $Student.GUID}
    $PSObj | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $Student.SamAccountName
    $PSObj | Add-Member -MemberType NoteProperty -Name "CalcGradYear" -Value $Student.Gradyear
    $PSObj = Generate-StudentADProperties -Student $PSObj -DataBlob $Data
    $PSObj = Generate-StudentADGroups -Student $PSObj -DataBlob $Data
    Write-Host $PSObj.OU
    Write-Host $Student.Ou
    if ($PSObj.OU -ne $Student.OU) {
        $Student.OU = $PSObj.OU
        Write-Host "OU Changed" -ForegroundColor Green
    } else {
        Write-Host "OU Not Changed" -ForegroundColor Red
    }
    $Student
}

$BackupName = $Data.fileNames.studentAccountDB + ".$(Get-Date -format MM.dd.yyyy.HH.mm)" + ".backup"
Rename-Item -Path $StudentDBPath -NewName $BackupName
$StudentDB | ConvertTo-Csv -NoTypeInformation | Out-File $StudentDBPath
#>
# Update Student Information End
##########################
