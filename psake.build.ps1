$functions = Get-ChildItem .\SRC\Functions\ -Filter *.ps1

foreach($function in $functions){
    include $function.FullName
}

properties {
    $ScriptName = "UserAutomation"
    $OutputPath = Join-Path -Path .\ -ChildPath Output
    $ScriptPath = Join-Path -Path $OutputPath -ChildPath $ScriptName
}

task default -depends clean, build, "Test\Functions"

task "Test\Functions" {
    $mms = [PSCustomObject]@{
        SchoolID = '51'
        GradYear = '2026' # UPDATE THIS EACH YEAR
        Grade_Level = "5"
        Last_Name = "Kafka"
        First_Name = "Jimmy"
        student_number = "12345"
        DOB = "8/26/2011"
    }
    $elm = [PSCustomObject]@{
        SchoolID = '6'
        GradYear = '2027' # UPDATE THIS EACH YEAR
        Grade_Level = "4"
        Last_Name = "Picard-Sampson"
        First_Name = "Brock"
        student_number = "54321"
        DOB = "8/26/2012"
    }
    $elmNC = [PSCustomObject]@{
        SchoolID = '6'
        GradYear = '2032' # UPDATE THIS EACH YEAR
        Grade_Level = "-1"
        Last_Name = "Picard-Sampson"
        First_Name = "Frank"
        student_number = "87654"
        DOB = "8/26/2012"
    }
    $data = [PSCustomObject]@{
        school = @{
            '51' = @{
                Initials = 'MMS'
                ou = @{
                    Students = "OU=OUstudents,OU=All-Users,OU=_MMS,DC=mps,DC=mansfieldct,DC=net"
                }
            }
            '4' = @{
                Initials = 'GN'
            }
            '6' = @{
                Initials = 'MES'
                ou = @{
                    Students = "OU=MES Students,OU=Students,OU=Users,OU=_Mansfield Public Schools,DC=mps,DC=mansfieldct,DC=net"
                }
            }
        }
    }

    $SymbleTest = "!@#July%^&"

    $Results = @{
        mms = Generate-StudentUserName -student $mms
        elm = Generate-StudentUserName -student $elm
        elmNC = Generate-StudentUserName -student $elmNC
        symbols = Remove-Symbols $SymbleTest
    }
    $Expectations = @{
        mms = @{
            UserName = "KafkaJ26"
            Password = ""
            ADGroups = "G2026,AD-MMS-Print-Students,InetFilter-5-8"
            ADProperties = @{
                OU = "ou=" + $MMS.GradYear + "," + $data.school.'51'.ou.students
                Email = "KafkaJ26@mpssites.org"
                Pager = $mms.student_number
                Description = $data.school.'51'.Initials + " Student"
                DisplayName = $mms.Last_Name + ", " + $mms.First_Name
                scriptPath = "mms2.bat"
            }
        }
        elm = @{
            UserName = "PicardSampsonB27"
            Password = "bp8262012"
            ADGroups = "InetFilter-MES"
            ADProperties = @{
                OU = "ou=" + $elm.GradYear + "," + $data.school.'6'.ou.students
                Email = "PicardSampsonB27@mpssites.org"
                Pager = $elm.student_number
                Description = $data.school.'6'.Initials + " Student"
                DisplayName = $elm.Last_Name + ", " + $elm.First_Name
                scriptPath = "StudentMES.bat"
            }
        }
        elmNC = @{
            UserName = "87654"
            Password = "fp8262012"
            ADGroups = "InetFilter-MES"
            ADProperties = @{
                OU = "ou=" + $elmNC.GradYear + "," + $data.school.'6'.ou.students
                Email = "87654@mpssites.org"
                Pager = $elmNC.student_number
                Description = $data.school.'6'.Initials + " Student"
                DisplayName = $elmNC.Last_Name + ", " + $elmNC.First_Name
                scriptPath = "StudentMES.bat"
            }
        }
        symbols = "July"
    }
    
    
    Assert ($Results.symbols -eq $Expectations.symbols) "Result should have been $($Results.symbols), it was $($Expectations.symbols)"
    Assert ($Results.mms.SamAccountName -eq $Expectations.mms.UserName -or $Results.mms.SamAccountName -eq "") "Error: Expected Username $($Expectations.mms.UserName) received $($Results.mms.SamAccountName) instead"
    
    $Results.mms = Generate-StudentPassword -student $Results.mms
    $Results.mms = Generate-StudentADProperties -student $Results.mms -DataBlob $data
    $Results.mms = Generate-StudentADGroups -student $Results.mms -DataBlob $data
    
    Assert ($Results.mms.password -ne "") "Password is blank"
    Assert ($Results.mms.OU -like "$($Expectations.mms.ADProperties.OU)") "MMS: OU does not contain the grade year: $($Results.mms.OU)"
    Assert ($Results.mms.Email -eq $Expectations.mms.ADProperties.Email) "MMS: Email does not match $($Results.mms.Email) vs $($Expectations.mms.ADProperties.Email)"
    Assert ($Results.mms.Pager -eq $Expectations.mms.ADProperties.Pager) "MMS: Pager does not match $($Results.mms.Pager) vs $($Expectations.mms.ADProperties.Pager)"
    Assert ($Results.mms.Description -eq $Expectations.mms.ADProperties.Description) "MMS: Description does not match $($Results.mms.Description) vs $($Expectations.mms.ADProperties.Description)"
    Assert ($Results.mms.ADGroups -ne $null -or $Results.mms.ADGroups -ne "") "MMS: ADGrups Property Missing"
    Assert ($Results.mms.ADGroups -eq $Expectations.mms.ADGroups) "MMS: Groups Wrong: Should be '$($Results.mms.ADGroups)' but was '$($Expectations.mms.ADGroups)' instead"
    
    $Results.elm = Generate-StudentPassword -student $Results.elm
    $Results.elm = Generate-StudentADProperties -student $Results.elm -DataBlob $data
    $Results.elm = Generate-StudentADGroups -student $Results.elm -DataBlob $data
    
    Assert ($Results.elm.password -ne "") "Password is blank"
    Assert ($Results.elm.OU -like "$($Expectations.elm.ADProperties.OU)") "ELM: OU does not contain the grade year $($Results.elm.OU) vs $($Expectations.elm.ADProperties.OU)"
    Assert ($Results.elm.Email -eq $Expectations.elm.ADProperties.Email) "ELM: Email does not match $($Results.elm.Email) vs $($Expectations.elm.ADProperties.Email)"
    Assert ($Results.elm.Pager -eq $Expectations.elm.ADProperties.Pager) "ELM: Pager does not match $($Results.elm.Pager) vs $($Expectations.elm.ADProperties.Pager)"
    Assert ($Results.elm.Description -eq $Expectations.elm.ADProperties.Description) "ELM: Description does not match $($Results.elm.Description) vs $($Expectations.elm.ADProperties.Description)"
    Assert ($Results.elm.ADGroups -ne $null -or $Results.elm.ADGroups -ne "") "ELM: ADGrups Property Missing"
    Assert ($Results.elm.ADGroups -eq $Expectations.elm.ADGroups) "ELM: Groups Wrong: Should be '$($Results.elm.ADGroups)' but was $($Expectations.elm.ADGroups) instead"

    $Results.elmNC = Generate-StudentPassword -student $Results.elmNC
    $Results.elmNC = Generate-StudentADProperties -student $Results.elmNC -DataBlob $data
    $Results.elmNC = Generate-StudentADGroups -student $Results.elmNC -DataBlob $data
    
    Assert ($Results.elmNC.password -ne "") "Password is blank"
    Assert ($Results.elmNC.OU -like "$($Expectations.elmNC.ADProperties.OU)") "ELMNC: OU does not contain the grade year $($Results.elmNC.OU) vs $($Expectations.elmNC.ADProperties.OU)"
    Assert ($Results.elmNC.Email -eq $Expectations.elmNC.ADProperties.Email) "ELMNC: Email does not match $($Results.elmNC.Email) vs $($Expectations.elmNC.ADProperties.Email)"
    Assert ($Results.elmNC.Pager -eq $Expectations.elmNC.ADProperties.Pager) "ELMNC: Pager does not match $($Results.elmNC.Pager) vs $($Expectations.elmNC.ADProperties.Pager)"
    Assert ($Results.elmNC.Description -eq $Expectations.elmNC.ADProperties.Description) "ELMNC: Description does not match $($Results.elmNC.Description) vs $($Expectations.elmNC.ADProperties.Description)"
    Assert ($Results.elmNC.ADGroups -ne $null -or $Results.elmNC.ADGroups -ne "") "ELMNC: ADGrups Property Missing"
    Assert ($Results.elmNC.ADGroups -eq $Expectations.elmNC.ADGroups) "ELMNC: Groups Wrong: Should be '$($Results.elmNC.ADGroups)' but was $($Expectations.elmNC.ADGroups) instead"
}

task Clean {
    if (Test-Path -Path "$OutputPath") {
        Remove-Item -Path $OutputPath -Recurse
        New-Item -Path .\ -ItemType Directory -Name "Output" | Out-Null
        New-Item -Path $OutputPath -Name $ScriptName -ItemType Directory | Out-Null
    } else {
        New-Item -Path .\ -ItemType Directory -Name "Output" | Out-Null
        New-Item -Path $OutputPath -Name $ScriptName -ItemType Directory | Out-Null
    }

}

task Build -depends Clean,"Test\Functions" {
    $Functions = Get-ChildItem ".\SRC\Functions\"
    $Version = "$(Get-Date -format "yy.M.d").$((New-TimeSpan -Hours (Get-Date -format "HH") -Minutes (Get-Date -format "mm")).totalminutes)"

    Copy-Item -Path ".\SRC\$ScriptName.ps1" -Destination $ScriptPath
    Copy-Item -Path ".\SRC\Config.psd1" -Destination $ScriptPath
    
    # Export Public Functions
    foreach ($Function in $Functions) {
        $Content = Get-Content -Path $Function.FullName | Out-String
        $Content + (Get-Content -Path "$ScriptPath\$ScriptName.ps1" | Out-String) | Set-Content "$ScriptPath\$ScriptName.ps1"
        # Add-Content -Value $content -Path "$ScriptPath\$ScriptName.psm1"
    }
    $Content = Get-Content -Path .\src\ScriptProperties.ps1 | Out-String
    $Content = $Content -replace "{{version}}",$version
    $Content + (Get-Content -Path "$ScriptPath\$ScriptName.ps1" | Out-String) | Set-Content "$ScriptPath\$ScriptName.ps1"

}

task Publish -depends Build {
    Publish-Script -Path "$ScriptPath\$ScriptName.ps1" -Repository "MPSPSRepo"
}