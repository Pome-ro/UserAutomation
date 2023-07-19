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
        $Fname = Remove-Symbols -string $Student.First_Name
        $Finit = $student.First_Name.SubString(0,$curSubString)

        $intGradYear = [int]$student.CalcGradYear

        if ($intGradYear -ge 2030) {
            Write-Host "Processing New Naming Convention"
            $SamAccountName = $student.student_number
            $UserPrincipalName = "$($student.student_number)@mpssites.org"
            $Duplicates = Get-ADUser -Filter "SamAccountName -like '$($SamAccountName)*'"
            
            if ($Null -ne $Duplicates) {
                Write-Host "Duplicates Found" -ForegroundColor Red
                
                do {
                    $CurSubString = $CurSubString + 1 
                    $Finit = $student.First_Name.SubString(0,$curSubString)
                    $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
                } until ($null -eq $($Duplicates | Where-Object {$_.SamAccountName -eq $SamAccountName}))
            }
            
        } else {
            Write-Host "Processing Old Naming Convention"
            $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
            If($SamAccountName.Length -gt 20){
                Write-host "Name To Long" -ForegroundColor Red
                do {
                    $lname = $lname.substring($Lname.length - 1)
                    $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
                } until ($SamAccountName.length -lt 21)
            }
            $UserPrincipalName = "$SamAccountName@mpssites.org"
            $Duplicates = Get-ADUser -Filter "SamAccountName -like '$($SamAccountName)*'"
            
            if ($Null -ne $Duplicates) {
                Write-Host "Duplicates Found" -ForegroundColor Red
                
                do {
                    $CurSubString = $CurSubString + 1 
                    $Finit = $student.First_Name.SubString(0,$curSubString)
                    $SamAccountName = $Lname + $Finit + $Student.CalcGradYear2digit
                } until ($null -eq $($Duplicates | Where-Object {$_.SamAccountName -eq $SamAccountName}))
            }
        }
       

        $Student | Add-Member -MemberType NoteProperty -Name "SamAccountName" -Value $SamAccountName
        $Student | Add-Member -MemberType NoteProperty -Name "UserPrincipalName" -Value $UserPrincipalName

        $Student
    }
    
    end {
        
    }
}