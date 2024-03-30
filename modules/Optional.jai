Optional :: struct(T: Type) {
    has_value: bool;
    value: T;
}

create_optional :: (value: $T) -> Optional(T) {
    return .{
        has_value = true,
        value = value,
    };
}

operator == :: (a: Optional, b: Optional) -> bool {
    if a.has_value != b.has_value  return false;
    if !a.has_value || !b.has_value  return true;
    return a.value == b.value;
}