Spine_Version :: enum {
    Unknown   ::  0;
    Version37 :: 37;
    Version38 :: 38;
    Version40 :: 40;
    Version41 :: 41;
}

detect_spine_version :: (version_string: Optional(string)) -> Spine_Version {
    if !version_string.has_value  return .Unknown;

    sub3 := slice(version_string.value, 0, 3);
    if sub3 == {
        case "3.7";  return .Version37;
        case "3.8";  return .Version38;
        case "4.0";  return .Version40;
        case "4.1";  return .Version41;
        case;
            if string_to_float(sub3) < 3.7 {
                return .Version37;  // Try to parse older versions with 3.7!
            } else {
                return .Unknown;
            }
    }
}
