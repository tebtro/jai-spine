Skeleton_Data :: struct {
    hash:    string;
    version: string;

    x:      float32;
    y:      float32;
    width:  float32;
    height: float32;

    fps: float32;
    image_path: string;
    audio_path: string;

    shared_strings: [..] string;

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

Bone_Index :: s32;
Slot_Index :: s32;

Ik\      _Constraint_Index :: s32;
Transform_Constraint_Index :: s32;
Path\    _Constraint_Index :: s32;

Color :: [4] float32;

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
    attachment_name: string;
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
    name: string;
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
    name: string;
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
    path: string;
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
    path: string;
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
    path: string;
    color: Color;
    sequence: * Sequence;
    width: float32;
    height: float32;
    inherit_timelines: bool;
}

Attachment_Path :: struct {
    #as using _: Attachment = .{ type = .PATH };
    path: string;
    closed: bool;
    constant_speed: bool;
    vertices: Vertices;
    lengths: [..] float32;
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
    name:         string;
    value_int:    s32;
    value_float:  float32;
    value_string: string;
    audio_path:   string;
    volume:       float32;
    balance:      float32;
}

Animation_Data :: struct {
    name: string;
    slot\    _timelines: [..] Slot\    _Timeline;
    bone\    _timelines: [..] Bone\    _Timeline;
    ik\      _timelines: [..] Ik\      _Timeline;
    transform_timelines: [..] Transform_Timeline;
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
            name: string;
        }
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

    Rotate_Timeline :: struct {
        #as using _ : Timeline = .{ type = .ROTATE };
        #as using _ : Curve_Timeline(Frame);

        Frame :: struct {
            #as using _ : Curve_Frame;
            rotation: float32;
        }
    }
}

Ik_Timeline :: struct {
    #as using _ : Curve_Timeline(Frame);

    ik_constraint_index: Ik_Constraint_Index;

    Frame :: struct {
        #as using _ : Curve_Frame;
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
        #as using _ : Curve_Frame;
        rotate: float32;
        mix_x: float32;
        mix_y: float32;
        scale_x: float32;
        scale_y: float32;
        shear_y: float32;
    }
}

Curve_Type :: enum u8 {
    LINEAR  :: 0;
    STEPPED :: 1;
    BEZIER  :: 2;
}

Curve_Frame :: struct {
    type: Curve_Type;
    time: float32;
}

Curve_Timeline :: struct(T: Type) {
    frames: [..] T;
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