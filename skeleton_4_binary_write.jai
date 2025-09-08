Skeleton_4_Binary_Write :: struct {
	using Skeleton_4;
	using Binary_Write;

    write :: (b: *String_Builder, base_skeleton: *Base_Skeleton_Data, optimize: bool) {
        using skeleton := cast(*Skeleton_Data) base_skeleton;

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
            write_bool   (b,    it.skin_required);
            if non_essential  write_color(b, it.color);
        }

        // Slots
        write_var_s32(b, xx slots.count, true);
        for slots {
            write_string (b, it.name);
            write_var_s32(b, it.bone, true);
            write_color  (b, it.color);
            write_color  (b, it.dark_color);
            write_string_reference(b, shared_strings, it.attachment_name, optimize);
            write_var_s32(b, xx it.blend_mode, true);
        }

        // Ik constraints
        write_var_s32(b, xx ik_constraints.count, true);
        for ik_constraints {
            write_string (b,    it.name);
            write_var_s32(b,    it.order, true);
            write_bool   (b,    it.skin_required);
            write_var_s32(b, xx it.bones.count, true);
            for it.bones {
                write_var_s32(b, it, true);
            }
            write_var_s32(b, it.target, true);
            write_f32    (b, it.mix);
            write_f32    (b, it.softness);
            write_s8     (b, it.bend_direction);
            write_bool   (b, it.compress);
            write_bool   (b, it.stretch);
            write_bool   (b, it.uniform);
        }

        // Transform constraints
        write_var_s32(b, xx transform_constraints.count, true);
        for transform_constraints {
            write_string (b,    it.name);
            write_var_s32(b,    it.order, true);
            write_bool   (b,    it.skin_required);
            write_var_s32(b, xx it.bones.count, true);
            for it.bones {
                write_var_s32(b, it, true);
            }
            write_var_s32(b, it.target, true);
            write_bool(b, it.local);
            write_bool(b, it.relative);
            write_f32(b, it.offset_rotation);
            write_f32(b, it.offset_x);
            write_f32(b, it.offset_y);
            write_f32(b, it.offset_scale_x);
            write_f32(b, it.offset_scale_y);
            write_f32(b, it.offset_shear_y);
            write_f32(b, it.mix_rotate);
            write_f32(b, it.mix_x);
            write_f32(b, it.mix_y);
            write_f32(b, it.mix_scale_x);
            write_f32(b, it.mix_scale_y);
            write_f32(b, it.mix_shear_y);
        }

        // Path constraints
        write_var_s32(b, xx path_constraints.count, true);
        for path_constraints {
            write_string (b, it.name);
            write_var_s32(b, it.order, true);
            write_bool   (b, it.skin_required);
            write_var_s32(b, xx it.bones.count, true);
            for it.bones {
                write_var_s32(b, it, true);
            }
            write_var_s32(b,    it.target, true);
            write_var_s32(b, xx it.position_mode, true);
            write_var_s32(b, xx it.spacing\_mode, true);
            write_var_s32(b, xx it.rotate\ _mode, true);
            write_f32    (b,    it.offset_rotation);
            write_f32    (b,    it.position);
            write_f32    (b,    it.spacing);
            write_f32    (b,    it.mix_rotate);
            write_f32    (b,    it.mix_x);
            write_f32    (b,    it.mix_y);
        }

        // Default skin
        write_skin(b, skeleton, *default_skin, is_default_skin = true, optimize);

        // Skins
        write_var_s32(b, xx skins.count, true);
        for * skins {
            write_skin(b, skeleton, it, is_default_skin = false, optimize);
        }

        // Events
        write_var_s32(b, xx events.count, true);
        for events {
            write_string_reference(b, shared_strings, it.name, optimize);
            write_var_s32(b, it.value_int, false);
            write_f32    (b, it.value_float);
            write_string (b, it.value_string);
            write_string (b, it.audio_path);
            if it.audio_path.has_value && it.audio_path.value {
                write_f32(b, it.volume);
                write_f32(b, it.balance);
            }
        }

        // Animations
        write_var_s32(b, xx animations.count, true);
        for animations {
            write_string(b, it.name);
            write_animation(b, skeleton, it, optimize);
        }
    }

    write_skin :: (b: *String_Builder, skeleton: *Skeleton_Data, using skin: *Skin, is_default_skin: bool, optimize: bool) {
        if is_default_skin {
            assert(name.data.has_value && name.data.value == "default");
            write_var_s32(b, xx slots.count, true);
        } else {
            write_string_reference(b, skeleton.shared_strings, name, optimize);

            write_var_s32_array(b, bones);
            write_var_s32_array(b, ik\      _constraints);
            write_var_s32_array(b, transform_constraints);
            write_var_s32_array(b, path\    _constraints);

            write_var_s32(b, xx slots.count, true);
        }

        for slots {
            write_var_s32(b, it.index, true);

            write_var_s32(b, xx it.attachments.count, true);
            for it.attachments {
                write_string_reference(b, skeleton.shared_strings, it.name,          optimize);
                write_string_reference(b, skeleton.shared_strings, it.name_override, optimize);
                write_attachment(b, skeleton, it, optimize);
            }
        }
    }

    write_attachment :: (b: *String_Builder, using skeleton: *Skeleton_Data, attachment: *Attachment, optimize: bool) {
        write_u8(b, xx attachment.type);
        if attachment.type == {
            case .REGION;
                region := cast(*Attachment_Region) attachment;
                write_string_reference(b, shared_strings, region.path, optimize);
                write_f32  (b, region.rotation);
                write_f32  (b, region.x);
                write_f32  (b, region.y);
                write_f32  (b, region.scale_x);
                write_f32  (b, region.scale_y);
                write_f32  (b, region.width);
                write_f32  (b, region.height);
                write_color(b, region.color);
                write_sequence(b, skeleton, region.sequence);

            case .BOUNDING_BOX;
                bounding_box := cast(*Attachment_Bounding_Box) attachment;
                write_vertices(b, bounding_box.vertices);
                if non_essential  write_color(b, bounding_box.color);

            case .MESH;
                mesh := cast(*Attachment_Mesh) attachment;
                write_string_reference(b, shared_strings, mesh.path, optimize);
                write_color    (b, mesh.color);
                write_var_s32  (b, mesh.vertex_count, true);
                write_f32_array(b, mesh.region_uvs, mesh.vertex_count << 1);
                write_s16_array(b, mesh.triangles);
                write_vertices (b, mesh.vertices, mesh.vertex_count);
                write_var_s32  (b, mesh.hull_length >> 1, true);
                write_sequence (b, skeleton, mesh.sequence);
                if non_essential {
                    write_s16_array(b, mesh.edges);
                    write_f32      (b, mesh.width);
                    write_f32      (b, mesh.height);
                }

            case .LINKED_MESH;
                mesh := cast(*Attachment_Linked_Mesh) attachment;
                write_string_reference(b, shared_strings, mesh.path, optimize);
                write_color(b, mesh.color);
                write_string_reference(b, shared_strings, mesh.skin_name, optimize);
                write_string_reference(b, shared_strings, mesh.parent,    optimize);
                write_bool(b, mesh.inherit_timelines);
                write_sequence(b, skeleton, mesh.sequence);
                if non_essential {
                    write_f32(b, mesh.width);
                    write_f32(b, mesh.height);
                }

            case .PATH;
                path := cast(*Attachment_Path) attachment;
                write_bool     (b, path.closed);
                write_bool     (b, path.constant_speed);
                write_var_s32  (b, path.vertex_count, true);
                write_vertices (b, path.vertices, path.vertex_count);
                write_f32_array(b, path.lengths, path.vertex_count / 3);
                if non_essential  write_color(b, path.color);

            case .POINT;
                log("TODO: Point");

            case .CLIPPING;
                clipping := cast(*Attachment_Clipping) attachment;
                write_var_s32 (b, clipping.end_slot_index, true);
                write_vertices(b, clipping.vertices);
                if non_essential  write_color(b, clipping.color);

            case;
                log("Unknown attachment type: %", attachment.type);
        }
    }

    write_sequence :: (b: *String_Builder, using skeleton: *Skeleton_Data, sequence: *Sequence) {
        if loader_version < .Version41 {
            return;
        }

        write_bool(b, xx sequence);
        if sequence {
            write_var_s32(b, sequence.regions_count, true);
            write_var_s32(b, sequence.start,         true);
            write_var_s32(b, sequence.digits,        true);
            write_var_s32(b, sequence.setup_index,   true);
        }
    }

    write_vertices :: (b: *String_Builder, vertices: Vertices) {
        write_var_s32(b, vertices.vertex_count, true);
        write_vertices(b, vertices, vertices.vertex_count);
    }

    write_vertices :: (b: *String_Builder, vertices: Vertices, vertex_count: s32) {
        vertices_count := vertex_count << 1;

		with_bones := vertices.bones.count > 0;
        write_bool(b, with_bones);
        if !with_bones {
            write_f32_array(b, vertices.vertices, vertices_count);
            return;
        }

        assert(vertices.bones.count == vertex_count);
        for vertices.bones {
            write_var_s32(b, xx it.count, true);
            for it {
                write_var_s32(b, it.bone, true);
                write_f32    (b, it.x);
                write_f32    (b, it.y);
                write_f32    (b, it.weight);
            }
        }
    }

    write_animation :: (b: *String_Builder, skeleton: *Skeleton_Data, using animation: Animation_Data, optimize: bool) {
        write_var_s32(b, total_timelines_count, true);

        // Slot timelines
        write_var_s32(b, xx slot_timelines.count, true);
        for slot_timelines {
            write_var_s32(b, it.slot_index, true);

            write_var_s32(b, xx it.timelines.count, true);
            for it.timelines {
                write_u8(b, xx it.type);
                write_var_s32(b, xx it.frame_count, true);

                if #complete it.type == {
                    case .ATTACHMENT;
                        timeline := cast(*Slot_Timeline.Attachment_Timeline) it;

                        for timeline.frames {
                            write_f32(b, it.time);
                            write_string_reference(b, skeleton.shared_strings, it.name, optimize);
                        }

                    case .RGBA;
                        timeline := cast(*Slot_Timeline.Rgba_Timeline) it;

                        write_var_s32(b, timeline.bezier_count, true);
                        write_curve_timeline(b, timeline, #code {
                            write_u8(b, frame.r);
                            write_u8(b, frame.g);
                            write_u8(b, frame.b);
                            write_u8(b, frame.a);
                        }, #code {});

                    case .RGB;
                        log("TODO: rgb timeline");

                    case .RGBA2;
                        timeline := cast(*Slot_Timeline.Rgba2_Timeline) it;

                        write_var_s32(b, timeline.bezier_count, true);
                        write_curve_timeline(b, timeline, #code {
                            write_u8(b, frame.r);
                            write_u8(b, frame.g);
                            write_u8(b, frame.b);
                            write_u8(b, frame.a);
                            write_u8(b, frame.r2);
                            write_u8(b, frame.g2);
                            write_u8(b, frame.b2);
                        }, #code {});

                    case .RGB2;
                        log("TODO: rgb2 timeline");

                    case .ALPHA;
                        log("TODO: alpha timeline");

                    case;
                        log("Unknown slot timeline type: %\n", it.type);
                }
            }
        }

        // Bone timelines
        write_var_s32(b, xx bone_timelines.count, true);
        for bone_timelines {
            write_var_s32(b, it.bone_index, true);

            write_var_s32(b, xx it.timelines.count, true);
            for it.timelines {
                write_u8(b, xx it.type);
                write_var_s32(b, it.frame_count, true);
                write_var_s32(b, it.bezier_count, true);

                if #complete it.type == {
                    case .ROTATE;
                        timeline := cast(*Bone_Timeline.Rotate_Timeline) it;
                        write_curve_timeline(b, timeline, #code {
                            write_f32(b, frame.rotation);
                        }, #code {});

                    case .TRANSLATE;
                        timeline := cast(*Bone_Timeline.Translate_Timeline) it;
                        write_curve_timeline(b, timeline, #code {
                            write_f32(b, frame.x);
                            write_f32(b, frame.y);
                        }, #code {});

                    case .TRANSLATE_X;
                        log("TODO: translate_x timeline");

                    case .TRANSLATE_Y;
                        log("TODO: translate_y timeline");

                    case .SCALE;
                        timeline := cast(*Bone_Timeline.Scale_Timeline) it;
                        write_curve_timeline(b, timeline, #code {
                            write_f32(b, frame.scale_x);
                            write_f32(b, frame.scale_y);
                        }, #code {});

                    case .SCALE_X;
                        log("TODO: scale_x timeline");

                    case .SCALE_Y;
                        log("TODO: scale_y timeline");

                    case .SHEAR;
                        timeline := cast(*Bone_Timeline.Shear_Timeline) it;
                        write_curve_timeline(b, timeline, #code {
                            write_f32(b, frame.shear_x);
                            write_f32(b, frame.shear_y);
                        }, #code {});

                    case .SHEAR_X;
                        log("TODO: shear_xtimeline");

                    case .SHEAR_Y;
                        log("TODO: shear_ytimeline");

                    case;
                        log("Unknown bone timeline type: %\n", it.type);
                }
            }
        }

        // Ik constraint timelines
        write_var_s32(b, xx ik_timelines.count, true);
        for * ik_timelines {
            write_var_s32(b, it.ik_constraint_index, true);

            write_var_s32(b, it.frame_count, true);
            write_var_s32(b, it.bezier_count, true);

            write_curve_timeline(b, it, #code {
                write_f32(b, frame.mix);
                write_f32(b, frame.softness);
            }, #code {
                write_s8(b, frame.bend_direction);
                write_bool(b, frame.compress);
                write_bool(b, frame.stretch);
            });
        }

        // Transform constraint timelines
        write_var_s32(b, xx transform_timelines.count, true);
        for * transform_timelines {
            write_var_s32(b, it.transform_constraint_index, true);

            write_var_s32(b, it.frame_count, true);
            write_var_s32(b, it.bezier_count, true);

            write_curve_timeline(b, it, #code {
                write_f32(b, frame.rotate);
                write_f32(b, frame.mix_x);
                write_f32(b, frame.mix_y);
                write_f32(b, frame.scale_x);
                write_f32(b, frame.scale_y);
                write_f32(b, frame.shear_y);
            }, #code {});
        }

        // Path constraint timelines
        write_var_s32(b, xx path_timelines.count, true);
        for path_timelines {
            write_var_s32(b, it.path_constraint_index, true);

            write_var_s32(b, xx it.timelines.count, true);
            for it.timelines {
            	write_u8(b, xx it.path_type);
            
                write_var_s32(b, it.frame_count, true);
                write_var_s32(b, it.bezier_count, true);
            
                if #complete it.path_type == {
                	case .POSITION;
                        timeline := cast(*Path_Timeline.Position_Timeline) it;
                        write_curve_timeline(b, timeline, #code {
                            write_f32(b, frame.position);
                        }, #code {});

                    case .SPACING;
                        log("TODO: spacing timeline");
                        return;

                    case .MIX;
                        log("TODO: mix timeline");
                        return;

                    case;
                        log("Invalid path type: %\n", it.path_type);
                        return;
                }
            }
        }

        // Deform timelines
        write_var_s32(b, xx deform_timelines.count, true);
        for deform_timelines {
            write_var_s32(b, it.skin_index, true);

            write_var_s32(b, xx it.slot_timelines.count, true);
            for it.slot_timelines {
                write_var_s32(b, it.slot_index, true);

                write_var_s32(b, xx it.attachment_timelines.count, true);
                for it.attachment_timelines {
                    write_string_reference(b, skeleton.shared_strings, it.attachment_name, optimize);
                    write_deform_timeline_type(b, skeleton, it.timeline_type);
                    write_var_s32(b, it.frame_count, true);

                    if #complete it.timeline_type == {
                        case .DEFORM;
                            timeline := cast(*Deform_Timeline.Slot_Timeline.Attachment_Deform_Timeline) it;
                            write_var_s32(b, timeline.bezier_count, true);
                            write_curve_timeline(b, timeline, #code {}, #code {
                                write_var_s32(b, frame.deform_length, true);
                                if frame.deform_length > 0 {
                                    write_var_s32(b, frame.offset, true);
                                    write_f32_array(b, frame.deform, frame.deform_length);
                                }
                            });

                        case .SEQUENCE;
                            timeline := cast(*Deform_Timeline.Slot_Timeline.Attachment_Sequence_Timeline) it;
                            for timeline.frames {
                            	write_f32(b, it.time);
                            	write_s32(b, it.sequence_mode.(s32) | (it.index << 4));
                            	write_f32(b, it.delay);
                            }

                        case;
                            log("Unknown deform timeline type: %\n", it.timeline_type);
                    }
                }
            }
        }

        // Draw order timeline
        write_var_s32(b, xx draw_order_timeline.frames.count, true);
        for draw_order_timeline.frames {
            write_f32(b, it.time);

            write_var_s32(b, xx it.offsets.count, true);
            for it.offsets {
                write_var_s32(b, it.slot_index, true);
                write_var_s32(b, it.offset,     true);
            }
        }

        // Event timeline
        write_var_s32(b, xx events.count, true);
        for events {
            write_f32    (b, it.time);
            write_var_s32(b, it.event_index, true);
            write_var_s32(b, it.value_int, false);
            write_f32    (b, it.value_float);
            write_bool   (b, it.use_value_string);
            if it.use_value_string  write_string (b, it.value_string);
            event_data  := skeleton.events[it.event_index];
            if event_data.audio_path.has_value && event_data.audio_path.value {
                write_f32(b, it.volume);
                write_f32(b, it.balance);
            }
        }
    }

    write_curve_timeline :: (b: *String_Builder, using timeline: *Curve_Timeline($Frame), code_before_bezier: Code, code_after_bezier: Code) #expand {
        for `frame: frames {
            write_f32(b, frame.time);

            #insert code_before_bezier;

            if it_index > 0 {
                write_u8(b, xx frame.type);

                if #complete frame.type == {
                    case .LINEAR;
                    case .STEPPED;
                    case .BEZIER;
                        for frame.beziers {
                            write_f32(b, it.cx1);
                            write_f32(b, it.cy1);
                            write_f32(b, it.cx2);
                            write_f32(b, it.cy2);
                        }

                    case;
                        assert(false, "Unknown curve type: %\n", frame.type);
                }
            }

            #insert code_after_bezier;
        }
    }

    write_deform_timeline_type :: (b: *String_Builder, skeleton: *Skeleton_Data, type: Deform_Timeline_Type) {
        if skeleton.loader_version >= .Version41 {
            write_u8(b, xx type);
        }
    }
}


#import "Basic";
