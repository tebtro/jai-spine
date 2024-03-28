write :: (b: * String_Builder, base_skeleton: * Base_Skeleton_Data, optimize: bool) {
    using skeleton := cast(* Skeleton_Data) base_skeleton;

    write_u32(b, hash_low);
    write_u32(b, hash_high);

    write_string(b, version);

    write_f32(b, x);
    write_f32(b, y);
    write_f32(b, width);
    write_f32(b, height);

    write_bool(b, non_essential);
    if non_essential {
        write_f32(b, fps);
        write_string(b, image_path);
        write_string(b, audio_path);
    }

    // Shared strings
    if optimize {
        // TODO: Remove duplicate entries!
    }

    write_string_reference_array(b, shared_strings);

    // Bones
    write_var_s32(b, xx bones.count, true);
    for bones {
        write_string(b, it.name);
        if it_index > 0  write_var_s32(b, it.parent, true);
        write_f32(b, it.rotation);
        write_f32(b, it.x);
        write_f32(b, it.y);
        write_f32(b, it.scale_x);
        write_f32(b, it.scale_y);
        write_f32(b, it.shear_x);
        write_f32(b, it.shear_y);
        write_f32(b, it.length);
        write_var_s32(b, xx it.transform_mode, true);
        write_bool(b, it.skin_required);
        if non_essential  write_color(b, it.color);
    }

    // Slots
    write_var_s32(b, xx slots.count, true);
    for slots {
        write_string(b, it.name);
        write_var_s32(b, it.bone, true);
        write_color(b, it.color);
        write_color(b, it.dark_color);
        write_string_reference(b, shared_strings, it.attachment_name, optimize);
        write_var_s32(b, xx it.blend_mode, true);
    }

    // Ik constraints
    write_var_s32(b, xx ik_constraints.count, true);
    for ik_constraints {
        write_string(b, it.name);
        write_var_s32(b, it.order, true);
        write_bool(b, it.skin_required);
        write_var_s32(b, xx it.bones.count, true);
        for it.bones {
            write_var_s32(b, it, true);
        }
        write_var_s32(b, it.target, true);
        write_f32(b, it.mix);
        write_f32(b, it.softness);
        write_s8(b, it.bend_direction);
        write_bool(b, it.compress);
        write_bool(b, it.stretch);
        write_bool(b, it.uniform);
    }
}


#import "Basic";

#import,file "binary_write.jai";
#import,file "skeleton.jai";
#import,file "skeleton_4.jai";