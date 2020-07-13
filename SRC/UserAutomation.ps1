
# ---------------- Start Script ---------------- #


$Config = Import-PowershellDataFile -Path "$PSScriptRoot\Config.psd1"
$Data = Import-PowershellDataFile -Path (Join-Path -Path $Config.BaseDirectory -ChildPath $Config.DataBlobFileName)
Import-Module -Name $Config.RequiredModules

$PSStudents = Get-MPSAStudent -filter {$_.Name -like "*"} -DataBlob $Data
$StudentDBPath = (Join-Path -Path $Data.rootPath -ChildPath $Data.fileNames.studentAccountDB)
$StudentDB = Import-CSV -Path $StudentDBPath

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
        $NewStudentUsername = Generate-StudentUserName -Student $NewStudent
        $NewStudentUsername = Generate-StudentPassword -Student $NewStudent

        $ConfirmedUniqueUsernames += $NewStudentUsername
    }

}

ForEach ($student in $ExistingUsers) {
    $Entry = "`"$($Student.Guid)`",`"$($Student.SamAccountName)`",`"$($Student.OU)`",`"$($Student.PasswordAsPlainText)`",`"$($Student.Email)`""
    Write-Host "Writing to DB: $Entry"
    #Add-Content -Path $StudentDBPath -Value $Entry
}

<#
$NewStudent = Generate-StudentPassword -Student $NewStudent
$NewStudent = Generate-StudentADProperties -Student $NewStudent
Add-StudentDBEntry -Student $NewStudent -DB $StudentDBPath
#>

<#
$ExitedStudentResults = ForEach ($LeavingStudent in $OffboardingStudents) {
    Disable-ADAccount -Identity
    Move-ADObject -object -ou $pathtodisabledou
    Exit-Student -Student $LeavingStudent
    Remove-StudentDBEntry
}#>