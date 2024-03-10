IS_LITTLE_ENDIAN :: false;  // Spine writes it's data as big endian!

read_number :: inline (s: * string, $T: Type) -> T {
    size :: size_of(T);

    assert(s.count >= size);

    result := (cast(* T) s.data).*;

    #if size > 1 && !IS_LITTLE_ENDIAN {
        result = byte_swap(result);
    }

    advance(s, size);
    return result;
}

read_u8  :: #bake_arguments read_number(T = u8);
read_u16 :: #bake_arguments read_number(T = u16);
read_u32 :: #bake_arguments read_number(T = u32);
read_u64 :: #bake_arguments read_number(T = u64);

read_s8  :: #bake_arguments read_number(T = s8);
read_s16 :: #bake_arguments read_number(T = s16);
read_s32 :: #bake_arguments read_number(T = s32);
read_s64 :: #bake_arguments read_number(T = s64);

read_bool :: (data: * string) -> bool {
    return (read_u8(data) == 1);
}

read_var_s32 :: (data: * string, optimize_positive: bool) -> s32 {
    b := read_u8(data);
    value: s32 = b & 0x7F;
    if (b & 0x80) {
        b = read_u8(data);
        value |= (b & 0x7F) << 7;
        if (b & 0x80) {
            b = read_u8(data);
            value |= (b & 0x7F) << 14;
            if (b & 0x80) {
                b = read_u8(data);
                value |= (b & 0x7F) << 21;
                if (b & 0x80) value |= (read_u8(data) & 0x7F) << 28;
            }
        }
    }

    if (!optimize_positive) value = cast(s32) (cast(u32) value >> 1) ^ cast(u32) -(value & 1);
    return value;
}

read_f32 :: (data: * string) -> float32 {
    union {
        u32_value: u32;
        f32_value: float32;
    };
    u32_value = read_u32(data);
    return f32_value;
}

read_string :: (data: * string) -> string {
    count := read_var_s32(data, true);
    if      count <= 0  return .{};
    else if count == 1  return "";

    count -= 1;

    result := to_string(data.data, count);
    advance(data, count);
    return result;
}

read_string_reference :: (data: * string, shared_strings: [] string) -> string {
    index := read_var_s32(data, true);
    return ifx index > 0 then shared_strings[index - 1] else .{};
}

read_color :: (data: * string) -> Color {
    rgba := read_u32(data);
    result: Color = ---;
    result[0] = ((rgba & 0xff000000) >> 24) / 255.0;
    result[1] = ((rgba & 0x00ff0000) >> 16) / 255.0;
    result[2] = ((rgba & 0x0000ff00) >>  8) / 255.0;
    result[3] = ((rgba & 0x000000ff) >>  0) / 255.0;
    return result;
}

read_var_s32_array :: (s: * string, array: * [..] $T) {
    count := read_var_s32(s, true);
    array_reserve(array, count);
    for 0..count-1 {
        array_add(array, read_var_s32(s, true));
    }
}

read_s16_array :: (s: * string) -> [..] s16 {
    result: [..] s16;
    count := read_var_s32(s, true);
    array_reserve(*result, count);
    for 0..count-1 {
        array_add(*result, read_s16(s));
    }
    return result;
}

read_f32_array :: (s: * string, count: s32, scale: float32 = 1) -> [..] float32 {
    result: [..] float32;
    array_reserve(*result, count);
    if scale == 1 {
        for 0..count-1 {
            array_add(*result, read_f32(s));
        }
    } else {
        for 0..count-1 {
            array_add(*result, read_f32(s) * scale);
        }
    }
    return result;
}

Spine_Version :: enum {
    Unknown :: 0;
    Version37 :: 37;
    Version38 :: 38;
    Version40 :: 40;
    Version41 :: 41;
}

load_skeleton_binary :: (using skeleton: * Skeleton_Data, data: string, scale: float32 = 1) -> bool {
    read_version_old :: (data: string) -> string {
        read_string(*data);
        return read_string(*data);
    }

    read_version_new :: (data: string) -> string {
        read_u32(*data);
        read_u32(*data);
        return read_string(*data);
    }

    detect_spine_version :: (version_string: string) -> Spine_Version {
        sub3 := slice(version_string, 0, 3);
        if sub3 == {
            case "3.7";  return .Version37;
            case "3.8";  return .Version38;
            case "4.0";  return .Version40;
            case "4.1";  return .Version41;
            case;
                if string_to_float(sub3) < 3.7 {
                    return .Version37;  // Try to parse older versions with 3.7!
                } else {
                    return .Unknown;
                }
        }
    }

    version_string := read_version_old(data);
    spine_version := detect_spine_version(version_string);

    if spine_version == .Version38 {
        return Skeleton_Binary_38.load(skeleton, data, scale, spine_version);
    }

    version_string = read_version_new(data);
    spine_version = detect_spine_version(version_string);

    if spine_version == .Version40 || spine_version == .Version41 {
        return Skeleton_Binary_41.load(skeleton, data, scale, spine_version);
    }

    log("Unsupported spine version: %\n", version_string);
    return false;
}

Skeleton_Binary_38 :: struct {
    load :: (using skeleton: * Skeleton_Data, data: string, scale: float32, spine_version: Spine_Version) -> bool {
        s := * data;

        hash    = read_string(s);
        version = read_string(s);

        x = read_f32(s);
        y = read_f32(s);
        width  = read_f32(s);
        height = read_f32(s);

        if read_bool(s) {
            fps = read_f32(s);
            image_path = read_string(s);
            audio_path = read_string(s);
        }

        print("TODO: 38\n");
        return true;
    }
}

Skeleton_Binary_41 :: struct {
    load :: (using skeleton: * Skeleton_Data, data: string, scale: float32, spine_version: Spine_Version) -> bool {
        s := * data;

        hash_low  := read_u32(s);
        hash_high := read_u32(s);
        hash = sprint("%0%", FormatInt.{ value = hash_high, base = 16 }, FormatInt.{ value = hash_low, base = 16 });

        version = read_string(s);
        if slice(version, 0, 3) == {
            case "4.0";
            case "4.1";
            case;
                log("Skeleton binary 4.1 loader does not support loading version: %!", version);
                return false;
        }

        x      = read_f32(s);
        y      = read_f32(s);
        width  = read_f32(s);
        height = read_f32(s);

        non_essential := read_bool(s);
        if non_essential {
            fps        = read_f32(s);
            image_path = read_string(s);
            audio_path = read_string(s);
        }

        // Shared strings
        shared_strings_count := read_var_s32(s, true);
        array_reserve(*shared_strings, shared_strings_count);
        for 0..shared_strings_count-1 {
            array_add(*shared_strings, read_string(s));
        }

        // Bones
        bones_count := read_var_s32(s, true);
        array_reserve(*bones, bones_count);
        for 0..bones_count-1 {
            bone := array_add(*bones);
            bone.name = read_string(s);
            if !bone.name {
                log("Bone name must not be null!");
                return false;
            }
            bone.parent         = ifx (it > 0) then read_var_s32(s, true) else -1;
            bone.rotation       = read_f32(s);
            bone.x              = read_f32(s) * scale;
            bone.y              = read_f32(s) * scale;
            bone.scale_x        = read_f32(s);
            bone.scale_y        = read_f32(s);
            bone.shear_x        = read_f32(s);
            bone.shear_y        = read_f32(s);
            bone.length         = read_f32(s);
            bone.transform_mode = xx read_var_s32(s, true);
            bone.skin_required  = read_bool(s);
            bone.color          = ifx non_essential then read_color(s);
        }

        // Slots
        slots_count := read_var_s32(s, true);
        array_reserve(*slots, slots_count);
        for 0..slots_count-1 {
            slot := array_add(*slots);
            slot.name = read_string(s);
            if !slot.name {
                log("Slot name must not be null!");
                return false;
            }
            slot.bone            = read_var_s32(s, true);
            slot.color           = read_color(s);
            slot.dark_color      = read_color(s);
            slot.attachment_name = read_string_reference(s, shared_strings);
            slot.blend_mode      = xx read_var_s32(s, true);
        }

        // Ik constraints
        ik_constraints_count := read_var_s32(s, true);
        array_reserve(*ik_constraints, ik_constraints_count);
        for 0..ik_constraints_count-1 {
            ik := array_add(*ik_constraints);
            ik.name = read_string(s);
            if !ik.name {
                log("Ik constraint name must not be null!");
                return false;
            }
            ik.order         = read_var_s32(s, true);
            ik.skin_required = read_bool(s);
            bones_count     := read_var_s32(s, true);
            array_reserve(*ik.bones, bones_count);
            for 0..bones_count-1 {
                array_add(*ik.bones, read_var_s32(s, true));
            }
            ik.target         = read_var_s32(s, true);
            ik.mix            = read_f32(s);
            ik.softness       = read_f32(s) * scale;
            ik.bend_direction = read_s8(s);
            ik.compress       = read_bool(s);
            ik.stretch        = read_bool(s);
            ik.uniform        = read_bool(s);
        }

        // Transform constraints
        transform_constraints_count := read_var_s32(s, true);
        array_reserve(*transform_constraints, transform_constraints_count);
        for 0..transform_constraints_count-1 {
            constraint := array_add(*transform_constraints);
            constraint.name = read_string(s);
            if !constraint.name {
                log("Ik constraint name must not be null!");
                return false;
            }
            constraint.order         = read_var_s32(s, true);
            constraint.skin_required = read_bool(s);
            bones_count             := read_var_s32(s, true);
            array_reserve(*constraint.bones, bones_count);
            for 0..bones_count-1 {
                array_add(*constraint.bones, read_var_s32(s, true));
            }
            constraint.target          = read_var_s32(s, true);
            constraint.local           = read_bool(s);
            constraint.relative        = read_bool(s);
            constraint.offset_rotation = read_f32(s);
            constraint.offset_x        = read_f32(s) * scale;
            constraint.offset_y        = read_f32(s) * scale;
            constraint.offset_scale_x  = read_f32(s);
            constraint.offset_scale_y  = read_f32(s);
            constraint.offset_shear_y  = read_f32(s);
            constraint.mix_rotate      = read_f32(s);
            constraint.mix_x           = read_f32(s);
            constraint.mix_y           = read_f32(s);
            constraint.mix_scale_x     = read_f32(s);
            constraint.mix_scale_y     = read_f32(s);
            constraint.mix_shear_y     = read_f32(s);
        }

        // Path constraints
        path_constraints_count := read_var_s32(s, true);
        array_reserve(*path_constraints, path_constraints_count);
        for 0..path_constraints_count-1 {
            constraint := array_add(*path_constraints);
            constraint.name = read_string(s);
            if !constraint.name {
                log("Path constraint name must not be null!");
                return false;
            }
            constraint.order         = read_var_s32(s, true);
            constraint.skin_required = read_bool(s);
            bones_count             := read_var_s32(s, true);
            array_reserve(*constraint.bones, bones_count);
            for 0..bones_count-1 {
                array_add(*constraint.bones, read_var_s32(s, true));
            }
            constraint.target        = read_var_s32(s, true);
            constraint.position_mode = xx read_var_s32(s, true);
            constraint.spacing\_mode = xx read_var_s32(s, true);
            constraint.rotate\ _mode = xx read_var_s32(s, true);
            constraint.position      = read_f32(s);
            if constraint.position_mode == .FIXED  constraint.position *= scale;
            constraint.spacing       = read_f32(s);
            if constraint.spacing_mode == .LENGTH || constraint.spacing_mode == .FIXED  constraint.spacing *= scale;
            constraint.mix_rotate    = read_f32(s);
            constraint.mix_x         = read_f32(s);
            constraint.mix_y         = read_f32(s);
        }

        // Default skin
        default_skin = read_skin(skeleton, s, scale, non_essential, spine_version, is_default_skin = true);

        // Skins
        skins_count := read_var_s32(s, true);
        array_reserve(*skins, skins.count + skins_count);
        for 0..skins_count-1 {
            skin := read_skin(skeleton, s, scale, non_essential, spine_version, is_default_skin = false);
            if !skin {
                return false;
            }
        }

        print("TODO: 41\n");
        return true;
    }

    read_skin :: (using skeleton: * Skeleton_Data, s: * string, scale: float32, non_essential: bool, spine_version: Spine_Version, is_default_skin: bool) -> * Skin {
        skin: * Skin;
        slots_count: s32;

        if is_default_skin {
            slots_count = read_var_s32(s, true);
            if slots_count <= 0  return null;

            skin = array_add(*skins);
            skin.name = "default";
        } else {
            skin = array_add(*skins);
            skin.name = read_string_reference(s, shared_strings);
            if !skin.name {
                log("Skin name must not be null!");
                return null;
            }

            read_var_s32_array(s, *skin.bones);
            read_var_s32_array(s, *skin.ik\      _constraints);
            read_var_s32_array(s, *skin.transform_constraints);
            read_var_s32_array(s, *skin.path\    _constraints);

            slots_count = read_var_s32(s, true);
        }

        array_reserve(*skin.slots, slots_count);
        for 0..slots_count-1 {
            slot := array_add(*skin.slots);
            slot.index = read_var_s32(s, true);

            attachments_count := read_var_s32(s, true);
            array_reserve(*slot.attachments, attachments_count);
            for 0..attachments_count-1 {
                attachment_name := read_string_reference(s, shared_strings);
                if !attachment_name {
                    log("Attachment name must not be null!");
                    return null;
                }

                attachment := read_attachment(skeleton, s, skin, slot.index, attachment_name, scale, non_essential, spine_version);
                if !attachment {
                    log("ERROR!");
                    return null;
                }

                array_add(*slot.attachments, attachment);
            }
        }

        return null;
    }

    read_attachment :: (using skeleton: * Skeleton_Data, s: * string, skin: * Skin, slot_index: Slot_Index, attachment_name: string, scale: float32, non_essential: bool, spine_version: Spine_Version) -> * Attachment {
        name := read_string_reference(s, shared_strings);
        if !name  name = attachment_name;

        attachment_type := cast(Attachment_Type) read_u8(s);
        log("Attachment: %\n", attachment_type);
        if attachment_type == {
            case .REGION;
                region := New(Attachment_Region);
                region.name     = name;
                region.path     = read_string_reference(s, shared_strings);
                if !region.path  region.path = name;
                region.rotation = read_f32(s);
                region.x        = read_f32(s) * scale;
                region.y        = read_f32(s) * scale;
                region.scale_x  = read_f32(s);
                region.scale_y  = read_f32(s);
                region.width    = read_f32(s) * scale;
                region.height   = read_f32(s) * scale;
                region.color    = read_color(s);
                region.sequence = read_sequence(s, spine_version);
                print("Region: %\n", region.*);
                return region;

            case .BOUNDING_BOX;
                bounding_box := New(Attachment_Bounding_Box);
                bounding_box.name     = name;
                bounding_box.vertices = read_vertices(s, scale);
                bounding_box.color    = ifx non_essential then read_color(s);
                return bounding_box;

            case .MESH;
                mesh := New(Attachment_Mesh);
                mesh.name        = name;
                mesh.path        = read_string_reference(s, shared_strings);
                if !mesh.path  mesh.path = name;
                mesh.color       = read_color(s);
                vertex_count    := read_var_s32(s, true);
                mesh.region_uvs  = read_f32_array(s, vertex_count << 1);
                mesh.triangles   = read_s16_array(s);
                mesh.vertices    = read_vertices(s, vertex_count, scale);
                mesh.hull_length = read_var_s32(s, true) << 1;
                mesh.sequence    = read_sequence(s, spine_version);
                if non_essential {
                    mesh.edges   = read_s16_array(s);
                    mesh.width   = read_f32(s) * scale;
                    mesh.height  = read_f32(s) * scale;
                }
                print("Mesh: %\n", mesh.*);
                return mesh;

            case .LINKED_MESH;
            case .PATH;
            case .POINT;

            case .CLIPPING;
                clipping := New(Attachment_Clipping);
                clipping.name           = name;
                clipping.end_slot_index = read_var_s32(s, true);
                clipping.vertices       = read_vertices(s, scale);
                clipping.color          = ifx non_essential then read_color(s);
                return clipping;

            case;
                log("Unknown attachment type: %", attachment_type);
        }

        return null;
    }

    read_sequence :: (s: * string, version: Spine_Version) -> * Sequence {
        if (version < .Version41 || !read_bool(s))  return null;

        result := New(Sequence);
        result.regions_count = read_var_s32(s, true);
        result.start         = read_var_s32(s, true);
        result.digits        = read_var_s32(s, true);
        result.setup_index   = read_var_s32(s, true);
        return result;
    }

    read_vertices :: (s: * string, scale: float32) -> Vertices {
        vertex_count := read_var_s32(s, true);
        return read_vertices(s, vertex_count, scale);
    }

    read_vertices :: (s: * string, vertex_count: s32, scale: float32) -> Vertices {
        result: Vertices;

        vertices_count := vertex_count << 1;

        if !read_bool(s) {
            result.vertices = read_f32_array(s, vertices_count, scale);
            return result;
        }

        array_reserve(*result.vertices, vertices_count);
        array_reserve(*result.bones, vertex_count);

        for 0..vertex_count-1 {
            bones := array_add(*result.bones);

            bones_count := read_var_s32(s, true);
            array_reserve(bones, bones_count);
            for 0..bones_count-1 {
                array_add(bones, read_var_s32(s, true));
                array_add(*result.vertices, read_f32(s) * scale);
                array_add(*result.vertices, read_f32(s) * scale);
                array_add(*result.vertices, read_f32(s));
            }
        }

        return result;
    }
}

write_skeleton_binary :: (using skeleton: * Skeleton_Data) -> string {
    return "";
}


#load "skeleton.jai";
#import "String";
#import "Basic";
#import "Bit_Operations";