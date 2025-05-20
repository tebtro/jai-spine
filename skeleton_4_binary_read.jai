Skeleton_4_Binary_Read :: struct {
	using Skeleton_4;
	using Binary_Read;

    load :: (data: string, scale: float64, lv: Spine_Version) -> *Skeleton_Data {
        s := *data;

        using skeleton := New(Skeleton_Data);
        loader_version = lv;

        hash_low  = read_u32(s);
        hash_high = read_u32(s);

        version = read_string(s);
        if slice(version.value, 0, 3) == {
            case "4.0";
            case "4.1";
            case;
                log("Skeleton binary 4.1 loader does not support loading version: %!", version);
                return null;
        }

        x      = read_f32(s);
        y      = read_f32(s);
        width  = read_f32(s);
        height = read_f32(s);

        non_essential = read_bool(s);
        if non_essential {
            fps        = read_f32(s);
            image_path = read_string(s);
            audio_path = read_string(s);
        }

        // Shared strings
        read_string_reference_array(s, *shared_strings);

        // Bones
        bones_count := read_var_s32(s, true);
        array_reserve(*bones, bones_count);
        for 0..bones_count-1 {
            bone := array_add(*bones);
            bone.name = read_string(s);
            if !bone.name.has_value || !bone.name.value {
                log("Bone name must not be null!");
                return null;
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
            if !slot.name.has_value || !slot.name.value {
                log("Slot name must not be null!");
                return null;
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
            if !ik.name.has_value || !ik.name.value {
                log("Ik constraint name must not be null!");
                return null;
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
            if !constraint.name.has_value || !constraint.name.value {
                log("Ik constraint name must not be null!");
                return null;
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
            if !constraint.name.has_value || !constraint.name.value {
                log("Path constraint name must not be null!");
                return null;
            }
            constraint.order         = read_var_s32(s, true);
            constraint.skin_required = read_bool(s);
            bones_count             := read_var_s32(s, true);
            array_reserve(*constraint.bones, bones_count);
            for 0..bones_count-1 {
                array_add(*constraint.bones, read_var_s32(s, true));
            }
            constraint.target          = read_var_s32(s, true);
            constraint.position_mode   = xx read_var_s32(s, true);
            constraint.spacing\_mode   = xx read_var_s32(s, true);
            constraint.rotate\ _mode   = xx read_var_s32(s, true);
            constraint.offset_rotation = read_f32(s);
            constraint.position        = read_f32(s);
            constraint.spacing         = read_f32(s);
            constraint.mix_rotate      = read_f32(s);
            constraint.mix_x           = read_f32(s);
            constraint.mix_y           = read_f32(s);
        }

        // Default skin
        success := read_skin(skeleton, *default_skin, s, scale, is_default_skin = true);
        if !success {
            log("Error while loading default skin!");
            return null;
        }

        // Skins
        skins_count := read_var_s32(s, true);
        array_reserve(*skins, skins_count);
        for 0..skins_count-1 {
            skin := array_add(*skins);
            success := read_skin(skeleton, skin, s, scale, is_default_skin = false);
            if !success {
                log("Error while loading skin!");
                return null;
            }
        }

        // Events
        events_count := read_var_s32(s, true);
        array_reserve(*events, events_count);
        for 0..events_count-1 {
            event := array_add(*events);
            event.name = read_string_reference(s, shared_strings);
            if !event.name.data.has_value || !event.name.data.value {
                log("Event name must not be null!");
                return null;
            }
            event.value_int    = read_var_s32(s, false);
            event.value_float  = read_f32(s);
            event.value_string = read_string(s);
            event.audio_path   = read_string(s);
            if event.audio_path.has_value && event.audio_path.value {
                event.volume  = read_f32(s);
                event.balance = read_f32(s);
            }
        }

        // Animations
        animations_count := read_var_s32(s, true);
        array_reserve(*animations, animations_count);
        for 0..animations_count-1 {
            animation := array_add(*animations);
            animation.name = read_string(s);
            if !animation.name.has_value || !animation.name.value {
                log("Animation name must not be null!");
                return null;
            }

            //log("Animation name: %", animation.name);

            success := read_animation(skeleton, animation, s, scale);
            if !success {
                log("Error while loading animation!");
                return null;
            }
        }

        return skeleton;
    }

    read_skin :: (using skeleton: *Skeleton_Data, skin: *Skin, s: *string, scale: float64, is_default_skin: bool) -> bool {
        slots_count: s32;

        if is_default_skin {
            slots_count = read_var_s32(s, true);
            if slots_count <= 0 {
                return false;
            }

            skin.name = .{ data = create_optional("default") };
        } else {
            skin.name = read_string_reference(s, shared_strings);
            if !skin.name.data.has_value || !skin.name.data.value {
                log("Skin name must not be null!");
                return false;
            }

            read_var_s32_array(s, *skin.bones);
            read_var_s32_array(s, *skin.ik\      _constraints);
            read_var_s32_array(s, *skin.transform_constraints);
            read_var_s32_array(s, *skin.path\    _constraints);

            slots_count = read_var_s32(s, true);
        }

        //log("Read skin: %", skin.name);

        array_reserve(*skin.slots, slots_count);
        for 0..slots_count-1 {
            slot := array_add(*skin.slots);
            slot.index = read_var_s32(s, true);

            attachments_count := read_var_s32(s, true);
            array_reserve(*slot.attachments, attachments_count);
            for 0..attachments_count-1 {
                attachment_name := read_string_reference(s, shared_strings);
                if !attachment_name.data.has_value || !attachment_name.data.value {
                    log("Attachment name must not be null!");
                    return false;
                }

                attachment_name_override := read_string_reference(s, shared_strings);

                //log("Read attachment: %", attachment_name);

                attachment := read_attachment(skeleton, s, skin, slot.index, scale);
                if !attachment {
                    log("Error while loading attachment!");
                    return false;
                }

                attachment.name          = attachment_name;
                attachment.name_override = attachment_name_override;

                array_add(*slot.attachments, attachment);
            }
        }

        return true;
    }

    read_attachment :: (using skeleton: *Skeleton_Data, s: *string, skin: *Skin, slot_index: Slot_Index, scale: float64) -> *Attachment {
        attachment_type := cast(Attachment_Type) read_u8(s);
        if attachment_type == {
            case .REGION;
                region := New(Attachment_Region);
                region.path     = read_string_reference(s, shared_strings);
                region.rotation = read_f32(s);
                region.x        = read_f32(s) * scale;
                region.y        = read_f32(s) * scale;
                region.scale_x  = read_f32(s);
                region.scale_y  = read_f32(s);
                region.width    = read_f32(s) * scale;
                region.height   = read_f32(s) * scale;
                region.color    = read_color(s);
                region.sequence = read_sequence(s, loader_version);
                return region;

            case .BOUNDING_BOX;
                bounding_box := New(Attachment_Bounding_Box);
                bounding_box.vertices = read_vertices(s, scale);
                bounding_box.color    = ifx non_essential then read_color(s);
                return bounding_box;

            case .MESH;
                mesh := New(Attachment_Mesh);
                mesh.path         = read_string_reference(s, shared_strings);
                mesh.color        = read_color(s);
                mesh.vertex_count = read_var_s32(s, true);
                mesh.region_uvs   = read_f32_array(s, mesh.vertex_count << 1);
                mesh.triangles    = read_s16_array(s);
                mesh.vertices     = read_vertices(s, mesh.vertex_count, scale);
                mesh.hull_length  = read_var_s32(s, true) << 1;
                mesh.sequence     = read_sequence(s, loader_version);
                if non_essential {
                    mesh.edges    = read_s16_array(s);
                    mesh.width    = read_f32(s) * scale;
                    mesh.height   = read_f32(s) * scale;
                }
                return mesh;

            case .LINKED_MESH;
                mesh := New(Attachment_Linked_Mesh);
                mesh.path              = read_string_reference(s, shared_strings);
                mesh.color             = read_color(s);
                mesh.skin_name         = read_string_reference(s, shared_strings);
                mesh.parent            = read_string_reference(s, shared_strings);
                mesh.inherit_timelines = read_bool(s);
                mesh.sequence          = read_sequence(s, loader_version);
                if non_essential {
                    mesh.width  = read_f32(s) * scale;
                    mesh.height = read_f32(s) * scale;
                }
                return mesh;

            case .PATH;
                path := New(Attachment_Path);
                path.closed         = read_bool(s);
                path.constant_speed = read_bool(s);
                path.vertex_count   = read_var_s32(s, true);
                path.vertices       = read_vertices(s, path.vertex_count, scale);
                read_f32_array(*path.lengths, s, path.vertex_count / 3, scale);
                path.color = ifx non_essential then read_color(s);
                return path;

            case .POINT;
                print("TODO: Point\n");
                return null;

            case .CLIPPING;
                clipping := New(Attachment_Clipping);
                clipping.end_slot_index = read_var_s32(s, true);
                clipping.vertices       = read_vertices(s, scale);
                clipping.color          = ifx non_essential then read_color(s);
                return clipping;

            case;
                log("Unknown attachment type: %", attachment_type);
        }

        return null;
    }

    read_sequence :: (s: *string, version: Spine_Version) -> *Sequence {
        if version < .Version41 || !read_bool(s) {
            return null;
        }

        result := New(Sequence);
        result.regions_count = read_var_s32(s, true);
        result.start         = read_var_s32(s, true);
        result.digits        = read_var_s32(s, true);
        result.setup_index   = read_var_s32(s, true);
        return result;
    }

    read_vertices :: (s: *string, scale: float64) -> Vertices {
        vertex_count := read_var_s32(s, true);
        return read_vertices(s, vertex_count, scale);
    }

    read_vertices :: (s: *string, vertex_count: s32, scale: float64) -> Vertices {
        result: Vertices;
        result.vertex_count = vertex_count;

        vertices_count := vertex_count << 1;

        with_bones := read_bool(s);
        if !with_bones {
            result.vertices = read_f32_array(s, vertices_count, scale);
            return result;
        }

        array_reserve(*result.bones, vertex_count);
        for 0..vertex_count-1 {
            bones := array_add(*result.bones);

            bones_count := read_var_s32(s, true);
            array_reserve(bones, bones_count);
            for 0..bones_count-1 {
                vertex := array_add(bones);
                vertex.bone   = read_var_s32(s, true);
                vertex.x      = read_f32(s) * scale;
                vertex.y      = read_f32(s) * scale;
                vertex.weight = read_f32(s);
            }
        }

        return result;
    }

    read_animation :: (skeleton: *Skeleton_Data, using animation: *Animation_Data, s: *string, scale: float64) -> bool {
        total_timelines_count = read_var_s32(s, true);  // timelines_count

        // Slot timelines
        slot_timelines_count := read_var_s32(s, true);
        array_reserve(*slot_timelines, slot_timelines_count);
        for 0..slot_timelines_count-1 {
            using slot_timeline := array_add(*slot_timelines);
            slot_index = read_var_s32(s, true);

            timelines_count := read_var_s32(s, true);
            array_reserve(*timelines, timelines_count);
            for 0..timelines_count-1 {
                timeline_type := cast(Slot_Timeline.Timeline_Type) read_u8(s);
                frame_count := read_var_s32(s, true);

                create_timeline :: ($T: Type) -> *T #expand {
                    timeline := New(T);
                    timeline.frame_count = frame_count;
                    array_add(*timelines, timeline);
                    return timeline;
                }

                //log("Slot timeline type: %", timeline_type);
                if #complete timeline_type == {
                    case .ATTACHMENT;
                        timeline := create_timeline(Slot_Timeline.Attachment_Timeline);

                        array_reserve(*timeline.frames, frame_count);
                        for 0..frame_count-1 {
                            frame := array_add(*timeline.frames);
                            frame.time = read_f32(s);
                            frame.name = read_string_reference(s, skeleton.shared_strings);
                        }

                    case .RGBA;
                        timeline := create_timeline(Slot_Timeline.Rgba_Timeline);

                        timeline.bezier_count = read_var_s32(s, true);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.r = read_u8(s);
                            frame.g = read_u8(s);
                            frame.b = read_u8(s);
                            frame.a = read_u8(s);
                        }, #code {});
                        if !success  return false;

                    case .RGB;
                        log("TODO: rgb timeline");
                        return false;

                    case .RGBA2;
                        timeline := create_timeline(Slot_Timeline.Rgba2_Timeline);
                        
                        timeline.bezier_count = read_var_s32(s, true);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.r = read_u8(s);
                            frame.g = read_u8(s);
                            frame.b = read_u8(s);
                            frame.a = read_u8(s);
                            frame.r2 = read_u8(s);
                            frame.g2 = read_u8(s);
                            frame.b2 = read_u8(s);
                        }, #code {});
                        if !success  return false;

                    case .RGB2;
                        log("TODO: rgb2 timeline");
                        return false;

                    case .ALPHA;
                        log("TODO: alpha timeline");
                        return false;

                    case;
                        log("Unknown slot timeline type: %\n", timeline_type);
                        return false;
                }
            }
        }

        // Bone timelines
        bone_timelines_count := read_var_s32(s, true);
        array_reserve(*bone_timelines, bone_timelines_count);
        for 0..bone_timelines_count-1 {
            using bone_timeline := array_add(*bone_timelines);
            bone_index = read_var_s32(s, true);

            timelines_count := read_var_s32(s, true);
            array_reserve(*timelines, timelines_count);
            for 0..timelines_count-1 {
                timeline_type := cast(Bone_Timeline.Timeline_Type) read_u8(s);
                frame_count  := read_var_s32(s, true);
                bezier_count := read_var_s32(s, true);

                create_timeline :: ($T: Type) -> *T #expand {
                    timeline := New(T);
                    timeline.frame_count = frame_count;
                    timeline.bezier_count = bezier_count;
                    array_add(*timelines, timeline);
                    return timeline;
                }

                //log("Bone timeline type: %", timeline_type);
                if #complete timeline_type == {
                    case .ROTATE;
                        timeline := create_timeline(Bone_Timeline.Rotate_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.rotation = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .TRANSLATE;
                        timeline := create_timeline(Bone_Timeline.Translate_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                            frame.x = read_f32(s);
                            frame.y = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .TRANSLATE_X;
                        log("TODO: translate_x timeline");
                        return false;

                    case .TRANSLATE_Y;
                        log("TODO: translate_y timeline");
                        return false;

                    case .SCALE;
                        timeline := create_timeline(Bone_Timeline.Scale_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.scale_x = read_f32(s);
                            frame.scale_y = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .SCALE_X;
                        log("TODO: scale_x timeline");
                        return false;

                    case .SCALE_Y;
                        log("TODO: scale_y timeline");
                        return false;

                    case .SHEAR;
                        timeline := create_timeline(Bone_Timeline.Shear_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.shear_x = read_f32(s);
                            frame.shear_y = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .SHEAR_X;
                        log("TODO: shear_xtimeline");
                        return false;

                    case .SHEAR_Y;
                        log("TODO: shear_ytimeline");
                        return false;

                    case;
                        log("Unknown bone timeline type: %\n", timeline_type);
                        return false;
                }
            }
        }

        // Ik constraint timelines
        ik_timelines_count := read_var_s32(s, true);
        array_reserve(*ik_timelines, ik_timelines_count);
        for 0..ik_timelines_count-1 {
            using timeline := array_add(*ik_timelines);
            ik_constraint_index = read_var_s32(s, true);

            frame_count  = read_var_s32(s, true);
            bezier_count = read_var_s32(s, true);

            //log("Ik constraint timeline");

            success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                frame.mix            = read_f32(s);
                frame.softness       = read_f32(s) * scale;
            }, #code {
                frame.bend_direction = read_s8(s);
                frame.compress       = read_bool(s);
                frame.stretch        = read_bool(s);
            });
            if !success  return false;
        }

        // Transform constraint timelines
        transform_timelines_count := read_var_s32(s, true);
        array_reserve(*transform_timelines, transform_timelines_count);
        for 0..transform_timelines_count-1 {
            using timeline := array_add(*transform_timelines);
            transform_constraint_index = read_var_s32(s, true);

            frame_count  = read_var_s32(s, true);
            bezier_count = read_var_s32(s, true);

            //log("Transform timeline");

            success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                frame.rotate  = read_f32(s);
                frame.mix_x   = read_f32(s);
                frame.mix_y   = read_f32(s);
                frame.scale_x = read_f32(s);
                frame.scale_y = read_f32(s);
                frame.shear_y = read_f32(s);
            }, #code {});
            if !success  return false;
        }

        // Path constraint timelines
        path_timelines_count := read_var_s32(s, true);
        array_reserve(*path_timelines, path_timelines_count);
        for 0..path_timelines_count-1 {
            using path_timeline := array_add(*path_timelines);
            path_constraint_index = read_var_s32(s, true);
            
            path_constraint := skeleton.path_constraints[path_constraint_index];

            timelines_count := read_var_s32(s, true);
            array_reserve(*timelines, timelines_count);
            for 0..timelines_count-1 {
                path_type := cast(Path_Type) read_u8(s);
                
                frame_count := read_var_s32(s, true);
                bezier_count := read_var_s32(s, true);

                //log("Path timeline type: %", path_type);
                
                create_timeline :: ($T: Type) -> *T #expand {
                    timeline := New(T);
                    timeline.frame_count = frame_count;
                    timeline.bezier_count = bezier_count;
                    array_add(*timelines, timeline);
                    return timeline;
                }
                
                timeline_scale: float64 = 1;

                if #complete path_type == {
                    case .POSITION;
                        timeline := create_timeline(Path_Timeline.Position_Timeline);
                        
                        if path_constraint.position_mode == .FIXED {
                            timeline_scale = scale;
                        }
                        
                        success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                            frame.position = read_f32(s) * timeline_scale;
                        }, #code {});
                        if !success  return false;

                    case .SPACING;
                        log("TODO: spacing timeline");
                        return false;

                    case .MIX;
                        log("TODO: mix timeline");
                        return false;

                    case;
                        log("Unknown path type: %\n", path_type);
                        return false;
                }
            }
        }

        // Deform timelines
        deform_timelines_count := read_var_s32(s, true);
        array_reserve(*deform_timelines, deform_timelines_count);
        for 0..deform_timelines_count-1 {
            using deform_timeline := array_add(*deform_timelines);
            skin_index = read_var_s32(s, true);

            slot_timelines_count := read_var_s32(s, true);
            array_reserve(*slot_timelines, slot_timelines_count);
            for 0..slot_timelines_count-1 {
                using slot_timeline := array_add(*slot_timelines);
                slot_index = read_var_s32(s, true);

                attachment_timelines_count := read_var_s32(s, true);
                array_reserve(*attachment_timelines, attachment_timelines_count);
                for 0..attachment_timelines_count-1 {
                    attachment_name := read_string_reference(s, skeleton.shared_strings);
                    timeline_type := read_deform_timeline_type(s, skeleton.loader_version);
                    frame_count := read_var_s32(s, true);

                    create_timeline :: ($T: Type) -> *T #expand {
                        timeline := New(T);
                        timeline.attachment_name = attachment_name;
                        timeline.timeline_type = timeline_type;
                        timeline.frame_count = frame_count;
                        array_add(*attachment_timelines, timeline);
                        return timeline;
                    }

                    //log("Deform timeline type: %", timeline_type);
                    if #complete timeline_type == {
                        case .DEFORM;
                            timeline := create_timeline(Deform_Timeline.Slot_Timeline.Attachment_Deform_Timeline);
                            timeline.bezier_count = read_var_s32(s, true);
                            success := read_curve_timeline(timeline, s, frame_count, 1, #code {}, #code {
                                frame.deform_length = read_var_s32(s, true);
                                if frame.deform_length > 0 {
                                    frame.offset = read_var_s32(s, true);
                                    read_f32_array(*frame.deform, s, frame.deform_length, scale);
                                }
                            });
                            if !success  return false;

                        case .SEQUENCE;
                            timeline := create_timeline(Deform_Timeline.Slot_Timeline.Attachment_Sequence_Timeline);
                            
                            array_reserve(*timeline.frames, frame_count);
                            
                            for 0..frame_count-1 {
                            	frame := array_add(*timeline.frames);
                            	frame.time = read_f32(s);
                            	mode_and_index := read_s32(s);
                                frame.sequence_mode = xx mode_and_index & 0xf;  // @todo Assert that it is a valid enum value!
                                frame.index = mode_and_index >> 4;
                                frame.delay = read_f32(s);
                            }

                        case;
                            log("Unknown deform timeline type: %\n", timeline_type);
                            return false;
                    }
                }
            }
        }

        // Draw order timeline
        draw_order_count := read_var_s32(s, true);
        array_reserve(*draw_order_timeline.frames, draw_order_count);
        for 0..draw_order_count-1 {
            using frame := array_add(*draw_order_timeline.frames);
            time = read_f32(s);

            offsets_count := read_var_s32(s, true);
            array_reserve(*offsets, offsets_count);
            for 0..offsets_count-1 {
                using _ := array_add(*offsets);
                slot_index = read_var_s32(s, true);
                offset     = read_var_s32(s, true);
            }
        }

        // Event timeline
        event_count := read_var_s32(s, true);
        array_reserve(*events, event_count);
        for 0..event_count-1 {
            using event := array_add(*events);
            time             = read_f32(s);
            event_index      = read_var_s32(s, true);
            value_int        = read_var_s32(s, false);
            value_float      = read_f32(s);
            use_value_string = read_bool(s);
            value_string     = ifx use_value_string then read_string(s);
            event_data  := skeleton.events[event_index];
            if event_data.audio_path.has_value && event_data.audio_path.value {
                volume  = read_f32(s);
                balance = read_f32(s);
            }
        }

        return true;
    }

    read_curve_timeline :: (using timeline: *Curve_Timeline($Frame), s: *string, frame_count: s32, scale: float64, code_before_bezier: Code, code_after_bezier: Code) -> bool #expand {
        array_reserve(*frames, frame_count);
        for 0..frame_count-1 {
            `frame := array_add(*frames);
            frame.time = read_f32(s);

            #insert code_before_bezier;

            if it > 0 {
                frame.type = xx read_u8(s);

                if #complete frame.type == {
                    case .LINEAR;
                    case .STEPPED;
                    case .BEZIER;
                        for * frame.beziers {
                            it.cx1 = read_f32(s);
                            it.cy1 = read_f32(s) * scale;
                            it.cx2 = read_f32(s);
                            it.cy2 = read_f32(s) * scale;
                        }

                    case;
                        assert(false, "Unknown curve type: %\n", frame.type);
                        return false;
                }
            }

            #insert code_after_bezier;
        }

        return true;
    }

    read_deform_timeline_type :: (s: *string, version: Spine_Version) -> Deform_Timeline_Type {
        if version == .Version40 {
            return .DEFORM;
        } else {
            return xx read_u8(s);
        }
    }
}


#import "Basic";
#import "String";
