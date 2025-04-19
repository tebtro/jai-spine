Skeleton_3_Json_Read :: struct {
	using Skeleton_3;
	using Json_Read;

	load :: (root: JSON_Value, scale: float64, spine_version: Spine_Version) -> *Skeleton_Data {
        using skeleton := New(Skeleton_Data);
        
        success: bool;
        
		if has(root, "skeleton") {
			skeleton_node := get(root, "skeleton", .OBJECT);
			hash = get_optional_string(skeleton_node, "hash");
			version = get_optional_string(skeleton_node, "spine");
			
			if !version.has_value {
				log_error("Spine does not contain a version number!");
				return null;
			}
			
    		if slice(version.value, 0, 3) != "3.8" {
                log_error("Spine 3.8 loader cant load version '%'!", version.value);
                return null;
            }
            
            if version.value == "3.8.75" {
            	log_error("Unsupported skeleton data, 3.8.75 is deprecated, please export with a newer version of Spine!");
            	return null;
            }
			
			x      = get_number(skeleton_node, "x", 0);
			y      = get_number(skeleton_node, "y", 0);
			width  = get_number(skeleton_node, "width", 0);
			height = get_number(skeleton_node, "height", 0);
			fps    = get_number(skeleton_node, "fps", 0);
			images_path = get_optional_string(skeleton_node, "images");
			audio_path  = get_optional_string(skeleton_node, "audio");
		}
		
		if has(root, "bones") {
			bones_node := get(root, "bones", .ARRAY);
			
			array_reserve(*bones, bones_node.array.count);
			
			for bone_node: bones_node.array {
				if bone_node.type != .OBJECT {
					log_error("Bone is not an object!");
					return null;
				}
				
                bone := array_add(*bones);
                bone.name = get_optional_string(bone_node, "name");
                if !bone.name.has_value || !bone.name.value {
                    log("Bone name must not be null!");
                    return null;
                }
                
                parent_name := get_optional_string(bone_node, "parent");
                bone.parent = find_bone_index(skeleton, parent_name);
                bone.length         = get_number(bone_node, "length", 0) * scale;
                bone.x              = get_number(bone_node, "x", 0) * scale;
                bone.y              = get_number(bone_node, "y", 0) * scale;
                bone.rotation       = get_number(bone_node, "rotation", 0);
                bone.scale_x        = get_number(bone_node, "scaleX", 1);
                bone.scale_y        = get_number(bone_node, "scaleY", 1);
                bone.shear_x        = get_number(bone_node, "shearX", 0);
                bone.shear_y        = get_number(bone_node, "shearY", 0);
                
                transform_mode_string := get_string(bone_node, "transform", "normal");
                success, bone.transform_mode = transform_mode_from_string(transform_mode_string);
                if !success {
                	log_error("Unknown transform mode: '%'!", transform_mode_string);
                	return null;
                }
                
                bone.skin_required  = get_bool(bone_node, "skin", false);
                
                success, bone.color = get_color(bone_node, "color", 0xffffffff);
                if !success {
                	return null;
                }
			}
		}
		
		if has(root, "slots") {
			slots_node := get(root, "slots", .ARRAY);
			
			array_reserve(*slots, slots_node.array.count);
			
			for slot_node: slots_node.array {
				if slot_node.type != .OBJECT {
					log_error("Slot is not an object!");
					return null;
				}
				
                slot := array_add(*slots);
                slot.name = get_optional_string(slot_node, "name");
                if !slot.name.has_value || !slot.name.value {
                    log("Slot name must not be null!");
                    return null;
                }
                
                bone_name := get_optional_string(slot_node, "bone");
                slot.bone = find_bone_index(skeleton, bone_name);
                
                success, slot.color = get_color(slot_node, "color", 0xffffffff);
                if !success {
                	return null;
                }
                
                success, slot.dark_color = get_color(slot_node, "dark", 0xffffffff);
                if !success {
                	return null;
                }
                
                slot.attachment_name = get_string_reference(slot_node, "attachment", *shared_strings);
                
                blend_mode_string := get_string(slot_node, "blend", "normal");
                success, slot.blend_mode = blend_mode_from_string(blend_mode_string);
                if !success {
                	log_error("Unknown blend mode: '%'!", blend_mode_string);
                	return null;
                }
			}
		}
		
		if has(root, "ik") {
			iks_node := get(root, "ik", .ARRAY);
			
			array_reserve(*ik_constraints, iks_node.array.count);
			
			for ik_node: iks_node.array {
				if ik_node.type != .OBJECT {
					log_error("IK is not an object!");
					return null;
				}
				
                ik := array_add(*ik_constraints);
                ik.name = get_optional_string(ik_node, "name");
                if !ik.name.has_value || !ik.name.value {
                    log("Ik constraint name must not be null!");
                    return null;
                }
                
                ik.order         = xx get_number(ik_node, "order", 0);
                ik.skin_required = get_bool(ik_node, "skin", false);
                
                bones_node := get(ik_node, "bones", .ARRAY);
                array_reserve(*ik.bones, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    array_add(*ik.bones, bone_index);
                }
                
                target_name := get_optional_string(ik_node, "target");
                ik.target = find_bone_index(skeleton, target_name);
                
                ik.mix            = get_number(ik_node, "mix", 1);
                ik.softness       = get_number(ik_node, "softness", 0) * scale;
                ik.bend_direction = xx ifx get_bool(ik_node, "bendPositive", true) then 1 else -1;
                ik.compress       = get_bool(ik_node, "compress", false);
                ik.stretch        = get_bool(ik_node, "stretch", false);
                ik.uniform        = get_bool(ik_node, "uniform", false);
			}
		}
		
		if has(root, "transform") {
			transform_constraints_node := get(root, "transform", .ARRAY);
			
			array_reserve(*transform_constraints, transform_constraints_node.array.count);
			
			for constraint_node: transform_constraints_node.array {
				if constraint_node.type != .OBJECT {
					log_error("Transform is not an object!");
					return null;
				}
				
                constraint := array_add(*transform_constraints);
                constraint.name = get_optional_string(constraint_node, "name");
                if !constraint.name.has_value || !constraint.name.value {
                    log("Transform constraint name must not be null!");
                    return null;
                }
                
                constraint.order         = xx get_number(constraint_node, "order", 0);
                constraint.skin_required = get_bool(constraint_node, "skin", false);
                
                bones_node := get(constraint_node, "bones", .ARRAY);
                array_reserve(*constraint.bones, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    array_add(*constraint.bones, bone_index);
                }
                
                target_name := get_optional_string(constraint_node, "target");
                constraint.target = find_bone_index(skeleton, target_name);
                
                constraint.local           = get_bool(constraint_node, "local", false);
                constraint.relative        = get_bool(constraint_node, "relative", false);
                constraint.offset_rotation = get_number(constraint_node, "rotation", 0);
                constraint.offset_x        = get_number(constraint_node, "x", 0) * scale;
                constraint.offset_y        = get_number(constraint_node, "y", 0) * scale;
                constraint.offset_scale_x  = get_number(constraint_node, "scaleX", 0);
                constraint.offset_scale_y  = get_number(constraint_node, "scaleY", 0);
                constraint.offset_shear_y  = get_number(constraint_node, "shearY", 0);
                constraint.rotate_mix      = get_number(constraint_node, "rotateMix", 1);
                constraint.translate_mix   = get_number(constraint_node, "translateMix", 1);
                constraint.scale_mix       = get_number(constraint_node, "scaleMix", 1);
                constraint.shear_mix       = get_number(constraint_node, "shearMix", 1);
			}
		}
		
		if has(root, "path") {
			path_constraints_node := get(root, "path", .ARRAY);
			
			array_reserve(*path_constraints, path_constraints_node.array.count);
			
			for constraint_node: path_constraints_node.array {
                constraint := array_add(*path_constraints);
                constraint.name = get_optional_string(constraint_node, "name");
                if !constraint.name.has_value || !constraint.name.value {
                    log("Path constraint name must not be null!");
                    return null;
                }
                
                constraint.order         = xx get_number(constraint_node, "order", 0);
                constraint.skin_required = get_bool(constraint_node, "skin", false);
                
                bones_node := get(constraint_node, "bones", .ARRAY);
                array_reserve(*constraint.bones, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    array_add(*constraint.bones, bone_index);
                }
                
                target_name := get_optional_string(constraint_node, "target");
                constraint.target = find_bone_index(skeleton, target_name);
                
                position_mode_string := get_string(constraint_node, "positionMode", "percent");
                success, constraint.position_mode = path_position_mode_from_string(position_mode_string);
                if !success {
                	log_error("Unknown position mode: '%'!", position_mode_string);
                	return null;
                }
                
                spacing_mode_string := get_string(constraint_node, "spacingMode", "length");
                success, constraint.spacing_mode = path_spacing_mode_from_string(spacing_mode_string);
                if !success {
                	log_error("Unknown spacing mode: '%'!", spacing_mode_string);
                	return null;
                }
                
                rotate_mode_string := get_string(constraint_node, "rotateMode", "tangent");
                success, constraint.rotate_mode = path_rotate_mode_from_string(rotate_mode_string);
                if !success {
                	log_error("Unknown rotate mode: '%'!", rotate_mode_string);
                	return null;
                }
                
                constraint.offset_rotation = get_number(constraint_node, "rotation", 0);
                constraint.position        = get_number(constraint_node, "position", 0);
                if constraint.position_mode == .FIXED then constraint.position *= scale;
                constraint.spacing         = get_number(constraint_node, "spacing", 0);
                if constraint.spacing_mode == .LENGTH || constraint.spacing_mode == .FIXED then constraint.spacing *= scale;
                constraint.rotate_mix      = get_number(constraint_node, "rotateMix", 1);
                constraint.translate_mix   = get_number(constraint_node, "translateMix", 1);
			}
		}
		
		if has(root, "skins") {
			skins_node := get(root, "skins", .ARRAY);
			
			array_reserve(*skins, skins_node.array.count);
			
			for skin_node: skins_node.array {
                skin := array_add(*skins);
                success := read_skin(skeleton, skin, skin_node, scale);
                if !success {
                    log("Error while loading skin!");
                    return null;
                }
			}
		}
		
		//print("Paths: %\n", path_constraints);
		
		log_error("@todo");
		return skeleton;
	}
	
    read_skin :: (using skeleton: *Skeleton_Data, skin: *Skin, skin_node: JSON_Value, scale: float64) -> bool #must {
        skin.name = get_string_reference(skin_node, "name", *shared_strings);
        if !skin.name.data.has_value || !skin.name.data.value {
            log("Skin name must not be null!");
            return false;
        }
        
        //log("Read skin: %", skin.name);
        if skin.name.data.value == "default" {
        	default_skin = skin;
        }
        
        names: [..] string;
        names.allocator = temp;
        
        if has(skin_node, "bones") {
        	success := get_string_array(skin_node, "bones", *names);
        	if !success then return false;
        	
        	array_reserve(*skin.bones, names.count);
        	
        	for names {
        		bone_index := find_bone_index(skeleton, it);
        		if bone_index < 0 {
        			log_error("Could not find bone '%'!", it);
        			return false;
        		}
        		
        		array_add(*skin.bones, bone_index);
        	}
        	
        	names.count = 0;
        }
        
        if has(skin_node, "ik") {
        	success := get_string_array(skin_node, "ik", *names);
        	if !success then return false;
        	
        	array_reserve(*skin.ik_constraints, names.count);
        	
        	for names {
        		constraint_index := find_ik_constraint_index(skeleton, it);
        		if constraint_index < 0 {
        			log_error("Could not find bone '%'!", it);
        			return false;
        		}
        		
        		array_add(*skin.ik_constraints, constraint_index);
        	}
        	
        	names.count = 0;
        }
        
        if has(skin_node, "transform") {
        	success := get_string_array(skin_node, "transform", *names);
        	if !success then return false;
        	
        	array_reserve(*skin.transform_constraints, names.count);
        	
        	for names {
        		constraint_index := find_transform_constraint_index(skeleton, it);
        		if constraint_index < 0 {
        			log_error("Could not find bone '%'!", it);
        			return false;
        		}
        		
        		array_add(*skin.transform_constraints, constraint_index);
        	}
        	
        	names.count = 0;
        }
        
        if has(skin_node, "path") {
        	success := get_string_array(skin_node, "path", *names);
        	if !success then return false;
        	
        	array_reserve(*skin.path_constraints, names.count);
        	
        	for names {
        		constraint_index := find_path_constraint_index(skeleton, it);
        		if constraint_index < 0 {
        			log_error("Could not find bone '%'!", it);
        			return false;
        		}
        		
        		array_add(*skin.path_constraints, constraint_index);
        	}
        	
        	names.count = 0;
        }
        
        if has(skin_node, "attachments") {
        	attachments_node := get(skin_node, "attachments", .OBJECT);
        	
        	array_reserve(*skin.slots, attachments_node.object.count);
        	
        	for attachments_node.object {
        		slot_name := it_index;
        		slot_node := it;
        	
                if slot_node.type != .OBJECT {
                    log_error("Slot is not an object!");
                    return false;
                }
        	
                slot := array_add(*skin.slots);
                slot.index = find_slot_index(skeleton, slot_name);
                
                array_reserve(*slot.attachments, slot_node.object.count);
                
                for slot_node.object {
                	attachment_name := it_index;
                	attachment_node := it;
                	
                    if attachment_node.type != .OBJECT {
                        log_error("Attachment is not an object!");
                        return false;
                    }

                    //log("Read attachment: %", attachment_name);

                    attachment := read_attachment(skeleton, attachment_name, attachment_node, skin, slot.index, scale);
                    if !attachment {
                        log("Error while loading attachment!");
                        return false;
                    }
                    
                    attachment.name = get_string_reference(attachment_name, *shared_strings);
        
                    if has(attachment_node, "name") {
                        name_override_node := get(attachment_node, "name", .STRING);
                        attachment.name = get_string_reference(name_override_node.str, *shared_strings);
                    }

                    array_add(*slot.attachments, attachment);
                }
        	}
        }
        
        return true;
    }
    
    read_attachment :: (using skeleton: *Skeleton_Data, attachment_name: string, attachment_node: JSON_Value, skin: *Skin, slot_index: Slot_Index, scale: float64) -> *Attachment #must {
    	attachment_type_name := get_string(attachment_node, "type", "region");
    	
        success: bool;
        
        if attachment_type_name == {
            case "region";
                region := New(Attachment_Region);
                region.path     = get_string_reference(attachment_node, "path", *shared_strings);
                region.x        = get_number(attachment_node, "x", 0) * scale;
                region.y        = get_number(attachment_node, "y", 0) * scale;
                region.scale_x  = get_number(attachment_node, "scaleX", 1);
                region.scale_y  = get_number(attachment_node, "scaleY", 1);
                region.rotation = get_number(attachment_node, "rotation", 0);
                region.width    = get_number(attachment_node, "width") * scale;
                region.height   = get_number(attachment_node, "height") * scale;
                
                success, region.color = get_color(attachment_node, "color", 0xffffffff);
                if !success {
                	return null;
                }
                
                return region;
                
            case "boundingbox";
                bounding_box := New(Attachment_Bounding_Box);
                success, bounding_box.vertices = read_vertices(attachment_node, scale);
                if !success then return null;
                
                success, bounding_box.color = get_color(attachment_node, "color", 0xffffffff);
                if !success {
                	return null;
                }
                
                return bounding_box;

            case "mesh";
                mesh := New(Attachment_Mesh);
                mesh.path = get_string_reference(attachment_node, "path", *shared_strings);
                
                success, mesh.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                success = get_number_array(attachment_node, "uvs", *mesh.region_uvs, 1);
                if !success then return null;
                
                mesh.vertex_count = xx mesh.region_uvs.count;
                
                success = get_number_array(attachment_node, "triangles", *mesh.triangles);
                if !success then return null;
                
                success, mesh.vertices = read_vertices(attachment_node, mesh.vertex_count, scale);
                if !success then return null;
                
                mesh.hull_length = get_number(attachment_node, "hull", 0).(s32);  // @todo Check range
                
                success = get_number_array(attachment_node, "edges", *mesh.edges);
                if !success then return null;
                
                mesh.width    = get_number(attachment_node, "width", 0) * scale;
                mesh.height   = get_number(attachment_node, "height", 0) * scale;
                
                return mesh;

            case "linkedmesh";
                mesh := New(Attachment_Linked_Mesh);
                mesh.path = get_string_reference(attachment_node, "path", *shared_strings);
                
                success, mesh.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                mesh.skin_name = get_string_reference(attachment_node, "skin", *shared_strings);
                mesh.parent    = get_string_reference(attachment_node, "parent", *shared_strings);
                
                mesh.inherit_deform = get_bool(attachment_node, "deform", true);
                
                mesh.width  = get_number(attachment_node, "width", 0) * scale;
                mesh.height = get_number(attachment_node, "height", 0) * scale;
                
                return mesh;

            case "path";
                path := New(Attachment_Path);
                log("Path: %", path.*);
                /*
                path.closed         = read_bool(s);
                path.constant_speed = read_bool(s);
                path.vertex_count   = read_var_s32(s, true);
                path.vertices       = read_vertices(s, path.vertex_count, scale);
                read_f32_array(*path.lengths, s, path.vertex_count / 3, scale);
                path.color = ifx non_essential then read_color(s);
                */
                return path;

            case "point";
                print("@todo: Point\n");
                return null;

            case "clipping";
                clipping := New(Attachment_Clipping);
                /*
                clipping.end_slot_index = read_var_s32(s, true);
                clipping.vertices       = read_vertices(s, scale);
                clipping.color          = ifx non_essential then read_color(s);
                */
                return clipping;

            case;
                log("Unknown attachment type: %", attachment_type_name);
        }

        return null;
    }

    read_vertices :: (json_value: JSON_Value, scale: float64) -> (success: bool, result: Vertices) {
        vertex_count := get_number(json_value, "vertexCount");
        success, result := read_vertices(json_value, vertex_count.(s32) << 1, scale);
        return success, result;
    }
    
    read_vertices :: (json_value: JSON_Value, vertex_count: s32, scale: float64) -> (success: bool, result: Vertices) {
        result: Vertices;
        result.vertex_count = vertex_count;

        vertices_count := vertex_count;
        
        vertices_node := get(json_value, "vertices", .ARRAY);
        vertices := vertices_node.array;
        
        if vertices.count == vertices_count {
        	success := get_number_array(vertices_node, *result.vertices, scale);
        	return success, result;
        }
        
        array_reserve(*result.bones, vertex_count);
        
        i := 0;
        n := vertices.count;
        while i < n {
            bones_count := get_number(vertices[i]).(int);
            i += 1;
            
            bones := array_add(*result.bones);
            array_reserve(bones, bones_count);
            
            nn := i + bones_count * 4;
            while i < nn {
            	defer i += 4;
                vertex := array_add(bones);
                vertex.bone   = xx get_number(vertices[i]);
                vertex.x      = get_number(vertices[i + 1]) * scale;
                vertex.y      = get_number(vertices[i + 2]) * scale;
                vertex.weight = get_number(vertices[i + 3]);
            }
        }
        
        return true, result;
    }
	
	transform_mode_from_string :: (original_name: string) -> (success: bool, mode: Transform_Mode) {
		name := to_lower_copy(original_name);
		if name == {
            case "normal";                  return true, .NORMAL;
            case "onlytranslation";         return true, .ONLY_TRANSLATION;
            case "norotationorreflection";  return true, .NO_ROTATION_OR_REFLECTION;
            case "noscale";                 return true, .NO_SCALE;
            case "noscaleorreflection";     return true, .NO_SCALE_OR_REFLECTION;
        }
        
        return false, xx -1;
	}
	
	blend_mode_from_string :: (original_name: string) -> (success: bool, mode: Blend_Mode) {
		name := to_lower_copy(original_name);
		if name == {
        	case "normal";    return true, .NORMAL;
        	case "additive";  return true, .ADD;
        	case "multiply";  return true, .MULTIPLY;
        	case "screen";    return true, .SCREEN;
		}
		
        return false, xx -1;
	}
	
	path_position_mode_from_string :: (original_name: string) -> (success: bool, mode: Path_Position_Mode) {
		name := to_lower_copy(original_name);
		if name == {
        	case "fixed";    return true, .FIXED;
        	case "percent";  return true, .PERCENT;
        }
		
        return false, xx -1;
	}
	
	path_spacing_mode_from_string :: (original_name: string) -> (success: bool, mode: Path_Spacing_Mode) {
		name := to_lower_copy(original_name);
		if name == {
        	case "length";   return true, .LENGTH;
        	case "fixed";    return true, .FIXED;
        	case "percent";  return true, .PERCENT;
        }
		
        return false, xx -1;
	}
	
	path_rotate_mode_from_string :: (original_name: string) -> (success: bool, mode: Path_Rotate_Mode) {
		name := to_lower_copy(original_name);
		if name == {
            case "tangent";     return true, .TANGENT;
            case "chain";       return true, .CHAIN;
            case "chainscale";  return true, .CHAIN_SCALE;
        }
		
        return false, xx -1;
	}
}


#import "Hash_Table";