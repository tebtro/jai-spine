DEBUG :: true;

add_constants :: (w: Workspace) {
    add_build_string(tprint("DEBUG :: %;", ifx DEBUG then "true" else "false"), w);
}

build :: () {
    options := get_build_options();
    
    if !DEBUG {
        set_optimization(*options, .VERY_OPTIMIZED);

        options.stack_trace = false;
        options.array_bounds_check        = .OFF;
        options.cast_bounds_check         = .OFF;
        options.null_pointer_check        = .OFF;
        options.arithmetic_overflow_check = .OFF;

        options.llvm_options.enable_split_modules = false;
    }

    make_directory_if_it_does_not_exist(options.output_path);
    
    options.output_path = "examples";
	if true build_workspace(*options, "skeleton.test", "examples/skeleton.test.jai");

    set_build_options_dc(.{do_output=false});
}

build_workspace :: (options: *Build_Options, name: string, main_file: string) {
    options.output_executable_name = name;
    
    w := compiler_create_workspace();
    
    check_bindings   := true;
    do_check         := true;  // Import modules/Check if true.

    user_arguments: [..] string;

    index := 0;

    // Handle command-line arguments. Once we see + or -,
    // we are done looking for our arguments.
    
    got_error       := false;

    output_executable_name: string;
    output_path:            string;

    plugin_start_index := -1;
    
    args := get_build_options().compile_time_command_line;
    
    while index < args.count {
        defer index += 1;

        it := args[index];

        if !it continue;  // @Temporary?

        if it[0] == #char "-" {
            if it == {
                case "-";
                    // Everything after this is user arguments.
                    for i: index+1..args.count-1  array_add(*user_arguments, args[i]);
                    break;

                case;
                    log_error("Unknown argument '%'.\nExiting.\n", it);
                    got_error = true;
                    break;
            }

            continue;
        } else if it[0] == #char "+" {
            plugin_start_index = index;
            break;
        }
    }
    
    plugins_to_create: [..] Plugin_To_Create;
    
    if plugin_start_index >= 0 {
        success:, plugins_to_create = parse_plugin_arguments(args, plugin_start_index);
        if !success got_error = true;
    }
    
    if got_error {
        exit(1);
    }
    
    if do_check {
        p := array_add(*plugins_to_create);
        if check_bindings  p.name = "Check";
        else               p.name = "Check(CHECK_BINDINGS=false)";
    }
    
    // Now that we know what the plugins are, init them.
    init_plugins(plugins_to_create, *plugins, w);
    
    all_success := true;
    
    assert(plugins.count == plugins_to_create.count);
    for p: plugins {
        c := *plugins_to_create[it_index];
        if p.init {
            success := p.init(p, c.options);
            all_success &&= success;
        } else if c.options {
            log_error("Plugin '%' takes no options, but these options were given: %\n", c.name, c.options);
        }
    }

    if !all_success {
        log_error("A plugin init() failed. Exiting.\n");
        exit(0);
    }
    
    intercept_flags: Intercept_Flags;
    
    set_build_options(options, w);
    
    for plugins if it.before_intercept it.before_intercept(it, *intercept_flags);
    
    // As the compiler builds the target program, we can listen in on messages
    // that report the status of the program. In later examples we can use
    // these messages to do sophisticated things, but for now, we'll just
    // use them to report on the status of compilation.

    // To tell the compiler to give us messages, we need to call compiler_begin_intercept
    // before we add any code to the target workspace.
    compiler_begin_intercept(w, intercept_flags);
    
    for plugins      if it.add_source it.add_source(it);
    
    add_constants(w);
    add_build_file(main_file, w);
    
    // Call message_loop(), which is a routine of ours below that will receive the messages.
    message_loop(w);
    
    // When we're done, message_loop will return.
    // We call compiler_end_intercept to tell the compiler we are done.
    compiler_end_intercept(w);
    
    for plugins if it.finish   it.finish  (it);
    for plugins if it.shutdown it.shutdown(it);
    
    {
        // None of the code in this file is intended to end up in an executable
        // of any kind. So, we tell the compiler not to make an executable for us:

        set_build_options_dc(.{do_output=false, write_added_strings=false});
    }
}


#run,stallable build();


//
// message_loop() runs the event loop that reads the messages.
// You can do whatever you want with those messages. The goal
// of this example is just to show the different kinds of messages,
// so we don't do anything crazy yet. But you can do some things
// that are crazy.
//
message_loop :: (w: Workspace) {
    while true {
        // We ask the compiler for the next message. If one is not available,
        // we will wait until it becomes available.
        message := compiler_wait_for_message();
        // Pass the message to all plugins.
        for plugins if it.message it.message(it, message);

        if message.kind == .COMPLETE break;
    }
}


plugins: [..] *Metaprogram_Plugin;


#import "File";
#import "Basic";
#import "Compiler";
#import "Metaprogram_Plugins";
