load_skeleton_binary :: (data: string, scale: float32 = 1) -> *Base_Skeleton_Data {
    read_version_old :: (data: string) -> Optional(string) {
        read_string(*data);
        return read_string(*data);
    }

    read_version_new :: (data: string) -> Optional(string) {
        read_u32(*data);
        read_u32(*data);
        return read_string(*data);
    }

    version_string := read_version_old(data);
    spine_version := detect_spine_version(version_string);

    if spine_version == .Version38 {
        return Skeleton_3_Binary_Read.load(data, scale, spine_version);
    }

    version_string = read_version_new(data);
    spine_version = detect_spine_version(version_string);

    if spine_version == .Version40 || spine_version == .Version41 {
        return Skeleton_4_Binary_Read.load(data, scale, spine_version);
    }

    log("Unsupported spine version: %\n", version_string);
    return null;
}


#scope_file


#import "String";
#import "Basic";
#import "Bit_Operations";
