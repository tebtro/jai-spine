builder_write_number :: inline (builder: * String_Builder, value: T, $T: Type) #modify {
    return IsScalar(T);
}{
    size :: size_of(T);

    ensure_contiguous_space(builder, size);

    #if IS_LITTLE_ENDIAN {
        simple_memcpy(builder, value);
    } else {
        bytes := [] u8.{ data = cast(* u8) *value, count = size };
        for < bytes {
            append(builder, it);
        }
    }
}

write_u8  :: #bake_arguments builder_write_number(T = u8);
write_u16 :: #bake_arguments builder_write_number(T = u16);
write_u32 :: #bake_arguments builder_write_number(T = u32);
write_u64 :: #bake_arguments builder_write_number(T = u64);

write_s8  :: #bake_arguments builder_write_number(T = s8);
write_s16 :: #bake_arguments builder_write_number(T = s16);
write_s32 :: #bake_arguments builder_write_number(T = s32);
write_s64 :: #bake_arguments builder_write_number(T = s64);

write_bool :: (builder: * String_Builder, value: bool) {
    write_u8(builder, ifx value then 1 else 0);
}

write_f32 :: (builder: * String_Builder, value: float32) {
    union {
        value_f32: float32;
        value_u32: u32;
    }

   value_f32 = value;
   write_u32(builder, value_u32);
}

write_var_s32 :: (builder: * String_Builder, value: s32, optimize_positive: bool) {
    union {
        value_s: s32;
        value_u: u32;
    }

    value_s = value;

    if !optimize_positive {
        union {
            temp2_s: s32;
            temp2_u: u32;
        }

        temp1 := value_u << 1;
        temp2_s = value_s >> 31;
        value_u = temp1 ^ temp2_u;
    }

    while true {
        b := cast(u8) value_u & 0x7F;
        if value_u > 0x7F  b |= 0x80;
        write_u8(builder, b);
        if value_u > 0x7F {
            value_u >>= 7;
        } else {
            break;
        }
    }
}

write_string :: (builder: * String_Builder, data: string) {
    count := cast(s32) data.count + 1;
    write_var_s32(builder, count, true);
    if count > 1 {
        append(builder, data.data, count - 1);
    }
}

write_string_reference :: (builder: * String_Builder, shared_strings: [] string, data: string) {
    found, i := array_find(shared_strings, data);
    index := ifx found then (i + 1) else 0;
    write_var_s32(builder, xx index, true);
}

write_color :: write_u32;

write_var_s32_array :: (builder: * String_Builder, array: [] s32) {
    write_var_s32(builder, xx array.count, true);
    for array {
        write_var_s32(builder, it, true);
    }
}

write_s16_array :: (builder: * String_Builder, array: [] s16) {
    write_var_s32(builder, xx array.count, true);
    for array {
        write_s16(builder, it);
    }
}

write_f32_array :: (builder: * String_Builder, array: [] float32) {
    write_var_s32(builder, xx array.count, true);
    for array {
        write_f32(builder, it);
    }
}


#import "Basic";
#import "Memory";
#import "Bit_Operations";


#scope_file


IS_LITTLE_ENDIAN :: false;

is_little_endian :: () -> bool {
    return !is_big_endian();
}

is_big_endian :: () -> bool {
    union {
        value: u32;
        array: [4] u8;
    }

    value = 0x01020304;

    return array[0] == 1;
}
