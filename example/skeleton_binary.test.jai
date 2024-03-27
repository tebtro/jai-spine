main :: () {
    test_serialization();

    files :: string.[
        "stretchyman/export/stretchyman-pro.skel",
        "chibi-stickers/export/chibi-stickers.skel",
        "spineboy/export/spineboy-ess.skel",
        "spineboy/export/spineboy-pro.skel",
    ];

    for files  test_skeleton(it);
}

test_skeleton :: (path: string) {
    data, success := read_entire_file(path);
    if !success {
        log("Could not open file!\n");
        return;
    }

    skeleton := load_skeleton_binary(data);
    if !skeleton {
        log("Error while loading skeleton file!\n");
        return;
    }

    //log("Skeleton: %\n", skeleton);

    new_data := write_skeleton_binary(skeleton);
    //write_entire_file("output.skel", new_data);

    if data != new_data {
        log("ERROR: New data differs from old data!");
    }
}

test_serialization :: () {
    u8s: [] u8 = .[ 0, 1, U8_MAX, U8_MAX/3 ];
    s32s: [] s32 = .[ -1, 0, 1, S32_MIN, S32_MAX, S32_MIN/3, S32_MAX/3 ];
    f32s: [] float32 = .[ -1, 0, 1, FLOAT32_MIN, FLOAT32_MAX, FLOAT32_INFINITY ];
    strings: [] string = .[ .{}, "", "same", "Hello Sailor!", "same" ];
    colors: [] Color = .[ 0x00000000, 0x7f7f7f7f, 0xffffffff ];
    s32_arrays: [][] s32     = .[ .[], .[ 123 ], .[ 1, 2, 3 ] ];
    s16_arrays: [][] s16     = .[ .[], .[ 123 ], .[ 1, 2, 3 ] ];
    f32_arrays: [][] float32 = .[ .[], .[ 123 ], .[ 1, 2, 3 ] ];

    shared_strings: [..] string;
    for strings  array_add_if_unique(*shared_strings, it);

    builder: String_Builder;
    for u8s         write_u8(*builder, it);
    for s32s        write_s32(*builder, it);
    for f32s        write_f32(*builder, it);
    for s32s        write_var_s32(*builder, it, true);
    for s32s        write_var_s32(*builder, it, false);
    for strings     write_string(*builder, it);
    for strings     write_string_reference(*builder, shared_strings, it);
    for colors      write_color(*builder, it);
    for s32_arrays  write_var_s32_array(*builder, it);
    for s16_arrays  write_s16_array(*builder, it);
    for f32_arrays  write_f32_array(*builder, it);
    data := builder_to_string(*builder);

    for u8s         assert(it == read_u8(*data));
    for s32s        assert(it == read_s32(*data));
    for f32s        assert(it == read_f32(*data));
    for s32s        assert(it == read_var_s32(*data, true));
    for s32s        assert(it == read_var_s32(*data, false));
    for strings     assert(it == read_string(*data));
    for strings     assert(it == read_string_reference(*data, shared_strings));
    for colors      assert(it == read_color(*data));
    for s32_arrays  assert(compare(it, read_var_s32_array(*data)));
    for s16_arrays  assert(compare(it, read_s16_array(*data)));
    for f32_arrays  assert(compare(it, read_f32_array(*data)));
}

compare :: (a: [] $T, b: [] T) -> bool {
    if a.count != b.count  return false;
    for a {
        if it != b[it_index]  return false;
    }
    return true;
}

#load "../skeleton_binary_read.jai";
#load "../skeleton_binary_write.jai";

#import "Basic";
#import "File";
#import "Math";