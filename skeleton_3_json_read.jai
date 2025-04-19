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
		
		//print("Transforms: %\n", transform_constraints);
		
		log_error("@todo");
		return skeleton;
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
}