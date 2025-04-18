read_number :: inline (s: *string, $T: Type) -> T #modify {
    return IsScalar(T);
}{
    size :: size_of(T);

    assert(s.count >= size);

    result := (cast(*T) s.data).*;

    #if size > 1 && !IS_LITTLE_ENDIAN {  // Spine writes it's data as big endian!
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

read_f32 :: #bake_arguments read_number(T = float32);
read_f64 :: #bake_arguments read_number(T = float64);

read_bool :: (data: *string) -> bool {
    return read_u8(data) == 1;
}

read_var_s32 :: (data: *string, optimize_positive: bool) -> s32 {
    union {
        value_s: s32;
        value_u: u32;
    }

    b := read_u8(data);
    value_u = b & 0x7F;
    if b & 0x80 {
        b = read_u8(data);
        value_u |= (cast(u32) b & 0x7F) << 7;
        if b & 0x80 {
            b = read_u8(data);
            value_u |= (cast(u32) b & 0x7F) << 14;
            if b & 0x80 {
                b = read_u8(data);
                value_u |= (cast(u32) b & 0x7F) << 21;
                if b & 0x80 {
                    b = read_u8(data);
                    value_u |= (cast(u32) b & 0x7F) << 28;
                }
            }
        }
    }

    if !optimize_positive {
        union {
            temp2_s: s32;
            temp2_u: u32;
        }

        temp1 := value_u >> 1;
        temp2_s = -(value_s & 1);

        value_u = temp1 ^ temp2_u;
    }

    return value_s;
}

read_string :: (data: *string) -> Optional(string) {
    count := read_var_s32(data, true);
    if count <= 0 || count-1 > data.count  return .{};
    else if count == 1  return create_optional("");

    count -= 1;

    result := string.{ count, data.data };
    advance(data, count);
    return create_optional(result);
}

read_string_reference :: (data: *string, shared_strings: [] String_Reference) -> String_Reference {
    index := read_var_s32(data, true);
    if index > 0 {
        return shared_strings[index - 1];
    } else {
        return .{
            original_index = index,
            data = create_optional(""),
        };
    }
}

read_color :: read_u32;

read_string_array :: (s: *string) -> [..] Optional(string) {
    result: [..] Optional(string);
    read_string_array(s, *result);
    return result;
}

read_string_array :: (s: *string, array: *[..] Optional(string)) {
    count := read_var_s32(s, true);
    array_reserve(array, count);
    for 0..count-1 {
        array_add(array, read_string(s));
    }
}

read_string_reference_array :: (s: *string) -> [..] String_Reference {
    result: [..] String_Reference;
    read_string_reference_array(s, *result);
    return result;
}

read_string_reference_array :: (s: *string, array: *[..] String_Reference) {
    count := read_var_s32(s, true);
    array_reserve(array, count);
    for 0..count-1 {
        reference := array_add(array);
        reference.original_index = it + 1;
        reference.data = read_string(s);
    }
}

read_var_s32_array :: (s: *string) -> [..] s32 {
    result: [..] s32;
    read_var_s32_array(s, *result);
    return result;
}

read_var_s32_array :: (s: *string, array: *[..] s32) {
    count := read_var_s32(s, true);
    array_reserve(array, count);
    for 0..count-1 {
        array_add(array, read_var_s32(s, true));
    }
}

read_s16_array :: (s: *string) -> [..] s16 {
    result: [..] s16;
    count := read_var_s32(s, true);
    array_reserve(*result, count);
    for 0..count-1 {
        array_add(*result, read_s16(s));
    }
    return result;
}

read_f32_array :: (s: *string, scale: float32 = 1) -> [..] float32 {
    result: [..] float32;
    count := read_var_s32(s, true);
    return read_f32_array(s, count, scale);
}

read_f32_array :: (s: *string, count: s32, scale: float32 = 1) -> [..] float32 {
    result: [..] float32;
    read_f32_array(*result, s, count, scale);
    return result;
}

read_f32_array :: (result: *[..] float32, s: *string, count: s32, scale: float32 = 1) {
    array_reserve(result, count);
    if scale == 1 {
        for 0..count-1 {
            array_add(result, read_f32(s));
        }
    } else {
        for 0..count-1 {
            array_add(result, read_f32(s) *scale);
        }
    }
}


#import "Basic";
#import "String";
#import "Bit_Operations";


#scope_file


IS_LITTLE_ENDIAN :: false;
