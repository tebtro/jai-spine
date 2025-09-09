Skeleton_3_Json_Write :: struct {
	#as using base_json_write: Json_Write;

	Writer :: Skeleton_3_Json_Write;

	using Skeleton_3;
	
    write :: (builder: *String_Builder, base_skeleton: *Base_Skeleton_Data, optimize: bool) {
        using skeleton := base_skeleton.(*Skeleton_Data);
        
        writer: Skeleton_3_Json_Write;
        writer.builder = builder;
        writer.optimize = optimize;
        write(*writer, skeleton);
    }
	
    write :: (using writer: *Writer, using skeleton: *Skeleton_Data) {
    	write_object(writer, "", #code {
            write_object(writer, "skeleton", #code {
                write(writer, "hash", hash);
                write(writer, "spine", version);
                
                write(writer, "x", x, 0);
                write(writer, "y", y, 0);
                write(writer, "width", width, 0);
                write(writer, "height", height, 0);
                write(writer, "fps", fps, 0);
                write(writer, "images", images_path);
                write(writer, "audio", audio_path);
            });
            
            if bones.count
            write_array(writer, "bones", #code {
            	for bone: bones
                write_object(writer, #code {
                    write(writer, "name", bone.name);
                    write(writer, "parent", bone.parent_name);
                    write(writer, "length", bone.length, 0);
                    write(writer, "x", bone.x, 0);
                    write(writer, "y", bone.y, 0);
                    write(writer, "rotation", bone.rotation, 0);
                    write(writer, "scaleX", bone.scale_x, 1);
                    write(writer, "scaleY", bone.scale_y, 1);
                    write(writer, "shearX", bone.shear_x, 0);
                    write(writer, "shearY", bone.shear_y, 0);
                    if bone.transform_mode != .NORMAL {
                        write(writer, "transform", to_string(bone.transform_mode));
                    }
                    write(writer, "skin", bone.skin_required, false);
                    write_color(writer, "color", bone.color, 0xffffffff);
                });
            });
            
            if slots.count
            write_array(writer, "slots", #code {
            	for slot: slots
                write_object(writer, #code {
                    write(writer, "name", slot.name);
                    write(writer, "bone", slot.bone_name);
                    write_color(writer, "color", slot.color, 0xffffffff);
                    write_color(writer, "dark", slot.dark_color, 0xffffffff);
                    write(writer, "attachment", slot.attachment_name);
                    if slot.blend_mode != .NORMAL {
                        write(writer, "blend", to_string(slot.blend_mode));
                    }
                });
            });
            
            if ik_constraints.count
            write_array(writer, "ik", #code {
            	for ik: ik_constraints
                write_object(writer, #code {
                    write(writer, "name", ik.name);
                    write(writer, "order", ik.order, 0);
                    write(writer, "skin", ik.skin_required, false);
            			
                    if ik.bone_names.count
                    write_array(writer, "bones", #code {
                        for bone_name: ik.bone_names {
                            write(writer, bone_name);
                        }
                    });
            			
                    write(writer, "target", ik.target_bone_name);
            			
                    write(writer, "mix", ik.mix, 1);
                    write(writer, "softness", ik.softness, 0);
                    write(writer, "bendPositive", ik.bend_direction > 0, true);
                    write(writer, "compress", ik.compress, false);
                    write(writer, "stretch", ik.stretch, false);
                    write(writer, "uniform", ik.uniform, false);
                });
            });
            
            if transform_constraints.count
            write_array(writer, "transform", #code {
            	for constraint: transform_constraints
                write_object(writer, #code {
                    write(writer, "name", constraint.name);
            			
                    write(writer, "order", constraint.order, 0);
                    write(writer, "skin", constraint.skin_required, false);
            		
                    write_array(writer, "bones", #code {
                        for bone_name: constraint.bone_names {
                            write(writer, bone_name);
                        }
                    });
            			
                    write(writer, "target", constraint.target_bone_name);
            			
                    write(writer, "local", constraint.local, false);
                    write(writer, "relative", constraint.relative, false);
                    write(writer, "rotation", constraint.offset_rotation, 0);
                    write(writer, "x", constraint.offset_x, 0);
                    write(writer, "y", constraint.offset_y, 0);
                    write(writer, "scaleX", constraint.offset_scale_x, 0);
                    write(writer, "scaleY", constraint.offset_scale_y, 0);
                    write(writer, "shearY", constraint.offset_shear_y, 0);
                    write(writer, "rotateMix", constraint.rotate_mix, 1);
                    write(writer, "translateMix", constraint.translate_mix, 1);
                    write(writer, "scaleMix", constraint.scale_mix, 1);
                    write(writer, "shearMix", constraint.shear_mix, 1);
                });
            });
            
            if path_constraints.count
            write_array(writer, "path", #code {
            	for constraint: path_constraints
                write_object(writer, #code {
	            	write(writer, "name", constraint.name);
	            	
	            	write(writer, "order", constraint.order, 0);
	            	write(writer, "skin", constraint.skin_required, false);
	            	
	            	write_array(writer, "bones", #code {
	            		for bone_name: constraint.bone_names {
	            			write(writer, bone_name);
	            		}
	            	});
	            	
	            	write(writer, "target", constraint.target_bone_name);
	            	
	            	if constraint.position_mode != .PERCENT
	            	write(writer, "positionMode", to_string(constraint.position_mode));
	            	
	            	if constraint.spacing_mode != .LENGTH
	            	write(writer, "spacingMode", to_string(constraint.spacing_mode));
	            	
	            	if constraint.rotate_mode != .TANGENT
	            	write(writer, "rotateMode", to_string(constraint.rotate_mode));
	            	
	            	write(writer, "rotation", constraint.offset_rotation, 0);
	            	write(writer, "position", constraint.position, 0);
	            	write(writer, "spacing", constraint.spacing, 0);
	            	write(writer, "rotateMix", constraint.rotate_mix, 1);
	            	write(writer, "translateMix", constraint.translate_mix, 1);
                });
            });
            
            if skins.count
            write_array(writer, "skins", #code {
            	for skin: skins
            	write_object(writer, #code {
            		write(writer, "name", skin.name);
            		
            		if skin.bone_names.count
            		write_array(writer, "bones", #code {
            			for bone_name: skin.bone_names {
            				write(writer, bone_name);
            			}
            		});
            		
            		if skin.ik_constraint_names.count
            		write_array(writer, "ik", #code {
            			for constraint_name: skin.ik_constraint_names {
            				write(writer, constraint_name);
            			}
            		});
            		
            		if skin.transform_constraint_names.count
            		write_array(writer, "transform", #code {
            			for constraint_name: skin.transform_constraint_names {
            				write(writer, constraint_name);
            			}
            		});
            		
            		if skin.path_constraint_names
            		write_array(writer, "path", #code {
            			for constraint_name: skin.path_constraint_names {
            				write(writer, constraint_name);
            			}
            		});
            		
            		if skin.slots.count
            		write_object(writer, "attachments", #code {
            			for slot: skin.slots
            			write_object(writer, slot.name, #code {
            				for attachment: slot.attachments
            				write_object(writer, attachment.name, #code {
            					write_attachment(writer, skeleton, attachment);
            				});
            			});
            		});
            	});
            });
            
            // @todo: events
            // @todo: animations
    	});
    	
    	stop_scope(writer);
    }
    
    write_attachment :: (using writer: *Writer, skeleton: *Skeleton_Data, attachment: *Attachment) {
    	write(writer, "type", to_string(attachment.type));
    
    	if #complete attachment.type == {
    		case .REGION;
    			region := attachment.(*Attachment_Region);
    			write(writer, "path", region.path);
    			write(writer, "x", region.x, 0);
    			write(writer, "y", region.y, 0);
    			write(writer, "scaleX", region.scale_x, 1);
    			write(writer, "scaleY", region.scale_y, 1);
    			write(writer, "rotation", region.rotation, 0);
    			write(writer, "width", region.width, 0);
    			write(writer, "height", region.height, 0);
    			write(writer, "color", region.color, 0xffffffff);
    			
    		case .BOUNDING_BOX;
    			bounding_box := attachment.(*Attachment_Bounding_Box);
    			write_vertices(writer, bounding_box.vertices, true);
    			write(writer, "color", bounding_box.color, 0xffffffff);
    			
    		case .MESH;
    			mesh := attachment.(*Attachment_Mesh);
    			
    		case .LINKED_MESH;
    			mesh := attachment.(*Attachment_Linked_Mesh);
    			
    		case .PATH;
    			path := attachment.(*Attachment_Path);
    			
    		case .POINT;
    			point := attachment.(*Attachment_Point);
    			
    		case .CLIPPING;
    			clipping := attachment.(*Attachment_Clipping);
    	}
    }
    
    write_vertices :: (using writer: *Writer, vertices: Vertices, write_vertex_count: bool) {
    	if write_vertex_count {
    		write(writer, "vertexCount", vertices.vertex_count >> 1);
    	}
    	
    	if vertices.bones.count {
    		assert(false, "TODO");
    	} else {
    		write_array(writer, "vertices", #code {
    			for vertex: vertices.vertices
    			write(writer, vertex);
    		});
    	}
    }
	
	to_string :: (transform: Transform_Mode) -> string {
		if #complete transform == {
            case .NORMAL;  return "normal";
            case .ONLY_TRANSLATION;  return "onlytranslation";
            case .NO_ROTATION_OR_REFLECTION;  return "norotationorreflection";
            case .NO_SCALE;  return "noscale";
            case .NO_SCALE_OR_REFLECTION;  return "noscaleorreflection";
        }
        
        assert(false);
        return "";
	}
	
	to_string :: (blend: Blend_Mode) -> string {
		if #complete blend == {
        	case .NORMAL;    return "normal";
        	case .ADD;       return "additive";
        	case .MULTIPLY;  return "multiply";
        	case .SCREEN;    return "screen";
		}
		
		assert(false);
		return "";
	}
	
	to_string :: (position: Path_Position_Mode) -> string {
		if #complete position == {
        	case .FIXED;  return "fixed";
        	case .PERCENT;  return "percent";
        }
        
		assert(false);
		return "";
	}
	
	to_string :: (spacing: Path_Spacing_Mode) -> string {
		if #complete spacing == {
        	case .LENGTH;  return "length";
        	case .FIXED;  return "fixed";
        	case .PERCENT;  return "percent";
        }
        
		assert(false);
		return "";
	}
	
	to_string :: (rotate: Path_Rotate_Mode) -> string {
		if #complete rotate == {
            case .TANGENT;  return "tangent";
            case .CHAIN;  return "chain";
            case .CHAIN_SCALE;  return "chainscale";
        }
        
		assert(false);
		return "";
	}
	
	to_string :: (attachment: Attachment_Type) -> string {
		if #complete attachment == {
            case .REGION;  return "region";
            case .BOUNDING_BOX;  return "boundingbox";
            case .MESH;  return "mesh";
            case .LINKED_MESH;  return "linkedmesh";
            case .PATH;  return "path";
            case .POINT;  return "point";
            case .CLIPPING;  return "clipping";
		}
	
		assert(false);
		return "";
	}
}
