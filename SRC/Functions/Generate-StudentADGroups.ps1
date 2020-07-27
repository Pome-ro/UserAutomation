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
        
        $MidleSchoolGroups = "G$($CalcGradYear)", "AD-MMS-Print-Students", "InetFilter-5-8"
        $ElementaryGrups = "AD-Pk4-Student-Print", "Students", "$($SchoolData.Initials)Students"

        switch ($schoolid) {
            '51' { $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $MidleSchoolGroups }
            {$_ -eq'2' -or '4' -or '5'} { $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $ElementaryGrups }
            Default {}
        }

        $Student

    }

    
    end {
        
    }
}