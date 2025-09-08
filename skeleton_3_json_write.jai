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
            
            write_array(writer, "bones", #code {
            	for bone: bones {
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
            	}
            });
            
            write_array(writer, "slots", #code {
            	for slot: slots {
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
            	}
            });
            
            // @todo: ik
            // @todo: transform
            // @todo: path
            // @todo: skins
            // @todo: events
            // @todo: animations
    	});
    	
    	stop_scope(writer);
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
		if blend == {
        	case .NORMAL;    return "normal";
        	case .ADD;       return "additive";
        	case .MULTIPLY;  return "multiply";
        	case .SCREEN;    return "screen";
		}
		
		assert(false);
		return "";
	}
}
