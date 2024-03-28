write_skeleton_binary :: (using skeleton: * Base_Skeleton_Data, optimize: bool) -> string {
    builder: String_Builder;

    if skeleton.loader_version == {
        case .Version37; #through;
        case .Version38;
            Skeleton_Binary_3.write(*builder, skeleton, optimize);

        case .Version40; #through;
        case .Version41;
            Skeleton_Binary_4.write(*builder, skeleton, optimize);
    }

    return builder_to_string(*builder);
}


#scope_file


Skeleton_Binary_3 :: #import,file "skeleton_3_binary_write.jai";
Skeleton_Binary_4 :: #import,file "skeleton_4_binary_write.jai";

#import,file "binary_write.jai";
#import,file "skeleton.jai";

