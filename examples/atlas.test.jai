main :: () {
    print("Hello Sailor!\n");
    data, success := read_entire_file("input.atlas");
    if !success {
        print("Could not open file!\n");
        return;
    }

    atlas: Atlas;
    success = load_atlas(*atlas, data);
    if !success {
        print("Error while loading atlas file!\n");
        return;
    }

    for atlas.pages {
        for * it.regions {
            it.name = tprint("path/%", it.name);
        }
    }

    new_data := write_atlas(*atlas);
    write_entire_file("output.atlas", new_data);
}

#load "../atlas.jai";

#import "Basic";
#import "File";