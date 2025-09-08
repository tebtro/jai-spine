Skeleton_4 :: struct {
    Skeleton_Data :: struct {
        #as using base: Base_Skeleton_Data = .{
            loader_version = .Version41,
        };

        hash_low:  u32;
        hash_high: u32;

        version: Optional(string);

        x:      float64;
        y:      float64;
        width:  float64;
        height: float64;

        non_essential: bool;

        fps: float64;
        image_path: Optional(string);
        audio_path: Optional(string);

        shared_strings: [..] String_Reference;

        bones: [..] Bone_Data;
        slots: [..] Slot_Data;
        ik_constraints: [..] Ik_Constraint;
        transform_constraints: [..] Transform_Constraint;
        path_constraints: [..] Path_Constraint;

        default_skin: Skin;
        skins: [..] Skin;

        events: [..] Event_Data;

        animations: [..] Animation_Data;
    }

    Bone\_Index :: s32;
    Slot\_Index :: s32;
    Skin\_Index :: s32;
    Event_Index :: s32;

    Ik\      _Constraint_Index :: s32;
    Transform_Constraint_Index :: s32;
    Path\    _Constraint_Index :: s32;

    Bone_Data :: struct {
        name: Optional(string);
        parent: Bone_Index;
        rotation: float64;
        x: float64;
        y: float64;
        scale_x: float64;
        scale_y: float64;
        shear_x: float64;
        shear_y: float64;
        length: float64;
        transform_mode: Transform_Mode;
        skin_required: bool;
        color: Color;
    }

    Slot_Data :: struct {
        name: Optional(string);
        bone: Bone_Index;
        color: Color;
        dark_color: Color;
        attachment_name: String_Reference;
        blend_mode: Blend_Mode;
    }

    Ik_Constraint :: struct {
        name: Optional(string);
        order: s32;
        skin_required: bool;
        bones: [..] Bone_Index;
        target: Bone_Index;
        mix: float64;
        softness: float64;
        bend_direction: s8;
        compress: bool;
        stretch: bool;
        uniform: bool;
    }

    Transform_Constraint :: struct {
        name: Optional(string);
        order: s32;
        skin_required: bool;
        bones: [..] Bone_Index;
        target: Bone_Index;
        local: bool;
        relative: bool;
        offset_rotation: float64;
        offset_x: float64;
        offset_y: float64;
        offset_scale_x: float64;
        offset_scale_y: float64;
        offset_shear_y: float64;
        mix_rotate: float64;
        mix_x: float64;
        mix_y: float64;
        mix_scale_x: float64;
        mix_scale_y: float64;
        mix_shear_y: float64;
    }

    Path_Constraint :: struct {
        name: Optional(string);
        order: s32;
        skin_required: bool;
        bones: [..] Bone_Index;
        target: Bone_Index;
        position_mode: Path_Position_Mode;
        spacing_mode:  Path_Spacing_Mode;
        rotate_mode:   Path_Rotate_Mode;
        offset_rotation: float64;
        position: float64;
        spacing: float64;
        mix_rotate: float64;
        mix_x: float64;
        mix_y: float64;
    }

    Skin :: struct {
        name: String_Reference;
        bones: [..] Bone_Index;
        ik\      _constraints: [..] Ik\      _Constraint_Index;
        transform_constraints: [..] Transform_Constraint_Index;
        path\    _constraints: [..] Path\    _Constraint_Index;
        slots: [..] Slot;
    }

    Slot :: struct {
        index: Slot_Index;
        attachments: [..] *Attachment;
    }

    Attachment :: struct {
        name:          String_Reference;
        name_override: String_Reference;
        type:          Attachment_Type;
    }

    Attachment_Type :: enum {
        REGION       :: 0;
        BOUNDING_BOX :: 1;
        MESH         :: 2;
        LINKED_MESH  :: 3;
        PATH         :: 4;
        POINT        :: 5;
        CLIPPING     :: 6;
    }

    Attachment_Region :: struct {
        #as using _: Attachment = .{ type = .REGION };
        path: String_Reference;
        rotation: float64;
        x: float64;
        y: float64;
        scale_x: float64;
        scale_y: float64;
        width: float64;
        height: float64;
        color: Color;
        sequence: *Sequence;
    }

    Attachment_Bounding_Box :: struct {
        #as using _: Attachment = .{ type = .BOUNDING_BOX };
        vertices: Vertices;
        color: Color;
    }

    Attachment_Mesh :: struct {
        #as using _: Attachment = .{ type = .MESH };
        path: String_Reference;
        color: Color;
        vertex_count: s32;
        region_uvs: [..] float64;
        triangles: [..] s16;
        vertices: Vertices;
        hull_length: s32;
        sequence: *Sequence;
        edges: [..] s16;
        width: float64;
        height: float64;
    }

    Attachment_Linked_Mesh :: struct {
        #as using _: Attachment = .{ type = .LINKED_MESH };
        path: String_Reference;
        color: Color;
        skin_name: String_Reference;
        parent: String_Reference;
        inherit_timelines: bool;
        sequence: *Sequence;
        width:  float64;
        height: float64;
    }

    Attachment_Path :: struct {
        #as using _: Attachment = .{ type = .PATH };
        closed: bool;
        constant_speed: bool;
        vertex_count: s32;
        vertices: Vertices;
        lengths: [..] float64;
        color: Color;
    }

    Attachment_Point :: struct {
        #as using _: Attachment = .{ type = .POINT };
        rotation: float64;
        x: float64;
        y: float64;
        color: Color;
    }

    Attachment_Clipping :: struct {
        #as using _: Attachment = .{ type = .CLIPPING };
        end_slot_index: Slot_Index;
        vertices: Vertices;
        color: Color;
    }

    Sequence :: struct {
        regions_count: s32;
        start: s32;
        digits: s32;
        setup_index: s32;
    }

    Vertices :: struct {
        vertex_count: s32;
        vertices: [..] float64;
        bones: [..] [..] Bone_Vertex;

        Bone_Vertex :: struct {
            bone: Bone_Index;
            x: float64;
            y: float64;
            weight: float64;
        }
    }

    Event_Data :: struct {
        name:         String_Reference;
        value_int:    s32;
        value_float:  float64;
        value_string: Optional(string);
        audio_path:   Optional(string);
        volume:       float64;
        balance:      float64;
    }

    Event :: struct {
        time:             float64;
        event_index:      Event_Index;
        value_int:        s32;
        value_float:      float64;
        use_value_string: bool;
        value_string:     Optional(string);
        volume:           float64;
        balance:          float64;
    }

    Animation_Data :: struct {
        name: Optional(string);
        total_timelines_count: s32;
        slot\    _timelines: [..] Slot\    _Timeline;
        bone\    _timelines: [..] Bone\    _Timeline;
        ik\      _timelines: [..] Ik\      _Timeline;
        transform_timelines: [..] Transform_Timeline;
        path\    _timelines: [..] Path\    _Timeline;
        deform\  _timelines: [..] Deform\  _Timeline;
        events: [..] Event;
        draw_order_timeline: Draw_Order_Timeline;
    }

    Slot_Timeline :: struct {
        slot_index: Slot_Index;

        timelines: [..] *Timeline;

        Timeline_Type :: enum u8 {
            ATTACHMENT :: 0;
            RGBA       :: 1;
            RGB        :: 2;
            RGBA2      :: 3;
            RGB2       :: 4;
            ALPHA      :: 5;
        }

        Timeline :: struct {
            type: Timeline_Type;
            frame_count: s32;
        }

        Attachment_Timeline :: struct {
            #as using _ : Timeline = .{ type = .ATTACHMENT };

            frames: [..] Frame;

            Frame :: struct {
                time: float64;
                name: String_Reference;
            }
        }

        Rgba_Timeline :: struct {
            #as using _ : Timeline = .{ type = .RGBA };
            #as using _ : Curve_Timeline(Frame);

            bezier_count: s32;

            Frame :: struct {
                #as using _ : Curve_Frame(4);
                r, g, b, a: u8;
            }
        }

        Rgb_Timeline :: struct {
            #as using _ : Timeline = .{ type = .RGB };
        }

        Rgba2_Timeline :: struct {
            #as using _ : Timeline = .{ type = .RGBA2 };
            #as using _ : Curve_Timeline(Frame);
            
            bezier_count: s32;
            
            Frame :: struct {
                #as using _ : Curve_Frame(4);
                r, g, b, a: u8;
                r2, g2, b2: u8;
            }
        }

        Rgb2_Timeline :: struct {
            #as using _ : Timeline = .{ type = .RGB2 };
        }

        Alpha_Timeline :: struct {
            #as using _ : Timeline = .{ type = .ALPHA };
        }
    }

    Bone_Timeline :: struct {
        bone_index: Bone_Index;

        timelines: [..] *Timeline;

        Timeline_Type :: enum u8 {
            ROTATE      :: 0;
            TRANSLATE   :: 1;
            TRANSLATE_X :: 2;
            TRANSLATE_Y :: 3;
            SCALE       :: 4;
            SCALE_X     :: 5;
            SCALE_Y     :: 6;
            SHEAR       :: 7;
            SHEAR_X     :: 8;
            SHEAR_Y     :: 9;
        }

        Timeline :: struct {
            type: Timeline_Type;
            frame_count: s32;
            bezier_count: s32;
        }

        // @todo Thats a bit bloated!

        Rotate_Timeline :: struct {
            #as using _ : Timeline = .{ type = .ROTATE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                rotation: float64;
            }
        }

        Translate_Timeline :: struct {
            #as using _ : Timeline = .{ type = .TRANSLATE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(2);
                x: float64;
                y: float64;
            }
        }

        Translate_X_Timeline :: struct {
            #as using _ : Timeline = .{ type = .TRANSLATE_X };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                x: float64;
            }
        }

        Translate_Y_Timeline :: struct {
            #as using _ : Timeline = .{ type = .TRANSLATE_Y };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                y: float64;
            }
        }

        Scale_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SCALE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(2);
                scale_x: float64;
                scale_y: float64;
            }
        }

        Scale_X_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SCALE_X };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                scale_x: float64;
            }
        }

        Scale_Y_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SCALE_Y };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                scale_y: float64;
            }
        }

        Shear_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SHEAR };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(2);
                shear_x: float64;
                shear_y: float64;
            }
        }

        Shear_X_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SHEAR_X };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                shear_x: float64;
            }
        }

        Shear_Y_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SHEAR_Y };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                shear_y: float64;
            }
        }
    }

    Ik_Timeline :: struct {
        #as using _ : Curve_Timeline(Frame);

        ik_constraint_index: Ik_Constraint_Index;
        frame_count: s32;
        bezier_count: s32;

        Frame :: struct {
            #as using _ : Curve_Frame(2);
            mix:            float64;
            softness:       float64;
            bend_direction: s8;
            compress:       bool;
            stretch:        bool;
        }
    }

    Transform_Timeline :: struct {
        #as using _ : Curve_Timeline(Frame);

        transform_constraint_index: Transform_Constraint_Index;
        frame_count: s32;
        bezier_count: s32;

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            rotate:  float64;
            mix\ _x: float64;
            mix\ _y: float64;
            scale_x: float64;
            scale_y: float64;
            shear_y: float64;
        }
    }

    Path_Timeline :: struct {
        path_constraint_index: Path_Constraint_Index;

        timelines: [..] *Timeline;

        Timeline :: struct {
            path_type: Path_Type;
            frame_count: s32;
            bezier_count: s32;
        }

        Position_Timeline :: struct {
            #as using _ : Timeline = .{ path_type = .POSITION };
            #as using _ : Curve_Timeline(Frame);
            
            Frame :: struct {
            	#as using _ : Curve_Frame(1);
            	position: float64;
            }
        }

        Spacing_Timeline :: struct {
            #as using _ : Timeline = .{ path_type = .SPACING };
            #as using _ : Curve_Timeline(Frame);
            
            Frame :: struct {
            	#as using _ : Curve_Frame(1);
            	spacing: float64;
            }
        }

        Mix_Timeline :: struct {
            #as using _ : Timeline = .{ path_type = .MIX };
            #as using _ : Curve_Timeline(Frame);
            
            Frame :: struct {
            	#as using _ : Curve_Frame(1);
            	rotate\  _mix: float64;
            	translate_mix: float64;
            }
        }
    }


    Deform_Timeline_Type :: enum u8 {
        DEFORM   :: 0;
        SEQUENCE :: 1;
    }

    Deform_Timeline :: struct {
        skin_index: Skin_Index;

        slot_timelines: [..] Slot_Timeline;

        Slot_Timeline :: struct {
            slot_index: Slot_Index;

            attachment_timelines: [..] *Attachment_Timeline;

            Attachment_Timeline :: struct {
                attachment_name: String_Reference;
                timeline_type: Deform_Timeline_Type;
                frame_count: s32;
            }

            Attachment_Deform_Timeline :: struct {
                #as using _ : Attachment_Timeline;
                #as using _ : Curve_Timeline(Frame);
                bezier_count: s32;

                Frame :: struct {
                    #as using _ : Curve_Frame(1);
                    deform_length: s32;
                    offset: s32;
                    deform: [..] float64;
                }
            }

            Attachment_Sequence_Timeline :: struct {
                #as using _ : Attachment_Timeline;
                
                frames: [..] Frame;

                Frame :: struct {
                	time: float64;
                	sequence_mode: Sequence_Mode;
                	index: s32;
                	delay: float64;
                }
            }
        }
    }

    Draw_Order_Timeline :: struct {
        frames: [..] Frame;

        Frame :: struct {
            time: float64;
            offsets: [..] Offset;

            Offset :: struct {
                slot_index: Slot_Index;
                offset: s32;
            }
        }
    }

    Curve_Type :: enum u8 {
        LINEAR  :: 0;
        STEPPED :: 1;
        BEZIER  :: 2;
    }

    Curve_Frame :: struct(N: int) {
        type: Curve_Type;
        time: float64;
        beziers: [N] Bezier_Data;
    }

    Curve_Timeline :: struct(T: Type) {
        frames: [..] T;
    }

    Bezier_Data :: struct {
        cx1: float64;
        cy1: float64;
        cx2: float64;
        cy2: float64;
    }

    Blend_Mode :: enum {
        NORMAL   :: 0;
        ADDITIVE :: 1;
        MULTIPLY :: 2;
        SCREEN   :: 3;
    }

    Bone_Type :: enum {
        ROTATE    :: 0;
        TRANSLATE :: 1;
        SCALE     :: 2;
        SHEAR     :: 3;
    }

    Transform_Mode :: enum {
        NORMAL                    :: 0;
        ONLY_TRANSLATION          :: 1;
        NO_ROTATION_OR_REFLECTION :: 2;
        NO_SCALE                  :: 3;
        NO_SCALE_OR_REFLECTION    :: 4;
    }

    Slot_Type :: enum {
        ATTACHMENT :: 0;
        COLOR      :: 1;
        TWO_COLOR  :: 2;
    }

    Path_Type :: enum {
        POSITION :: 0;
        SPACING  :: 1;
        MIX      :: 2;
    }

    Path_Position_Mode :: enum {
        FIXED   :: 0;
        PERCENT :: 1;
    }

    Path_Spacing_Mode :: enum {
        LENGTH  :: 0;
        FIXED   :: 1;
        PERCENT :: 2;
    }

    Path_Rotate_Mode :: enum {
        TANGENT     :: 0;
        CHAIN       :: 1;
        CHAIN_SCALE :: 2;
    }
    
    Sequence_Mode :: enum {
        HOLD :: 0;
        ONCE :: 1;
        LOOP :: 2;
        PING_PONG :: 3;
        ONCE_REVERSE :: 4;
        LOOP_REVERSE :: 5;
        PING_PONG_REVERSE :: 6;
    }

    find_slot :: (using skin: *Skin, slot_index: Slot_Index) -> *Slot {
        for * slots {
            if it.index == slot_index {
                return it;
            }
        }

        return null;
    }

	/*
    find_attachment :: (using slot: *Slot, attachment_name: string) -> *Attachment {
        for attachments {
            if it.name == attachment_name {
                return it;
            }
        }

        return null;
    }
    */
}
