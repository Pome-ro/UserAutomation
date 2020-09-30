Function Remove-Symbols {
    param(
        [string]
        $string
    )
    [regex]$reg = "[^\p{L}\p{Nd}]"
    return $string -replace $reg
}

