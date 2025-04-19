Json_Read :: struct {
    has :: (json_val: JSON_Value, key: string) -> bool {
        if json_val.type == .OBJECT {
            return Hash_Table.table_contains(json_val.object, key);
        } else {
            assert(false);
            return false;
        }
    }

    get :: (json_val: JSON_Value, key: string, expected_type: JSON_Type) -> JSON_Value {
        assert(json_val.type == .OBJECT);
        table := json_val.object;
        val, success := Hash_Table.table_find(table, key);
        assert(success);
        assert(val.type == expected_type);
        return val;
    }

    get_bool :: (json_value: JSON_Value, key: string, default: bool) -> bool {
        if has(json_value, key) {
            return get(json_value, key, .BOOLEAN).boolean;
        }
	
        return default;
    }

    get_string :: (json_value: JSON_Value, key: string, default: string) -> string {
        if has(json_value, key) {
            return get(json_value, key, .STRING).str;
        }
	
        return default;
    }

    get_optional_string :: (json_value: JSON_Value, key: string) -> Optional(string) {
        assert(json_value.type == .OBJECT);
        table := json_value.object;
        value, success := Hash_Table.table_find(table, key);
        if success {
            assert(value.type == .STRING);
            return .{
                has_value = success,
                value = value.str,
            };
        } else {
            return .{};
        }
    }

    get_number :: (json_value: JSON_Value, key: string) -> float64 {
        return get(json_value, key, .NUMBER).number;
    }

    get_number :: (json_value: JSON_Value, key: string, default: float64) -> float64 {
        if has(json_value, key) {
            return get(json_value, key, .NUMBER).number;
        }
	
        return default;
    }

    get_color :: (json_value: JSON_Value, key: string, default: Color) -> (success: bool, color: Color) {
        if has(json_value, key) {
            color_string := get(json_value, key, .STRING).str;
            color, success := string_to_int(color_string, base=16);
            if !success {
                log_error("Could not parse color: '%'!", color_string);
                return false, 0;
            }
                	
            return true, xx color;
        } else {
            return true, default;
        }
    }

    get_string_reference :: (json_value: JSON_Value, key: string, shared_strings: *[..] String_Reference) -> String_Reference {
        str := get_optional_string(json_value, key);
        if str.has_value {
            found, index := find_string_reference(shared_strings.*, str.value);
            if found {
                return shared_strings.*[index];
            } else {
                result := String_Reference.{
                    original_index = xx shared_strings.count,
                    data = str,
                };
    		
                array_add(shared_strings, result);
                return result;
            }
        } else {
            return .{
                original_index = 0,
                data = create_optional(""),
            };
        }
    }

    find_string_reference :: (shared_strings: [] String_Reference, needle: string) -> (found: bool, result: int) {
        for shared_strings {
            if !it.data.has_value  continue;
	
            if it.data.value == needle {
                return true, it_index;
            }
        }
	
        return false, -1;
    }
}


#import "jaison";

Hash_Table :: #import "Hash_Table";
