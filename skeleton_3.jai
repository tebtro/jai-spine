Skeleton_3 :: struct {
    Skeleton_Data :: struct {
        #as using base: Base_Skeleton_Data;

        hash:    Optional(string);
        version: Optional(string);

        x: float64;
        y: float64;
        width:  float64;
        height: float64;
        
        non_essential: bool;

        fps: float64;
        images_path: Optional(string);
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
        parent_name: Optional(string);
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
        bone_name: Optional(string);
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
        rotate_mix: float64;
        translate_mix: float64;
        scale_mix: float64;
        shear_mix: float64;
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
        rotate_mix: float64;
        translate_mix: float64;
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
        inherit_deform: bool;
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
        slot\    _timelines: [..] Slot\    _Timeline;
        bone\    _timelines: [..] Bone\    _Timeline;
        ik\      _timelines: [..] Ik\      _Timeline;
        transform_timelines: [..] Transform_Timeline;
        path\    _timelines: [..] Path\    _Timeline;
        deform\  _timelines: [..] Deform\  _Timeline;
        draw_order_timeline: Draw_Order_Timeline;
        events: [..] Event;
    }

    Slot_Timeline :: struct {
        slot_index: Slot_Index;

        timelines: [..] *Timeline;

        Timeline_Type :: enum u8 {
            ATTACHMENT :: 0;
            COLOR      :: 1;
            TWO_COLOR  :: 2;
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

        Color_Timeline :: struct {
            #as using _ : Timeline = .{ type = .COLOR };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                color: Color;
            }
        }

        Two_Color_Timeline :: struct {
            #as using _ : Timeline = .{ type = .TWO_COLOR };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                light: Color;
                dark: Color;
            }
        }
    }

    Bone_Timeline :: struct {
        bone_index: Bone_Index;

        timelines: [..] *Timeline;

        Timeline_Type :: enum u8 {
            ROTATE      :: 0;
            TRANSLATE   :: 1;
            SCALE       :: 2;
            SHEAR       :: 3;
        }

        Timeline :: struct {
            type: Timeline_Type;
            frame_count: s32;
        }

        // @todo Thats a bit bloated!

        Rotate_Timeline :: struct {
            #as using _ : Timeline = .{ type = .ROTATE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                angle: float64;
            }
        }

        Translate_Timeline :: struct {
            #as using _ : Timeline = .{ type = .TRANSLATE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                x: float64;
                y: float64;
            }
        }

        Scale_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SCALE };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                scale_x: float64;
                scale_y: float64;
            }
        }

        Shear_Timeline :: struct {
            #as using _ : Timeline = .{ type = .SHEAR };
            #as using _ : Curve_Timeline(Frame);

            Frame :: struct {
                #as using _ : Curve_Frame(1);
                shear_x: float64;
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

        Frame :: struct {
            #as using _ : Curve_Frame(1);
            rotate_mix:    float64;
            translate_mix: float64;
            scale_mix:     float64;
            shear_mix:     float64;
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

    Deform_Timeline :: struct {
        skin_index: Skin_Index;

        slot_timelines: [..] Slot_Timeline;

        Slot_Timeline :: struct {
            slot_index: Slot_Index;

            attachment_timelines: [..] Attachment_Timeline;

            Attachment_Timeline :: struct {
                #as using _ : Curve_Timeline(Frame);
                
                attachment_name: String_Reference;
                
                frame_count: s32;
                
                Frame :: struct {
                    #as using _ : Curve_Frame(1);
                    offset: s32;
                    vertices: [..] float64;
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
        ADD      :: 1;
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
    
    find_bone_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Bone_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_bone_index(skeleton, name.value);
    }
    find_bone_index :: (using skeleton: *Skeleton_Data, name: string) -> Bone_Index {
    
    	for bones {
    		if it.name.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }
    
    find_ik_constraint_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Ik_Constraint_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_ik_constraint_index(skeleton, name.value);
    }
    find_ik_constraint_index :: (using skeleton: *Skeleton_Data, name: string) -> Ik_Constraint_Index {
    
    	for ik_constraints {
    		if it.name.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }
    
    find_transform_constraint_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Transform_Constraint_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_transform_constraint_index(skeleton, name.value);
    }
    find_transform_constraint_index :: (using skeleton: *Skeleton_Data, name: string) -> Transform_Constraint_Index {
    
    	for transform_constraints {
    		if it.name.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }
    
    find_path_constraint_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Path_Constraint_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_path_constraint_index(skeleton, name.value);
    }
    find_path_constraint_index :: (using skeleton: *Skeleton_Data, name: string) -> Path_Constraint_Index {
    
    	for path_constraints {
    		if it.name.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }
    
    find_skin_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Skin_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_skin_index(skeleton, name.value);
    }
    find_skin_index :: (using skeleton: *Skeleton_Data, name: string) -> Skin_Index {
    	for *skins {
    		if !it.name.data.has_value  continue;
    		
    		if it.name.data.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }

    find_slot_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Slot_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_slot_index(skeleton, name.value);
    }
    find_slot_index :: (using skeleton: *Skeleton_Data, name: string) -> Slot_Index {
        for * slots {
        	if !it.name.has_value  continue;
        
            if it.name.value == name {
                return xx it_index;
            }
        }

        return -1;
    }
    
    find_event_index :: (using skeleton: *Skeleton_Data, name: Optional(string)) -> Event_Index {
    	if !name.has_value {
    		return -1;
    	}
    	
    	return find_event_index(skeleton, name.value);
    }
    find_event_index :: (using skeleton: *Skeleton_Data, name: string) -> Event_Index {
    	for *events {
    		if !it.name.data.has_value  continue;
    		
    		if it.name.data.value == name {
    			return xx it_index;
    		}
    	}
    	
    	return -1;
    }
}

