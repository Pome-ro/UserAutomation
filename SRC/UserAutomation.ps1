
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