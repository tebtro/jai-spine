Atlas_Format :: enum {
    Unknown :: 0;
    Alpha;
    Intensity;
    LuminanceAlpha;
    RGB565;
    RGBA4444;
    RGB888;
    RGBA8888;
}

Atlas_Filter :: enum {
    Unknown :: 0;
    Nearest;
    Linear;
    MipMap;
    MipMapNearestNearest;
    MipMapLinear\Nearest;
    MipMapNearestLinear;
    MipMapLinear\Linear;
}

Atlas_Wrap :: enum {
    MIRRORED_REPEAT;
    CLAMP_TO_EDGE;
    REPEAT;
}

Atlas :: struct {
    headers: [..] Atlas_Entry;
    pages:   [..] Atlas_Page;
}

Atlas_Entry :: struct {
    name: string;
    values: [] string;
}

Atlas_Page :: struct {
    name: string;
    format: Atlas_Format;
    min_filter: Atlas_Filter;
    mag_filter: Atlas_Filter;
    u_wrap: Atlas_Wrap;
    v_wrap: Atlas_Wrap;
    scale: float = 1;
    width:  int;
    height: int;
    pre_multiplied_alpha: bool;

    regions: [..] Atlas_Region;
}

Atlas_Region :: struct {
    name: string;
    index: int = -1;
    x: int;
    y: int;
    width:  int;
    height: int;
    offset_x: int;
    offset_y: int;
    original_width:  int;
    original_height: int;
    degrees: int;
    entries: [..] Atlas_Entry;
}

load_atlas :: (using atlas: * Atlas, data: string) -> bool #must {
    read_line :: (data: * string) -> string, bool {
        line, found := consume_next_line(data);
        if !found  return "", false;
        return trim(line), found;
    }

    read_entry :: (line: string) -> Atlas_Entry, bool {
        result: Atlas_Entry;
        if line.count == 0  return result, false;

        found, name, remaining := split_from_left(line, #char ":");
        if !found  return result, false;

        result.name = name;
        result.values = split(remaining, cast(u8) #char ",");

        for * result.values {
            it.* = trim(it.*);
        }

        return result, true;
    }

    // Ignore empty lines before first entry.
    line, found := read_line(* data);
    while found && line.count == 0 {
        line, found = read_line(* data);
    }

    // Header entries
    while true {
        if !found || line.count == 0  break;
        entry, found_entry := read_entry(line);

        if !found_entry  break;
        array_add(* headers, entry);

        line, found = read_line(* data);
    }

    // Pages and regions
    page: * Atlas_Page;

    while found {
        if line.count == 0 {
            page = null;
            line, found = read_line(* data);
            continue;
        }

        if !page {
            page = array_add(* pages);
            page.name = line;

            while true {
                line, found = read_line(* data);
                if !found || line.count == 0  break;

                entry, found_entry := read_entry(line);
                if !found_entry  break;

                if entry.name == {
                    case "scale";
                        page.scale = string_to_float(entry.values[0]);

                    case "size";
                        page.width  = string_to_int(entry.values[0]);
                        page.height = string_to_int(entry.values[1]);

                    case "format";
                        value, known := Reflection.enum_name_to_value(Atlas_Format, entry.values[0]);
                        page.format = ifx known then value else .Unknown;

                    case "filter";
                        value, known := Reflection.enum_name_to_value(Atlas_Filter, entry.values[0]);
                        page.min_filter = ifx known then value else .Unknown;

                        value, known  = Reflection.enum_name_to_value(Atlas_Filter, entry.values[1]);
                        page.mag_filter = ifx known then value else .Unknown;

                    case "repeat";
                        page.u_wrap = ifx find_index_from_left(entry.values[0], "x") >= 0 then .REPEAT else .CLAMP_TO_EDGE;
                        page.u_wrap = ifx find_index_from_left(entry.values[0], "y") >= 0 then .REPEAT else .CLAMP_TO_EDGE;

                    case "pma";
                        page.pre_multiplied_alpha = equal(entry.values[0], "true");
                }
            }
        } else {
            region := array_add(* page.regions);
            region.name = line;

            while true {
                line, found = read_line(* data);
                if !found || line.count == 0  break;

                entry, found_entry := read_entry(line);
                if !found_entry  break;

                if entry.name == {
                    case "index";
                        region.index = string_to_int(entry.values[0]);

                    case "xy";
                        region.x = string_to_int(entry.values[0]);
                        region.y = string_to_int(entry.values[1]);

                    case "size";
                        region.width  = string_to_int(entry.values[0]);
                        region.height = string_to_int(entry.values[1]);

                    case "bounds";
                        region.x      = string_to_int(entry.values[0]);
                        region.y      = string_to_int(entry.values[1]);
                        region.width  = string_to_int(entry.values[2]);
                        region.height = string_to_int(entry.values[3]);

                    case "offset";
                        region.offset_x = string_to_int(entry.values[0]);
                        region.offset_y = string_to_int(entry.values[1]);

                    case "orig";
                        region.original_width  = string_to_int(entry.values[0]);
                        region.original_height = string_to_int(entry.values[1]);

                    case "offsets";
                        region.offset_x        = string_to_int(entry.values[0]);
                        region.offset_y        = string_to_int(entry.values[1]);
                        region.original_width  = string_to_int(entry.values[2]);
                        region.original_height = string_to_int(entry.values[3]);

                    case "rotate";
                        if entry.values[0] == {
                            case "false";

                            case "true";
                                region.degrees = 90;

                            case;
                                region.degrees = string_to_int(entry.values[0]);
                        }

                    case;
                        array_add(* region.entries, entry);
                }
            }

            if region.original_width == 0 && region.original_height == 0 {
                region.original_width  = region.width;
                region.original_height = region.height;
            }
        }
    }

    return true;
}

write_atlas :: (using atlas: * Atlas) -> string {
    builder: String_Builder;
    init_string_builder(*builder);
    defer reset(*builder);

    write_entries :: (builder: * String_Builder, entries: [] Atlas_Entry) {
        for entries {
            append(builder, "\t");
            append(builder, it.name);
            append(builder, ":");
            for it.values {
                if it_index > 0  append(builder, ",");
                append(builder, " ");
                append(builder, it);
            }
            append(builder, "\n");
        }
    }

    write_entries(*builder, headers);

    for pages {
        using it;

        append(*builder, "\n");

        print_to_builder(*builder, "%\n", name);

        if width != 0 || height != 0 {
            print_to_builder(*builder, "\tsize: %, %\n", width, height);
        }

        if format != .Unknown {
            print_to_builder(*builder, "\tformat: %\n", format);
        }

        if min_filter != .Unknown || mag_filter != .Unknown {
            print_to_builder(*builder, "\tfilter: %, %\n", min_filter, mag_filter);
        }

        if u_wrap != .MIRRORED_REPEAT || v_wrap != .MIRRORED_REPEAT {
            append(*builder, "\trepeat: clamp");
            if u_wrap == .REPEAT  append(*builder, "x");
            if v_wrap == .REPEAT  append(*builder, "y");
            append(*builder, "\n");
        }

        if scale != 1 {
            print_to_builder(*builder, "\tscale: %\n", scale);
        }

        if pre_multiplied_alpha {
            append(*builder, "\tpma: true\n");
        }

        for regions {
            using it;

            print_to_builder(*builder, "%\n", name);

            if index >= 0 {
                print_to_builder(*builder, "\tindex: %\n", index);
            }

            if x > 0 || y > 0 || width > 0 || height > 0 {
                print_to_builder(*builder, "\tbounds: %, %, %, %\n", x, y, width, height);
            }

            if offset_x > 0 || offset_y > 0 || original_width != width || original_height != height {
                print_to_builder(*builder, "\toffsets: %, %, %, %\n", offset_x, offset_y, original_width, original_height);
            }

            if degrees != 0 {
                print_to_builder(*builder, "\trotation: %\n", degrees);
            }

            write_entries(*builder, entries);
        }
    }

    return builder_to_string(*builder);
}

#import "Basic";
#import "String";
#import "Text_File_Handler";
Reflection :: #import "Reflection";