load_skeleton_json :: (data: string, scale: float32 = 1) -> *Base_Skeleton_Data {
	success, root := json_parse_string(data);
	if !success {
		log_error("Could not parse json data!");
		return null;
	}
	
	

	/*
        const version = dataToParse.skeleton.spine;
        const ver = detectSpineVersion(version);
        let parser: any = null;

        if (ver === SPINE_VERSION.VER37) {
            parser = new spine37.SkeletonJson(new spine37.AtlasAttachmentLoader(atlas));
        }
        if (ver === SPINE_VERSION.VER38) {
            parser = new spine38.SkeletonJson(new spine38.AtlasAttachmentLoader(atlas));
        }
        if (ver === SPINE_VERSION.VER40 || ver === SPINE_VERSION.VER41) {
            parser = new spine41.SkeletonJson(new spine41.AtlasAttachmentLoader(atlas));
        }
        if (!parser) {
            const error = `Unsupported version of spine model ${version}, please update pixi-spine`;

            console.error(error);
        }

        parser.scale = this.scale;

        return parser.readSkeletonData(dataToParse);
    */
        
        
        
	if has(root, "skeleton") {
		print("Has skeleton!\n");
	}

	print("@todo\n");
	return null;
}


#scope_file


has :: (json_val: JSON_Value, key: string) -> bool {
	if json_val.type == .OBJECT {
		return Hash_Table.table_contains(json_val.object, key);
	} else {
		assert(false);
		return false;
	}
}

get :: (json_val: JSON_Value, key: string, expected_type: JSON_Type) -> JSON_Value {
    assert(json_val.type == .OBJECT);
    table := json_val.object;
    val, success := Hash_Table.table_find(table, key);
    assert(success);
    assert(val.type == expected_type);
    return val;
}


#import "jaison";
Hash_Table :: #import "Hash_Table";