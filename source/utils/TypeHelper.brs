function isFloat32(item as dynamic) as boolean
    return type(item) = "Float" or type(item) = "roFloat"
end function

function isFloat64(item as dynamic) as boolean
    return type(item) = "Double" or type(item) = "roDouble"
end function

function isFloat(item as dynamic) as boolean
    return isFloat32(item) or isFloat64(item)
end function

function isInteger32(item as dynamic) as boolean
    return type(item) = "roInteger" or type(item) = "Integer" or type(item) = "roInt"
end function

function isInteger64(item as dynamic) as boolean
    return type(item) = "LongInteger" or type(item) = "roLongInteger"
end function

function isInteger(item as dynamic) as boolean
    return isInteger32(item) or isInteger64(item)
end function

function isString(item as dynamic) as boolean
    return type(item) = "String" or type(item) = "roString"
end function

function isNumber(item as dynamic) as boolean
    return isInteger(item) or isFloat(item)
end function