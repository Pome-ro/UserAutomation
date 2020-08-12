function Add-StudentDBEntry {
    [CmdletBinding()]
    param (
        # Student Object
        [Parameter(Mandatory)]
        [PSCustomObject[]]
        $Student, 
        # Path
        [Parameter(Mandatory)]
        [String]
        $Path
    )
    
    begin {
        
    }
    
    process {
        $StudentObj = New-Object -TypeName psobject

        $StudentObj | Add-Member -MemberType NoteProperty -Name GUID  -Value $Student.GUID
        $StudentObj | Add-Member -MemberType NoteProperty -Name SamAccountName -Value $Student.SamAccountName
        $StudentObj | Add-Member -MemberType NoteProperty -Name OU  -Value $Student.OU
        $StudentObj | Add-Member -MemberType NoteProperty -Name SchoolID  -Value $Student.SchoolID
        $StudentObj | Add-Member -MemberType NoteProperty -Name ADGroups  -Value $Student.ADGroups
        $StudentObj | Add-Member -MemberType NoteProperty -Name PasswordAsPlainText  -Value $Student.PasswordAsPlainText
        $StudentObj | Add-Member -MemberType NoteProperty -Name Email  -Value $Student.Email
        $StudentObj | Add-Member -MemberType NoteProperty -Name GradYear  -Value $Student.CalcGradYear
        $StudentObj | Add-Member -MemberType NoteProperty -Name DateCreated  -Value (Get-Date)
        $StudentObj | Add-Member -MemberType NoteProperty -Name DateModified  -Value (Get-Date)
        
        #$Entry = "`"$($Student.Guid)`",`"$($Student.SamAccountName)`",`"$($Student.OU)`",`"$($Student.PasswordAsPlainText)`",`"$($Student.Email)`",`"$($Student.CalcGradYear)`",`"$(Get-Date)`",`"$(Get-Date)`""
        #Write-Host "Writing to DB: $Entry"
        #Add-Content -Path $Path -Value $Entry

        $StudentOBJ
    }
    
    end {
        
    }
}