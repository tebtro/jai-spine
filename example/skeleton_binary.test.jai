main :: () {
    data, success := read_entire_file("spineboy/export/spineboy-pro.skel");
    if !success {
        print("Could not open file!\n");
        return;
    }

    skeleton: Skeleton_Data;
    success = load_skeleton_binary(*skeleton, data);
    if !success {
        print("Error while loading skeleton file!\n");
        return;
    }

    print("Skeleton: %\n", skeleton.animations);

    /*
    for atlas.pages {
        for * it.regions {
            it.name = tprint("path/%", it.name);
        }
    }
    */

    new_data := write_skeleton_binary(*skeleton);
    write_entire_file("output.skel", new_data);
}

#load "../skeleton_binary.jai";

#import "Basic";
#import "File";