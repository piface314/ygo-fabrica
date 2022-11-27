function string.trim(s)
    return s:match("^%s*(.-)%s*$")
end