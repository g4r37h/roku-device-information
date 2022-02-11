function ternary(condition as boolean, valueIfTrue as dynamic, valueIfFalse as dynamic) as dynamic
    if condition then return valueIfTrue
    return valueIfFalse
end function

function getValue(value as dynamic, default as dynamic) as dynamic
    if isString(value)
        if value <> "" then return value
        return default
    else if isNumber(value)
        if value <> 0 then return value
        return default
    end if
    if value <> invalid then return value
    return default
end function
