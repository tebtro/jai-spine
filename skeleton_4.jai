Skeleton_Data :: struct {
    #as using base: Base_Skeleton_Data = .{
        loader_version = .Version41,
    };

    hash_low:  u32;
    hash_high: u32;

    version: string;

    x:      float32;
    y:      float32;
    width:  float32;
    height: float32;

    non_essential: bool;

    fps: float32;
    image_path: string;
    audio_path: string;

    shared_strings: [..] String_Reference;

    bones: [..] Bone_Data;
    slots: [..] Slot_Data;
    ik_constraints: [..] Ik_Constraint;
    transform_constraints: [..] Transform_Constraint;
    path_constraints: [..] Path_Constraint;

    default_skin: * Skin;
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
    name: string;
    parent: Bone_Index;
    rotation: float32;
    x: float32;
    y: float32;
    scale_x: float32;
    scale_y: float32;
    shear_x: float32;
    shear_y: float32;
    length: float32;
    transform_mode: Transform_Mode;
    skin_required: bool;
    color: Color;
}

Slot_Data :: struct {
    name: string;
    bone: Bone_Index;
    color: Color;
    dark_color: Color;
    attachment_name: String_Reference;
    blend_mode: Blend_Mode;
}

Ik_Constraint :: struct {
    name: string;
    order: s32;
    skin_required: bool;
    bones: [..] Bone_Index;
    target: Bone_Index;
    mix: float32;
    softness: float32;
    bend_direction: s8;
    compress: bool;
    stretch: bool;
    uniform: bool;
}

Transform_Constraint :: struct {
    name: string;
    order: s32;
    skin_required: bool;
    bones: [..] Bone_Index;
    target: Bone_Index;
    local: bool;
    relative: bool;
    offset_rotation: float32;
    offset_x: float32;
    offset_y: float32;
    offset_scale_x: float32;
    offset_scale_y: float32;
    offset_shear_y: float32;
    mix_rotate: float32;
    mix_x: float32;
    mix_y: float32;
    mix_scale_x: float32;
    mix_scale_y: float32;
    mix_shear_y: float32;
}

Path_Constraint :: struct {
    name: string;
    order: s32;
    skin_required: bool;
    bones: [..] Bone_Index;
    target: Bone_Index;
    position_mode: Path_Position_Mode;
    spacing_mode:  Path_Spacing_Mode;
    rotate_mode:   Path_Rotate_Mode;
    offset_rotation: float32;
    position: float32;
    spacing: float32;
    mix_rotate: float32;
    mix_x: float32;
    mix_y: float32;
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
    attachments: [..] * Attachment;
}

Attachment :: struct {
    name: String_Reference;
    type: Attachment_Type;
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
    rotation: float32;
    x: float32;
    y: float32;
    scale_x: float32;
    scale_y: float32;
    width: float32;
    height: float32;
    color: Color;
    sequence: * Sequence;
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
    vertices: Vertices;
    triangles: [..] s16;
    region_uvs: [..] float32;
    hull_length: s32;
    sequence: * Sequence;
    edges: [..] s16;
    width: float32;
    height: float32;
}

Attachment_Linked_Mesh :: struct {
    #as using _: Attachment = .{ type = .LINKED_MESH };
    path: String_Reference;
    color: Color;
    skin_name: String_Reference;
    parent: String_Reference;
    inherit_timelines: bool;
    sequence: * Sequence;
    width:  float32;
    height: float32;
}

Attachment_Path :: struct {
    #as using _: Attachment = .{ type = .PATH };
    closed: bool;
    constant_speed: bool;
    vertices: Vertices;
    lengths: [..] float32;
    color: Color;
}

Attachment_Point :: struct {
    #as using _: Attachment = .{ type = .POINT };
    rotation: float32;
    x: float32;
    y: float32;
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
    vertices: [..] float32;
    bones: [..] [..] Bone_Index;
}

Event_Data :: struct {
    name:         String_Reference;
    value_int:    s32;
    value_float:  float32;
    value_string: string;
    audio_path:   string;
    volume:       float32;
    balance:      float32;
}

Event :: struct {
    time:         float32;
    event_index:  Event_Index;
    value_int:    s32;
    value_float:  float32;
    value_string: string;
    volume:       float32;
    balance:      float32;
}

Animation_Data :: struct {
    name: string;
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

    timelines: [..] * Timeline;

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
    }

    Attachment_Timeline :: struct {
        #as using _ : Timeline = .{ type = .ATTACHMENT };

        frames: [..] Frame;

        Frame :: struct {
            time: float32;
            name: String_Reference;
        }
    }

    Rgba_Timeline :: struct {
        #as using _ : Timeline = .{ type = .RGBA };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(4);
            r: float32;
            g: float32;
            b: float32;
            a: float32;
        }
    }

    Rgb_Timline :: struct {
        #as using _ : Timeline = .{ type = .RGB };
    }

    Rgba2_Timline :: struct {
        #as using _ : Timeline = .{ type = .RGBA2 };
    }

    Rgb2_Timline :: struct {
        #as using _ : Timeline = .{ type = .RGB2 };
    }

    Alpha_Timline :: struct {
        #as using _ : Timeline = .{ type = .ALPHA };
    }
}

Bone_Timeline :: struct {
    bone_index: Bone_Index;

    timelines: [..] * Timeline;

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
    }

    // @todo Thats a bit bloated!

    Rotate_Timeline :: struct {
        #as using _ : Timeline = .{ type = .ROTATE };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            rotation: float32;
        }
    }

    Translate_Timeline :: struct {
        #as using _ : Timeline = .{ type = .TRANSLATE };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(2);
            x: float32;
            y: float32;
        }
    }

    Translate_X_Timeline :: struct {
        #as using _ : Timeline = .{ type = .TRANSLATE_X };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            x: float32;
        }
    }

    Translate_Y_Timeline :: struct {
        #as using _ : Timeline = .{ type = .TRANSLATE_Y };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            y: float32;
        }
    }

    Scale_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SCALE };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(2);
            scale_x: float32;
            scale_y: float32;
        }
    }

    Scale_X_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SCALE_X };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            scale_x: float32;
        }
    }

    Scale_Y_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SCALE_Y };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            scale_y: float32;
        }
    }

    Shear_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SHEAR };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(2);
            shear_x: float32;
            shear_y: float32;
        }
    }

    Shear_X_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SHEAR_X };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            shear_x: float32;
        }
    }

    Shear_Y_Timeline :: struct {
        #as using _ : Timeline = .{ type = .SHEAR_Y };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            shear_y: float32;
        }
    }
}

Ik_Timeline :: struct {
    #as using _ : Curve_Timeline(Frame);

    ik_constraint_index: Ik_Constraint_Index;

    Frame :: struct {
        #as using _ : Curve_Frame(2);
        mix:            float32;
        softness:       float32;
        bend_direction: s8;
        compress:       bool;
        stretch:        bool;
    }
}

Transform_Timeline :: struct {
    #as using _ : Curve_Timeline(Frame);

    transform_constraint_index: Transform_Constraint_Index;

    Frame :: struct {
        #as using _ : Curve_Frame(1);
        rotate:  float32;
        mix\ _x: float32;
        mix\ _y: float32;
        scale_x: float32;
        scale_y: float32;
        shear_y: float32;
    }
}

Path_Timeline :: struct {
    path_constraint_index: Path_Constraint_Index;

    timelines: [..] * Timeline;

    Timeline :: struct {
        path_type: Path_Type;
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

        attachment_timelines: [..] Attachment_Timeline;

        Attachment_Timeline :: struct {
            #as using _ : Curve_Timeline(Frame);

            attachment_name: String_Reference;

            timeline_type: Deform_Timeline_Type;

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                offset: s32;
                deform: [..] float32;
            }
        }
    }
}

Draw_Order_Timeline :: struct {
    frames: [..] Frame;

    Frame :: struct {
        time: float32;
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
    time: float32;
    beziers: [N] Bezier_Data;
}

Curve_Timeline :: struct(T: Type) {
    frames: [..] T;
}

Bezier_Data :: struct {
    cx1: float32;
    cy1: float32;
    cx2: float32;
    cy2: float32;
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

find_slot :: (using skin: * Skin, slot_index: Slot_Index) -> * Slot {
    for * slots {
        if it.index == slot_index {
            return it;
        }
    }

    return null;
}

find_attachment :: (using slot: * Slot, attachment_name: string) -> * Attachment {
    for attachments {
        if it.name == attachment_name {
            return it;
        }
    }

    return null;
}

#import,file "binary.jai";
#import,file "skeleton.jai";