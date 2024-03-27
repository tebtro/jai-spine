Skeleton_Data :: struct {
    #as using base: Base_Skeleton_Data;

    hash: string;
    version: string;

    x: float32;
    y: float32;
    width: float32;
    height: float32;

    fps: float32;
    image_path: string;
    audio_path: string;
}

#import,file "skeleton.jai";