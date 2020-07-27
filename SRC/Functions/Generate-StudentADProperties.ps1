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