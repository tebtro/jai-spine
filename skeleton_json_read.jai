load_skeleton_json :: (data: string, scale: float32 = 1) -> *Base_Skeleton_Data {
	success, root := json_parse_string(data);
	if !success {
		log_error("Could not parse json data!");
		return null;
	}
	
	skeleton_node := get(root, "skeleton", .OBJECT);
	version_node := get(skeleton_node, "spine", .STRING);
    spine_version := detect_spine_version(create_optional(version_node.str));
	
	if spine_version == .Version38 {
        return Skeleton_3_Json_Read.load(root, scale, spine_version);
	}
	
    log_error("Unsupported version of spine model '%'!", spine_version);
	return null;
}
