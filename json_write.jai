Json_Write :: struct {
	builder: *String_Builder;
	optimize: bool;
	
	depth: int;
	
	last_comma_pos := -1;
	
	indent :: (using writer: *Json_Write) {
		if optimize  return;
		
		for 0..depth-1 {
			append(builder, "\t");
		}
	}
	
	space :: (using writer: *Json_Write, count := 1) {
		if optimize  return;
		
		for 0..count-1 {
			append(builder, " ");
		}
	}
	
	comma :: (using writer: *Json_Write) {
		last_comma_pos = builder_string_length(builder);
		append(builder, ",");
	}
	
	start_scope :: (using writer: *Json_Write) {
		last_comma_pos = -1;
	}
	stop_scope :: (using writer: *Json_Write) {
		if last_comma_pos < 0 {
			return;
		}
		
		str := builder_to_string(builder);
		
		part_1 := str;
		part_1.count = last_comma_pos;
		
		part_2 := str;
		part_2.data += last_comma_pos + 1;
		part_2.count -= last_comma_pos + 1;
		
		append(builder, part_1);
		append(builder, part_2);
		
		last_comma_pos = -1;
	}
	
	newline :: (using writer: *Json_Write) {
		if optimize  return;
		
		append(builder, "\n");
	}
	
	write_scope :: (using writer: *Json_Write, key: string, code: Code, start: string, end: string) #expand {
		indent(writer);
	
		if key {
			append(builder, "\"");
			append(builder, key);
			append(builder, "\":");
			space(writer);
		}
	
    	append(builder, start);
    	newline(writer);
    	
		start_scope(writer);
    	
    	depth += 1;
		
		#insert code;
		
    	depth -= 1;
    	
		stop_scope(writer);
		
		indent(writer);
    	append(builder, end);
        comma(writer);
    	newline(writer);
	}
	
	write_object :: (using writer: *Json_Write, code: Code) #expand {
		write_scope(writer, "", code, "{", "}");
	}
	write_object :: (using writer: *Json_Write, key: string, code: Code) #expand {
		write_scope(writer, key, code, "{", "}");
	}
	
	write_array :: (using writer: *Json_Write, code: Code) #expand {
		write_scope(writer, "", code, "[", "]");
	}
	write_array :: (using writer: *Json_Write, key: string, code: Code) #expand {
		write_scope(writer, key, code, "[", "]");
	}
	
	write :: (using writer: *Json_Write, key: string, value: bool, default: bool) {
		if value == default  return;
		write(writer, key, value);
	}
	write :: (using writer: *Json_Write, key: string, value: bool) {
		indent(writer);
        append(builder, "\"");
        append(builder, key);
        append(builder, "\":");
        space(writer);
		append(builder, ifx value then "true" else "false");
        comma(writer);
		newline(writer);
	}
	
	write :: (using writer: *Json_Write, key: string, value: int, default: int) {
		if value == default  return;
		write(writer, key, value);
	}
	write :: (using writer: *Json_Write, key: string, value: int) {
		indent(writer);
        append(builder, "\"");
        append(builder, key);
        append(builder, "\":");
        space(writer);
		append(builder, tprint("%", value));
        comma(writer);
		newline(writer);
	}
	
	write :: (using writer: *Json_Write, key: string, value: float64, default: float64) {
		if value == default  return;
		write(writer, key, value);
	}
	write :: (using writer: *Json_Write, key: string, value: float64) {
		indent(writer);
        append(builder, "\"");
        append(builder, key);
        append(builder, "\":");
        space(writer);
		append(builder, tprint("%", value));
        comma(writer);
		newline(writer);
	}
	
	write :: (using writer: *Json_Write, key: string, value: string) {
		indent(writer);
        append(builder, "\"");
        append(builder, key);
        append(builder, "\":");
        space(writer);
        append(builder, "\"");
		append(builder, value);
        append(builder, "\"");
        comma(writer);
		newline(writer);
	}
	
	write :: (using writer: *Json_Write, key: string, optional_string: Optional(string)) {
		if optional_string.has_value {
			write(writer, key, optional_string.value);
		}
	}
	
	write :: (using writer: *Json_Write, key: string, value: String_Reference) {
		if value.data.has_value {
			write(writer, key, value.data.value);
		}
	}
	
	write_color :: (using writer: *Json_Write, key: string, value: Color, default: Color) {
		if value == default  return;
		write_color(writer, key, value);
	}
	write_color :: (using writer: *Json_Write, key: string, value: Color) {
		indent(writer);
        append(builder, "\"");
        append(builder, key);
        append(builder, "\":");
        space(writer);
        dec := tprint("%", value);
        hex := tprint("0x%", FormatInt.{ value = value, base = 16 });
        if dec.count < hex.count {
			append(builder, dec);
        } else {
			append(builder, hex);
        }
        comma(writer);
		newline(writer);
	}
}
