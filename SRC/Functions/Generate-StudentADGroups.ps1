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
        $ElementaryGrups = "InetFilter-MES"

        if($SchoolID -eq '51'){
            # adds middle school groups
            $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $MidleSchoolGroups -force
        } else {
            # adds elementary school groups
            $Student | Add-Member -MemberType NoteProperty -Name "ADGroups" -Value $ElementaryGrups -force
        }

        $Student

    }

    
    end {
        
    }
}