write_skeleton_binary :: (using skeleton: *Base_Skeleton_Data, optimize: bool) -> string {
    builder: String_Builder;

    if skeleton.loader_version == {
        case .Version37; #through;
        case .Version38;
            Skeleton_3_Binary_Write.write(*builder, skeleton, optimize);

        case .Version40; #through;
        case .Version41;
            Skeleton_4_Binary_Write.write(*builder, skeleton, optimize);
    }

    return builder_to_string(*builder);
}
