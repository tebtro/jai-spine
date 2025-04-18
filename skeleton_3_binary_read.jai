Skeleton_3_Binary_Read :: struct {
	using Skeleton_3;

    load :: (data: string, scale: float32, spine_version: Spine_Version) -> *Skeleton_Data {
        s := *data;

        using skeleton := New(Skeleton_Data);

        hash    = read_string(s);
        version = read_string(s);

        x = read_f32(s);
        y = read_f32(s);
        width  = read_f32(s);
        height = read_f32(s);

        if read_bool(s) {
            fps = read_f32(s);
            image_path = read_string(s);
            audio_path = read_string(s);
        }

        print("TODO: 38\n");
        return skeleton;
    }
}


#import "Basic";
