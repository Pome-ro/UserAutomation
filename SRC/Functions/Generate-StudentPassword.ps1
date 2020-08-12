function Generate-StudentPassword {
    [CmdletBinding()]
    param (
        [Parameter()]
        [PSCustomObject[]]
        $Student,
        
        [Parameter()]
        [PSCustomObject]
        $Datablob
    )
    
    begin {

    }
    
    process {
        $MiddleSchool = $False
        $SchoolID = [string]$Student.SchoolID
        $SchoolData = $DataBlob.School.$SchoolID

        if ($Student.SchoolID -ne '51') {
            $Birthday = Get-Date $student.dob -format Mdyyyy
            $Password = $student.First_Name.ToLower().substring(0, 1) + $student.Last_Name.ToLower().Substring(0, 1) + $Birthday
            $Student | Add-Member -MemberType NoteProperty -Name "PasswordAsPlainText" -Value $Password
            $Student
        }

        if ($Student.SchoolID -eq '51') {
            # return Get-Random -Minimum 10000000 -Maximum 99999999
            $password = -join (((50..57) + (97..104) + (106..107) + (109..110) + (112..122))  | Get-Random -Count 8 | ForEach-Object {[char]$_})
            $Student | Add-Member -MemberType NoteProperty -Name "PasswordAsPlainText" -Value $Password
            $Student
        }
    }

    
    end {
        
    }
}