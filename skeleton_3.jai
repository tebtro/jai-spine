Skeleton_3 :: struct {
    Skeleton_Data :: struct {
        #as using base: Base_Skeleton_Data;

        hash:    Optional(string);
        version: Optional(string);

        x: float32;
        y: float32;
        width:  float32;
        height: float32;

        fps: float32;
        image_path: Optional(string);
        audio_path: Optional(string);
    }
}

