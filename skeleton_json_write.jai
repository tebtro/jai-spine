write_skeleton_json :: (using skeleton: *Base_Skeleton_Data, optimize: bool) -> string {
    builder: String_Builder;

    if skeleton.loader_version == {
        case .Version37; #through;
        case .Version38;
            Skeleton_3_Json_Write.write(*builder, skeleton, optimize);

        case .Version40; #through;
        case .Version41;
        	assert(false, "TODO");
    }

    return builder_to_string(*builder);
}
