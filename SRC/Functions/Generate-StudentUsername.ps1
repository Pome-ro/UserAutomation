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