Function Get-GradYear {

    [CmdletBinding()]
    param
    (
        [int]$GradeLevel,
        [Switch]$TwoDigit
    )
    # this function calculates the Grad Year by taking the Grade_Level as input
    # and counting, starting at Grade_Level till 8 (which is when students graduate)
    # and adding that ammount to the current year.
    # it then returns that value so we can store it later.

    $month = 7, 8, 9, 10, 11, 12
    $curMonth = (Get-Date).Month
    if ($month -contains $curMonth) {
        $SchoolYear = $(get-date).year + 1
    } else {
        $SchoolYear = $(get-date).year
    }

    $yeartilgrad = 8 - $GradeLevel
    [string]$gradyear = $SchoolYear + $yeartilgrad

    if ($TwoDigit) {
        return $gradyear.Substring(2, 2)
    } else {
        return $gradyear
    }
}