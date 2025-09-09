Skeleton_3_Json_Read :: struct {
	using Skeleton_3;
	using Json_Read;

	load :: (root: JSON_Value, scale: float64, spine_version: Spine_Version) -> *Skeleton_Data {
        using skeleton := New(Skeleton_Data);
        skeleton.loader_version = spine_version;
        
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
                
                bone.parent_name = get_optional_string(bone_node, "parent");
                bone.parent = find_bone_index(skeleton, bone.parent_name);
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
                
                slot.bone_name = get_optional_string(slot_node, "bone");
                slot.bone = find_bone_index(skeleton, slot.bone_name);
                
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
                
                ik.order = xx get_number(ik_node, "order", 0);
                ik.skin_required = get_bool(ik_node, "skin", false);
                
                bones_node := get(ik_node, "bones", .ARRAY);
                array_reserve(*ik.bone_names, bones_node.array.count);
                array_reserve(*ik.bone_indices, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    
                    array_add(*ik.bone_names, bone_name);
                    array_add(*ik.bone_indices, bone_index);
                }
                
                ik.target_bone_name = get_optional_string(ik_node, "target");
                ik.target_bone_index = find_bone_index(skeleton, ik.target_bone_name);
                
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
                array_reserve(*constraint.bone_indices, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    
                    array_add(*constraint.bone_names, bone_name);
                    array_add(*constraint.bone_indices, bone_index);
                }
                
                constraint.target_bone_name = get_optional_string(constraint_node, "target");
                constraint.target_bone_index = find_bone_index(skeleton, constraint.target_bone_name);
                
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
                array_reserve(*constraint.bone_names, bones_node.array.count);
                array_reserve(*constraint.bone_indices, bones_node.array.count);
                for bone_node: bones_node.array {
                    if bone_node.type != .STRING {
                        log_error("Bone is not a string!");
                        return null;
                    }
                	
                    bone_name := create_optional(bone_node.str);
                    bone_index := find_bone_index(skeleton, bone_name);
                    
                    array_add(*constraint.bone_names, bone_name);
                    array_add(*constraint.bone_indices, bone_index);
                }
                
                constraint.target_bone_name = get_optional_string(constraint_node, "target");
                constraint.target_bone_index = find_bone_index(skeleton, constraint.target_bone_name);
                
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
			
			for skin_node: skins_node.array {
				if skin_node.type != .OBJECT {
					log_error("Skin is not an object!");
					return null;
				}
				
				skin := array_add(*skeleton.skins);
				skin.name = get_string_reference(skin_node, "name", *shared_strings);
				
				// Bones
				if has(skin_node, "bones") {
					bones_node := get(skin_node, "bones", .ARRAY);
					
					array_reserve(*skin.bone_names, bones_node.array.count);
					array_reserve(*skin.bone_indices, bones_node.array.count);
					
					for bone_node: bones_node.array {
						if bone_node.type != .STRING {
							log_error("Bone is not a string!");
							return null;
						}
						
						bone_name := create_optional(bone_node.str);
						bone_index := find_bone_index(skeleton, bone_name);
						
						array_add(*skin.bone_names, bone_name);
						array_add(*skin.bone_indices, bone_index);
					}
				}
				
				// IK constraints
				if has(skin_node, "ik") {
					ik_node := get(skin_node, "ik", .ARRAY);
					
					array_reserve(*skin.ik_constraint_names, ik_node.array.count);
					array_reserve(*skin.ik_constraint_indices, ik_node.array.count);
					
					for constraint_node: ik_node.array {
						if constraint_node.type != .STRING {
							log_error("IK constraint is not a string!");
							return null;
						}
						
						constraint_name := create_optional(constraint_node.str);
						constraint_index := find_ik_constraint_index(skeleton, constraint_name);
						
						array_add(*skin.ik_constraint_names, constraint_name);
						array_add(*skin.ik_constraint_indices, constraint_index);
					}
				}
				
				// Transform constraints
				if has(skin_node, "transform") {
					transform_node := get(skin_node, "transform", .ARRAY);
					
					array_reserve(*skin.transform_constraint_names, transform_node.array.count);
					array_reserve(*skin.transform_constraint_indices, transform_node.array.count);
					
					for constraint_node: transform_node.array {
						if constraint_node.type != .STRING {
							log_error("Transform constraint is not a string!");
							return null;
						}
						
						constraint_name := create_optional(constraint_node.str);
						constraint_index := find_transform_constraint_index(skeleton, constraint_name);
						
						array_add(*skin.transform_constraint_names, constraint_name);
						array_add(*skin.transform_constraint_indices, constraint_index);
					}
				}
				
				// Path constraints
				if has(skin_node, "path") {
					path_node := get(skin_node, "path", .ARRAY);
					
					array_reserve(*skin.path_constraint_names, path_node.array.count);
					array_reserve(*skin.path_constraint_indices, path_node.array.count);
					
					for constraint_node: path_node.array {
						if constraint_node.type != .STRING {
							log_error("Path constraint is not a string!");
							return null;
						}
						
						constraint_name := create_optional(constraint_node.str);
						constraint_index := find_path_constraint_index(skeleton, constraint_name);
						
						array_add(*skin.path_constraint_names, constraint_name);
						array_add(*skin.path_constraint_indices, constraint_index);
					}
				}
				
				// Slots
				if has(skin_node, "attachments") {
					slots_node := get(skin_node, "attachments", .OBJECT);
					
					for slot_node: slots_node.object {
						slot_name := it_index;
						
						if slot_node.type != .OBJECT {
							log_error("Slot is not an object!");
							return null;
						}
						
						slot_index := find_slot_index(skeleton, create_optional(slot_name));
						if slot_index == -1 {
							log_error("Slot not found: '%'!", slot_name);
							return null;
						}
						
						slot := array_add(*skin.slots);
						slot.name = slot_name;
						slot.index = slot_index;
						
						// Attachments
						for attachment_node: slot_node.object {
							attachment_name := it_index;
							
							if attachment_node.type != .OBJECT {
								log_error("Attachment is not an object!");
								return null;
							}
							
							attachment := read_attachment(skeleton, attachment_name, attachment_node, skin, slot.index, scale);
							if !attachment {
								return null;
							}
							
							attachment.name = .{
                                original_index = 0,
                                data = create_optional(attachment_name),
                            };
							
							array_add(*slot.attachments, attachment);
						}
					}
				}
			}
		}
		
		// Events
		if has(root, "events") {
			events_node := get(root, "events", .OBJECT);
			
			for event_node: events_node.object {
				event_name := it_index;
				
				if event_node.type != .OBJECT {
					log_error("Event is not an object!");
					return null;
				}
				
				event := array_add(*skeleton.events);
				event.name = get_string_reference(event_node, "name", *shared_strings);
				event.value_int = xx get_number(event_node, "int", 0);
				event.value_float = get_number(event_node, "float", 0);
				event.value_string = get_optional_string(event_node, "string");
				event.audio_path = get_optional_string(event_node, "audio");
				event.volume = get_number(event_node, "volume", 1);
				event.balance = get_number(event_node, "balance", 0);
			}
		}
		
		// Animations
		if has(root, "animations") {
			animations_node := get(root, "animations", .OBJECT);
			
			for animation_node: animations_node.object {
				animation_name := it_index;
				
				if animation_node.type != .OBJECT {
					log_error("Animation is not an object!");
					return null;
				}
				
				using animation := array_add(*skeleton.animations);
				animation.name = get_optional_string(animation_node, "name");
				
				// Slots
				if has(animation_node, "slots") {
					slots_node := get(animation_node, "slots", .OBJECT);
					
					for slot_node: slots_node.object {
						slot_name := it_index;
						
						if slot_node.type != .OBJECT {
							log_error("Slot animation is not an object!");
							return null;
						}
						
            			using slot_timeline := array_add(*slot_timelines);
						
						slot_index = find_slot_index(skeleton, create_optional(slot_name));
						if slot_index == -1 {
							log_error("Slot not found: '%'!", slot_name);
							return null;
						}
						
                        create_timeline :: ($T: Type) -> *T #expand {
                            timeline := New(T);
                            //timeline.frame_count = frame_count;
                            array_add(*timelines, timeline);
                            return timeline;
                        }
						
						// Attachment
						if has(slot_node, "attachment") {
							attachment_node := get(slot_node, "attachment", .ARRAY);
							
                        	timeline := create_timeline(Slot_Timeline.Attachment_Timeline);
							
							for frame_node: attachment_node.array {
								if frame_node.type != .OBJECT {
									log_error("Attachment frame is not an object!");
									return null;
								}
								
								frame := array_add(*timeline.frames);
								frame.time = get_number(frame_node, "time", 0);
								frame.name = get_string_reference(frame_node, "name", *shared_strings);
							}
						}
						
						// Color
						if has(slot_node, "color") {
							color_node := get(slot_node, "color", .ARRAY);
							
                        	timeline := create_timeline(Slot_Timeline.Color_Timeline);
                        	
                            success = read_curve_timeline(timeline, color_node, 1, #code {
								success, frame.color = get_color(frame_node, "color", 0xffffffff);
								if !success then return null;
                            }, #code {});
                            if !success then return null;
						}
						
						// Two color
						if has(slot_node, "twoColor") {
							two_color_node := get(slot_node, "twoColor", .ARRAY);
							
                        	timeline := create_timeline(Slot_Timeline.Two_Color_Timeline);
                        	
                            success = read_curve_timeline(timeline, two_color_node, 1, #code {
								success, frame.light = get_color(frame_node, "light", 0xffffffff);
								if !success then return null;
								
								success, frame.dark = get_color(frame_node, "dark", 0xffffffff);
								if !success then return null;
                            }, #code {});
                            if !success then return null;
						}
					}
				}
				
				// Bones
				if has(animation_node, "bones") {
					bones_node := get(animation_node, "bones", .OBJECT);
					
					for bone_node: bones_node.object {
						bone_name := it_index;
						
						if bone_node.type != .OBJECT {
							log_error("Bone animation is not an object!");
							return null;
						}
						
            			using bone_timeline := array_add(*bone_timelines);
						
						bone_index = find_bone_index(skeleton, create_optional(bone_name));
						if bone_index == -1 {
							log_error("Bone not found: '%'!", bone_name);
							return null;
						}
						
                        create_timeline :: ($T: Type) -> *T #expand {
                            timeline := New(T);
                            array_add(*timelines, timeline);
                            return timeline;
                        }
						
						// Rotate
						if has(bone_node, "rotate") {
							rotate_node := get(bone_node, "rotate", .ARRAY);
							
                        	timeline := create_timeline(Bone_Timeline.Rotate_Timeline);
                        	
                            success := read_curve_timeline(timeline, rotate_node, 1, #code {
								frame.angle = get_number(frame_node, "angle", 0);
                            }, #code {});
                            if !success  return null;
						}
						
						// Translate
						if has(bone_node, "translate") {
							translate_node := get(bone_node, "translate", .ARRAY);
							
                        	timeline := create_timeline(Bone_Timeline.Translate_Timeline);
                        	
                            success := read_curve_timeline(timeline, translate_node, 1, #code {
								frame.x = get_number(frame_node, "x", 0) * scale;
								frame.y = get_number(frame_node, "y", 0) * scale;
                            }, #code {});
                            if !success  return null;
						}
						
						// Scale
						if has(bone_node, "scale") {
							scale_node := get(bone_node, "scale", .ARRAY);
							
                        	timeline := create_timeline(Bone_Timeline.Scale_Timeline);
                        	
                            success := read_curve_timeline(timeline, scale_node, 1, #code {
								frame.scale_x = get_number(frame_node, "x", 1);
								frame.scale_y = get_number(frame_node, "y", 1);
                            }, #code {});
                            if !success  return null;
						}
						
						// Shear
						if has(bone_node, "shear") {
							shear_node := get(bone_node, "shear", .ARRAY);
							
                        	timeline := create_timeline(Bone_Timeline.Shear_Timeline);
                        	
                            success := read_curve_timeline(timeline, shear_node, 1, #code {
								frame.shear_x = get_number(frame_node, "x", 0);
								frame.shear_y = get_number(frame_node, "y", 0);
                            }, #code {});
                            if !success  return null;
						}
					}
				}
				
				// IK
				if has(animation_node, "ik") {
					ik_node := get(animation_node, "ik", .OBJECT);
					
					for constraint_node: ik_node.object {
						constraint_name := it_index;
						
						if constraint_node.type != .ARRAY {
							log_error("IK constraint animation is not an array! (%)", constraint_node.type);
							return null;
						}
						
            			using timeline := array_add(*ik_timelines);
						ik_constraint_index = find_ik_constraint_index(skeleton, create_optional(constraint_name));
						if ik_constraint_index == -1 {
							log_error("IK constraint not found: '%'!", constraint_name);
							return null;
						}
						
                        success := read_curve_timeline(timeline, constraint_node, scale, #code {
							frame.mix            = get_number(frame_node, "mix", 1);
							frame.softness       = get_number(frame_node, "softness", 0) * scale;
							frame.bend_direction = xx ifx get_bool(frame_node, "bendPositive", true) then 1 else -1;
							frame.compress       = get_bool(frame_node, "compress", false);
							frame.stretch        = get_bool(frame_node, "stretch", false);
                        }, #code {});
                        if !success  return null;
					}
				}
				
				// Transform
				if has(animation_node, "transform") {
					transform_node := get(animation_node, "transform", .OBJECT);
					
					for constraint_node: transform_node.object {
						constraint_name := it_index;
						
						if constraint_node.type != .ARRAY {
							log_error("Transform constraint animation is not an array!");
							return null;
						}
							
            			using timeline := array_add(*transform_timelines);
						
						transform_constraint_index = find_transform_constraint_index(skeleton, create_optional(constraint_name));
						if transform_constraint_index == -1 {
							log_error("Transform constraint not found: '%'!", constraint_name);
							return null;
						}
						
                        success := read_curve_timeline(timeline, constraint_node, scale, #code {
							frame.rotate_mix    = get_number(frame_node, "rotateMix", 1);
							frame.translate_mix = get_number(frame_node, "translateMix", 1);
							frame.scale_mix     = get_number(frame_node, "scaleMix", 1);
							frame.shear_mix     = get_number(frame_node, "shearMix", 1);
                        }, #code {});
                        if !success  return null;
					}
				}
				
				// Path
				if has(animation_node, "path") {
					path_node := get(animation_node, "path", .OBJECT);
					
					for constraint_node: path_node.object {
						constraint_name := it_index;
						
						if constraint_node.type != .OBJECT {
							log_error("Path constraint animation is not an object!");
							return null;
						}
						
                        using path_timeline := array_add(*path_timelines);
						
                        path_constraint_index = find_path_constraint_index(skeleton, create_optional(constraint_name));
                        if path_constraint_index == -1 {
                            log_error("Path constraint not found: '%'!", constraint_name);
                            return null;
                        }
                        
                        path_constraint := skeleton.path_constraints[path_constraint_index];
						
						for path_timeline_node: constraint_node.object {
							path_timeline_name := it_index;
							
                            if path_timeline_node.type != .ARRAY {
                                log_error("Path timeline node is not an array!");
                                return null;
                            }
                            
                            create_timeline :: ($T: Type) -> *T #expand {
                                timeline := New(T);
                                //timeline.frame_count = frame_count;
                                array_add(*timelines, timeline);
                                return timeline;
                            }
                            
                            timeline_scale: float64 = 1;
							
							if path_timeline_name == "position" {
                        		timeline := create_timeline(Path_Timeline.Position_Timeline);
                        		
                        		if path_constraint.position_mode == .FIXED {
                        			timeline_scale = scale;
                        		}
								
                                success := read_curve_timeline(timeline, path_timeline_node, scale, #code {
                                    frame.position = get_number(frame_node, "position", 0) * timeline_scale;
                                }, #code {});
                                if !success  return null;
							}
							else if path_timeline_name == "spacing" {
                        		timeline := create_timeline(Path_Timeline.Spacing_Timeline);
                        		
                        		if path_constraint.spacing_mode == .LENGTH || path_constraint.spacing_mode == .FIXED {
                        			timeline_scale = scale;
                        		}
								
                                success := read_curve_timeline(timeline, path_timeline_node, scale, #code {
                                    frame.spacing = get_number(frame_node, "spacing", 0) * timeline_scale;
                                }, #code {});
                                if !success  return null;
							}
							else if path_timeline_name == "mix" {
                        		timeline := create_timeline(Path_Timeline.Mix_Timeline);
								
                                success := read_curve_timeline(timeline, path_timeline_node, scale, #code {
                                    frame.rotate\  _mix = get_number(frame_node, "rotate_mix",    1);
                                    frame.translate_mix = get_number(frame_node, "translate_mix", 1);
                                }, #code {});
                                if !success  return null;
							}
							else {
								log_error("Unknown path timeline type: %", path_timeline_name);
								return null;
							}
						}
					}
				}
				
				// Deform timeline
				if has(animation_node, "deform") {
					deform_node := get(animation_node, "deform", .OBJECT);
					
					for deform_skin_node: deform_node.object {
						deform_skin_name := it_index;
						
						using deform_timeline := array_add(*deform_timelines);
						
						skin_index = find_skin_index(skeleton, deform_skin_name);
						if skin_index < 0 {
							log_error("Could not find deform skin: %", deform_skin_name);
							return null;
						}
						
						if deform_skin_node.type != .OBJECT {
							log_error("Deform skin is not an object!");
							return null;
						}
						
						for slot_node: deform_skin_node.object {
							slot_name := it_index;
							
                            if slot_node.type != .OBJECT {
                                log_error("Deform skin slot is not an object!");
                                return null;
                            }
                            
                            using slot_timeline := array_add(*slot_timelines);
                            
                            slot_index = find_slot_index(skeleton, slot_name);
                            if slot_index < 0 {
                                log_error("Could not find deform skin slot: %", slot_name);
                                return null;
                            }
                            
                            for attachment_node: slot_node.object {
                            	attachment_name := it_index;
                            	
                            	attachment_timeline := array_add(*attachment_timelines);
                            	attachment_timeline.attachment_name = get_string_reference(attachment_name, *shared_strings);
                            	
                                if attachment_node.type != .ARRAY {
                                    log_error("Deform skin slot attachment is not an array!");
                                    return null;
                                }
                                
                                success := read_curve_timeline(attachment_timeline, attachment_node, scale, #code {
                                	frame.offset = xx get_number(frame_node, "offset", 0);
                                	
                                	if has(frame_node, "vertices") {
                                        success := get_number_array(frame_node, "vertices", *frame.vertices, scale);
                                        if !success then return null;
                                	}
                                }, #code {});
                                if !success  return null;
                            }
						}
					}
				}
				
				// Draw order
				if has(animation_node, "drawOrder") {
					draw_order_node := get(animation_node, "drawOrder", .ARRAY);
					
					for frame_node: draw_order_node.array {
						if frame_node.type != .OBJECT {
							log_error("Draw order frame is not an object!");
							return null;
						}
						
						frame := array_add(*animation.draw_order_timeline.frames);
						frame.time = get_number(frame_node, "time", 0);
						
						if has(frame_node, "offsets") {
                            offsets_node := get(frame_node, "offsets", .ARRAY);
                            array_reserve(*frame.offsets, offsets_node.array.count);
						
                            for offset_node: offsets_node.array {
                                if offset_node.type != .OBJECT {
                                    log_error("Draw order offset is not an object!");
                                    return null;
                                }
							
                                slot_name := get_optional_string(offset_node, "slot");
							
                                offset := array_add(*frame.offsets);
                                offset.slot_index = find_slot_index(skeleton, slot_name);
                                offset.offset = xx get_number(offset_node, "offset", 0);
                            }
						}
					}
				}
				
				// Events
				if has(animation_node, "events") {
					events_node := get(animation_node, "events", .ARRAY);
					
					for frame_node: events_node.array {
						if frame_node.type != .OBJECT {
							log_error("Event frame is not an object!");
							return null;
						}
						
						frame := array_add(*animation.events);
						frame.time = get_number(frame_node, "time", 0);
						
						event_name := get_optional_string(frame_node, "name");
						frame.event_index = find_event_index(skeleton, event_name);
						
						frame.value_int = xx get_number(frame_node, "int", 0);
						frame.value_float = get_number(frame_node, "float", 0);
						frame.value_string = get_optional_string(frame_node, "string");
						frame.volume = get_number(frame_node, "volume", 1);
						frame.balance = get_number(frame_node, "balance", 0);
					}
				}
			}
		}
		
		return skeleton;
	}
	
	read_attachment :: (using skeleton: *Skeleton_Data, attachment_name: string, attachment_node: JSON_Value, skin: *Skin, slot_index: Slot_Index, scale: float64) -> *Attachment {
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
                region.width    = get_number(attachment_node, "width", 0) * scale;
                region.height   = get_number(attachment_node, "height", 0) * scale;
                
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
                
                mesh.hull_length = xx get_number(attachment_node, "hull", 0);
                
                success = get_number_array(attachment_node, "edges", *mesh.edges);
                if !success then return null;
                
                mesh.width  = get_number(attachment_node, "width", 0) * scale;
                mesh.height = get_number(attachment_node, "height", 0) * scale;
                
                return mesh;

            case "linkedmesh";
                mesh := New(Attachment_Linked_Mesh);
                mesh.path = get_string_reference(attachment_node, "path", *shared_strings);
                
                success, mesh.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                mesh.skin_name = get_string_reference(attachment_node, "skin", *shared_strings);
                mesh.parent = get_string_reference(attachment_node, "parent", *shared_strings);
                mesh.inherit_deform = get_bool(attachment_node, "deform", true);
                
                mesh.width  = get_number(attachment_node, "width", 0) * scale;
                mesh.height = get_number(attachment_node, "height", 0) * scale;
                
                return mesh;

            case "path";
                path := New(Attachment_Path);
                path.closed = get_bool(attachment_node, "closed", false);
                path.constant_speed = get_bool(attachment_node, "constantSpeed", true);
                path.vertex_count = xx get_number(attachment_node, "vertexCount", 0);
                
                success, path.vertices = read_vertices(attachment_node, path.vertex_count, scale);
                if !success then return null;
                
                success = get_number_array(attachment_node, "lengths", *path.lengths, scale);
                if !success then return null;
                
                success, path.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                return path;

            case "point";
                point := New(Attachment_Point);
                point.x = get_number(attachment_node, "x", 0) * scale;
                point.y = get_number(attachment_node, "y", 0) * scale;
                point.rotation = get_number(attachment_node, "rotation", 0);
                
                success, point.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                return point;

            case "clipping";
                clipping := New(Attachment_Clipping);
                clipping.end_slot_index = find_slot_index(skeleton, get_optional_string(attachment_node, "end"));
                
                success, clipping.vertices = read_vertices(attachment_node, scale);
                if !success then return null;
                
                success, clipping.color = get_color(attachment_node, "color", 0xffffffff);
                if !success then return null;
                
                return clipping;

            case;
                log_error("Unknown attachment type: '%'!", attachment_type_name);
                return null;
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

    read_curve_timeline :: (using timeline: *Curve_Timeline($Frame), json_array: JSON_Value, scale: float64, code_before_bezier: Code, code_after_bezier: Code) -> bool #expand {
    	if json_array.type != .ARRAY {
    		return false;
    	}
    	
    	success := true;
    	
    	frame_count := json_array.array.count;
    	
        array_reserve(*frames, frame_count);
        
        for `frame_node: json_array.array {
            if frame_node.type != .OBJECT {
                log_error("Frame is not an object!");
                return false;
            }
        
            `frame := array_add(*frames);
            
			frame.time = get_number(frame_node, "time", 0);

            #insert code_before_bezier;

            if it_index > 0 {
            	if has(frame_node, "curve") {
                    curve_node := get(frame_node, "curve");
                    if curve_node.type == .NUMBER {
                        frame.type = .BEZIER;
                    } else {
                        success, frame.type = curve_type_from_string(get_string(frame_node, "curve", "linear"));
                        if !success then return false;
                    }
            	} else {
            		frame.type = .LINEAR;
            	}

                if #complete frame.type == {
                    case .LINEAR;
                    case .STEPPED;
                    case .BEZIER;
                        for * frame.beziers {
                            it.cx1 = get_number(frame_node, "curve");
                            it.cy1 = get_number(frame_node, "c2", 0);
                            it.cx2 = get_number(frame_node, "c3", 1);
                            it.cy2 = get_number(frame_node, "c4", 1);
                        }

                    case;
                        assert(false, "Unknown curve type: %\n", frame.type);
                        return false;
                }
            }

            #insert code_after_bezier;
        }

        return success;
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
	
	curve_type_from_string :: (original_name: string) -> (success: bool, mode: Curve_Type) {
		name := to_lower_copy(original_name);
		if name == {
            case "linear";   return true, .LINEAR;
            case "stepped";  return true, .STEPPED;
            case "bezier";   return true, .BEZIER;
        }
		
        return false, xx 255;
	}
}


#import "Hash_Table";