function Generate-StudentHomeDir {
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
        
        $MidleSchoolGroups = $SchoolData.BaseHomeDir + "\$($Student.CalcGradYear)\$($Student.SamAccountname)"
        $ElementaryGrups = ""

        switch ($schoolid) {
            '51' { $Student | Add-Member -MemberType NoteProperty -Name "HomeDirectory" -Value $MidleSchoolGroups }
            Default {}
        }

        $Student

    }

    
    end {
        
    }
}