
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
        $NewStudent = Generate-StudentADProperties -Student $NewStudent -DataBlob $data
        $NewStudent = Generate-StudentADGroups -Student $NewStudent -DataBlob $data
        $NewStudent = Generate-StudentHomeDir -Student $NewStudent -DataBlob $data

        $ConfirmedUniqueUsernames += $NewStudent
    }

}

ForEach ($Student in $ConfirmedUniqueUsernames) {
    $Student.schoolid
    Add-StudentDBEntry -student $Student

    New-ADUser -Name $student.displayname -SamAccountName $student.SamAccountName -Path $student.ou -ScriptPath $student.scriptpath -DisplayName $student.displayname -Description $student.Description -mail $student.email -WhatIf
    
    foreach ($group in $student.adgroups) {

        try {
            Add-ADGroupMember $group $student.samaccountname
        } catch {

        }
        if ($?) {

        }
    }

}

$NewStudentResults = ForEach ($NewStudent in $OnboardingStudents){
    $NewStudent = Generate-StudentUserName -Student $NewStudent
    $NewStudent = Generate-StudentPassword -Student $NewStudent
    $NewStudent = Generate-StudentADProperties -Student $NewStudent
    Add-StudentDBEntry -Student $NewStudent -DB $StudentDBPath
}

$ExitedStudentResults = ForEach ($LeavingStudent in $OffboardingStudents) {
    Disable-ADAccount -Identity
    Move-ADObject -object -ou $pathtodisabledou
    Exit-Student -Student $LeavingStudent
    Remove-StudentDBEntry
}
