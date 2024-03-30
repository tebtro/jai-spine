load_skeleton_binary :: (data: string, scale: float32 = 1) -> * Base_Skeleton_Data {
    read_version_old :: (data: string) -> Optional(string) {
        read_string(*data);
        return read_string(*data);
    }

    read_version_new :: (data: string) -> Optional(string) {
        read_u32(*data);
        read_u32(*data);
        return read_string(*data);
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

    version_string := read_version_old(data);
    spine_version := detect_spine_version(version_string);

    if spine_version == .Version38 {
        return Skeleton_Binary_3.load(data, scale, spine_version);
    }

    version_string = read_version_new(data);
    spine_version = detect_spine_version(version_string);

    if spine_version == .Version40 || spine_version == .Version41 {
        return Skeleton_Binary_4.load(data, scale, spine_version);
    }

    log("Unsupported spine version: %\n", version_string);
    return null;
}


#scope_file


Skeleton_Binary_3 :: #import,file "skeleton_3_binary_read.jai";
Skeleton_Binary_4 :: #import,file "skeleton_4_binary_read.jai";

#import,file "modules/Optional.jai";

#import,file "binary_read.jai";
#import,file "skeleton.jai";

#import "String";
#import "Basic";
#import "Bit_Operations";
