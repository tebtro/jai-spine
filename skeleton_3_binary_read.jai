Skeleton_3_Binary_Read :: struct {
	using Skeleton_3;
	using Binary_Read;

    load :: (data: string, scale: float64, spine_version: Spine_Version) -> *Skeleton_Data {
        s := *data;

        using skeleton := New(Skeleton_Data);

        hash    = read_string(s);
        version = read_string(s);

        x = read_f32(s);
        y = read_f32(s);
        width  = read_f32(s);
        height = read_f32(s);

        non_essential = read_bool(s);
        if non_essential {
            fps = read_f32(s);
            images_path = read_string(s);
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
            constraint.rotate_mix      = read_f32(s);
            constraint.translate_mix   = read_f32(s);
            constraint.scale_mix       = read_f32(s);
            constraint.shear_mix       = read_f32(s);
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
            constraint.rotate_mix      = read_f32(s);
            constraint.translate_mix   = read_f32(s);
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
                if non_essential {
                    mesh.edges    = read_s16_array(s);
                    mesh.width    = read_f32(s) * scale;
                    mesh.height   = read_f32(s) * scale;
                }
                return mesh;

            case .LINKED_MESH;
                mesh := New(Attachment_Linked_Mesh);
                mesh.path           = read_string_reference(s, shared_strings);
                mesh.color          = read_color(s);
                mesh.skin_name      = read_string_reference(s, shared_strings);
                mesh.parent         = read_string_reference(s, shared_strings);
                mesh.inherit_deform = read_bool(s);
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

                    case .COLOR;
                        timeline := create_timeline(Slot_Timeline.Color_Timeline);

                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                        	frame.color = read_color(s);
                        }, #code {});
                        if !success  return false;

                    case .TWO_COLOR;
                        timeline := create_timeline(Slot_Timeline.Two_Color_Timeline);
                        
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                        	frame.light = read_color(s);
                        	frame.dark = read_color(s);
                        }, #code {});
                        if !success  return false;

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

                create_timeline :: ($T: Type) -> *T #expand {
                    timeline := New(T);
                    timeline.frame_count = frame_count;
                    array_add(*timelines, timeline);
                    return timeline;
                }

                //log("Bone timeline type: %", timeline_type);
                if #complete timeline_type == {
                    case .ROTATE;
                        timeline := create_timeline(Bone_Timeline.Rotate_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.angle = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .TRANSLATE;
                        timeline := create_timeline(Bone_Timeline.Translate_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                            frame.x = read_f32(s) * scale;
                            frame.y = read_f32(s) * scale;
                        }, #code {});
                        if !success  return false;

                    case .SCALE;
                        timeline := create_timeline(Bone_Timeline.Scale_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.scale_x = read_f32(s);
                            frame.scale_y = read_f32(s);
                        }, #code {});
                        if !success  return false;

                    case .SHEAR;
                        timeline := create_timeline(Bone_Timeline.Shear_Timeline);
                        success := read_curve_timeline(timeline, s, frame_count, 1, #code {
                            frame.shear_x = read_f32(s);
                            frame.shear_y = read_f32(s);
                        }, #code {});
                        if !success  return false;

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

            //log("Transform timeline");

            success := read_curve_timeline(timeline, s, frame_count, scale, #code {
                frame.rotate_mix    = read_f32(s);
                frame.translate_mix = read_f32(s);
                frame.scale_mix     = read_f32(s);
                frame.shear_mix     = read_f32(s);
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
                    using attachment_timeline := array_add(*attachment_timelines);
                    attachment_name = read_string_reference(s, skeleton.shared_strings);
                    frame_count = read_var_s32(s, true);
                    
                    success := read_curve_timeline(attachment_timeline, s, frame_count, 1, #code {
                        frame.offset = read_var_s32(s, true);
                        if frame.offset > 0 {
                            start := read_var_s32(s, true);
                            vertices_count := frame.offset;
                            read_f32_array(*frame.vertices, s, vertices_count, scale);
                        }
                    }, #code {});
                    if !success  return false;
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

			// @todo: Weird confusion!  Why do we have it > 0 in v4?
            //if it > 0
            if it < frame_count - 1
            {
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
}


#import "Basic";
#import "String";
