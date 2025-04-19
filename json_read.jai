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
    
    get_string_array :: (json_value: JSON_Value, key: string, output: *[..] string) -> bool {
        strings_node := get(json_value, key, .ARRAY);
        for string_node: strings_node.array {
            if string_node.type != .STRING {
                log_error("Is not a string!");
                return false;
            }
                
            array_add(output, string_node.str);
        }
        
        return true;
    }

	// @todo: We are just asserting, but on release builds we would just return invalid values!
    get_number :: (json_value: JSON_Value) -> float64 {
    	assert(json_value.type == .NUMBER);
        return json_value.number;
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
    
    get_number_array :: (json_value: JSON_Value, key: string, output: *[..] s16) -> bool {
    	json_array := get(json_value, key, .ARRAY);
    	return get_number_array(json_array, output);
    }
    get_number_array :: (json_value: JSON_Value, output: *[..] s16) -> bool {
    	if json_value.type != .ARRAY {
    		log_error("Json is not an array!");
    		return false;
    	}
    	
        array_reserve(output, json_value.array.count);
    
    	for json_value.array {
    		if it.type != .NUMBER {
    			log_error("Is not a number!");
    			return false;
    		}
    		
    		array_add(output, xx it.number);  // @todo Check range
    	}
    	
    	return true;
    }
    
    get_number_array :: (json_value: JSON_Value, key: string, output: *[..] s32) -> bool {
    	json_array := get(json_value, key, .ARRAY);
    	return get_number_array(json_array, output);
    }
    get_number_array :: (json_value: JSON_Value, output: *[..] s32) -> bool {
    	if json_value.type != .ARRAY {
    		log_error("Json is not an array!");
    		return false;
    	}
    	
        array_reserve(output, json_value.array.count);
    
    	for json_value.array {
    		if it.type != .NUMBER {
    			log_error("Is not a number!");
    			return false;
    		}
    		
    		array_add(output, xx it.number);  // @todo Check range
    	}
    	
    	return true;
    }
    
    get_number_array :: (json_value: JSON_Value, key: string, output: *[..] float64, scale: float64) -> bool {
    	json_array := get(json_value, key, .ARRAY);
    	success := get_number_array(json_array, output, scale);
    	if !success {
    		log_error("Error while reading number array: %", key);
    	}
    	
    	return success;
    }
    get_number_array :: (json_value: JSON_Value, output: *[..] float64, scale: float64) -> bool {
    	if json_value.type != .ARRAY {
    		log_error("Json is not an array!");
    		return false;
    	}
    	
        array_reserve(output, json_value.array.count);
    
        if scale == 1 {
            for json_value.array {
                if it.type != .NUMBER {
                    log_error("Vertex is not a number!");
                    return false;
                }
                	
                array_add(output, it.number);
            }
        } else {
            for json_value.array {
                if it.type != .NUMBER {
                    log_error("Vertex is not a number!");
                    return false;
                }
                	
                array_add(output, it.number * scale);
            }
        }
    	
    	return true;
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
        	return get_string_reference(str.value, shared_strings);
        } else {
            return .{
                original_index = 0,
                data = create_optional(""),
            };
        }
    }
    
    get_string_reference :: (value: string, shared_strings: *[..] String_Reference) -> String_Reference {
        found, index := find_string_reference(shared_strings.*, value);
        if found {
            return shared_strings.*[index];
        } else {
            result := String_Reference.{
                original_index = xx shared_strings.count,
                data = create_optional(value),
            };
    		
            array_add(shared_strings, result);
            return result;
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
