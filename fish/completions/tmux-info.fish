set -l _tmux_variables \
     'active_window_index\t"Index of active window in session"' \
     'alternate_on\t"1 if pane is in alternate screen"' \
     'alternate_saved_x\t"Saved cursor X in alternate screen"' \
     'alternate_saved_y\t"Saved cursor Y in alternate screen"' \
     'buffer_created\t"Time buffer created"' \
     'buffer_name\t"Name of buffer"' \
     'buffer_sample\t"Sample of start of buffer"' \
     'buffer_size\t"Size of the specified buffer in bytes"' \
     'client_activity\t"Time client last had activity"' \
     'client_cell_height\t"Height of each client cell in pixels"' \
     'client_cell_width\t"Width of each client cell in pixels"' \
     'client_control_mode\t"1 if client is in control mode"' \
     'client_created\t"Time client created"' \
     'client_discarded\t"Bytes discarded when client behind"' \
     'client_flags\t"List of client flags"' \
     'client_height\t"Height of client"' \
     'client_key_table\t"Current key table"' \
     'client_last_session\t"Name of the client"''s last session' \
     'client_name\t"Name of client"' \
     'client_pid\t"PID of client process"' \
     'client_prefix\t"1 if prefix key has been pressed"' \
     'client_readonly\t"1 if client is read-only"' \
     'client_session\t"Name of the client"''s session' \
     'client_termfeatures\t"Terminal features of client, if any"' \
     'client_termname\t"Terminal name of client"' \
     'client_termtype\t"Terminal type of client, if available"' \
     'client_tty\t"Pseudo terminal of client"' \
     'client_uid\t"UID of client process"' \
     'client_user\t"User of client process"' \
     'client_utf8\t"1 if client supports UTF-8"' \
     'client_width\t"Width of client"' \
     'client_written\t"Bytes written to client"' \
     'command\t"Name of command in use, if any"' \
     'command_list_alias\t"Command alias if listing commands"' \
     'command_list_name\t"Command name if listing commands"' \
     'command_list_usage\t"Command usage if listing commands"' \
     'config_files\t"List of configuration files loaded"' \
     'copy_cursor_line\t"Line the cursor is on in copy mode"' \
     'copy_cursor_word\t"Word under cursor in copy mode"' \
     'copy_cursor_x\t"Cursor X position in copy mode"' \
     'copy_cursor_y\t"Cursor Y position in copy mode"' \
     'current_file\t"Current configuration file"' \
     'cursor_character\t"Character at cursor in pane"' \
     'cursor_flag\t"Pane cursor flag"' \
     'cursor_x\t"Cursor X position in pane"' \
     'cursor_y\t"Cursor Y position in pane"' \
     'history_bytes\t"Number of bytes in window history"' \
     'history_limit\t"Maximum window history lines"' \
     'history_size\t"Size of history in lines"' \
     'hook\t"Name of running hook, if any"' \
     'hook_client\t"Name of client where hook was run, if any"' \
     'hook_pane\t"ID of pane where hook was run, if any"' \
     'hook_session\t"ID of session where hook was run, if any"' \
     'hook_session_name\t"Name of session where hook was run, if any"' \
     'hook_window\t"ID of window where hook was run, if any"' \
     'hook_window_name\t"Name of window where hook was run, if any"' \
     'host\t"Hostname of local host"' \
     'host_short\t"Hostname of local host {no domain name}"' \
     'insert_flag\t"Pane insert flag"' \
     'keypad_cursor_flag\t"Pane keypad cursor flag"' \
     'keypad_flag\t"Pane keypad flag"' \
     'last_window_index\t"Index of last window in session"' \
     'line\t"Line number in the list"' \
     'mouse_all_flag\t"Pane mouse all flag"' \
     'mouse_any_flag\t"Pane mouse any flag"' \
     'mouse_button_flag\t"Pane mouse button flag"' \
     'mouse_hyperlink\t"Hyperlink under mouse, if any"' \
     'mouse_line\t"Line under mouse, if any"' \
     'mouse_sgr_flag\t"Pane mouse SGR flag"' \
     'mouse_standard_flag\t"Pane mouse standard flag"' \
     'mouse_status_line\t"Status line on which mouse event took place"' \
     'mouse_status_range\t"Range type or argument of mouse event on status line"' \
     'mouse_utf8_flag\t"Pane mouse UTF-8 flag"' \
     'mouse_word\t"Word under mouse, if any"' \
     'mouse_x\t"Mouse X position, if any"' \
     'mouse_y\t"Mouse Y position, if any"' \
     'next_session_id\t"Unique session ID for next new session"' \
     'origin_flag\t"Pane origin flag"' \
     'pane_active\t"1 if active pane"' \
     'pane_at_bottom\t"1 if pane is at the bottom of window"' \
     'pane_at_left\t"1 if pane is at the left of window"' \
     'pane_at_right\t"1 if pane is at the right of window"' \
     'pane_at_top\t"1 if pane is at the top of window"' \
     'pane_bg\t"Pane background colour"' \
     'pane_bottom\t"Bottom of pane"' \
     'pane_current_command\t"Current command if available"' \
     'pane_current_path\t"Current path if available"' \
     'pane_dead\t"1 if pane is dead"' \
     'pane_dead_signal\t"Exit signal of process in dead pane"' \
     'pane_dead_status\t"Exit status of process in dead pane"' \
     'pane_dead_time\t"Exit time of process in dead pane"' \
     'pane_fg\t"Pane foreground colour"' \
     'pane_format\t"1 if format is for a pane"' \
     'pane_height\t"Height of pane"' \
     'pane_id\t"Unique pane ID"' \
     'pane_in_mode\t"1 if pane is in a mode"' \
     'pane_index\t"Index of pane"' \
     'pane_input_off\t"1 if input to pane is disabled"' \
     'pane_last\t"1 if last pane"' \
     'pane_left\t"Left of pane"' \
     'pane_marked\t"1 if this is the marked pane"' \
     'pane_marked_set\t"1 if a marked pane is set"' \
     'pane_mode\t"Name of pane mode, if any"' \
     'pane_path\t"Path of pane {can be set by application}"' \
     'pane_pid\t"PID of first process in pane"' \
     'pane_pipe\t"1 if pane is being piped"' \
     'pane_right\t"Right of pane"' \
     'pane_search_string\t"Last search string in copy mode"' \
     'pane_start_command\t"Command pane started with"' \
     'pane_start_path\t"Path pane started with"' \
     'pane_synchronized\t"1 if pane is synchronized"' \
     'pane_tabs\t"Pane tab positions"' \
     'pane_title\t"Title of pane {can be set by application}"' \
     'pane_top\t"Top of pane"' \
     'pane_tty\t"Pseudo terminal of pane"' \
     'pane_unseen_changes\t"1 if there were changes in pane while in mode"' \
     'pane_width\t"Width of pane"' \
     'pid\t"Server PID"' \
     'rectangle_toggle\t"1 if rectangle selection is activated"' \
     'scroll_position\t"Scroll position in copy mode"' \
     'scroll_region_lower\t"Bottom of scroll region in pane"' \
     'scroll_region_upper\t"Top of scroll region in pane"' \
     'search_match\t"Search match if any"' \
     'search_present\t"1 if search started in copy mode"' \
     'selection_active\t"1 if selection started and changes with the cursor in copy mode"' \
     'selection_end_x\t"X position of the end of the selection"' \
     'selection_end_y\t"Y position of the end of the selection"' \
     'selection_present\t"1 if selection started in copy mode"' \
     'selection_start_x\t"X position of the start of the selection"' \
     'selection_start_y\t"Y position of the start of the selection"' \
     'server_sessions\t"Number of sessions"' \
     'session_activity\t"Time of session last activity"' \
     'session_alerts\t"List of window indexes with alerts"' \
     'session_attached\t"Number of clients session is attached to"' \
     'session_attached_list\t"List of clients session is attached to"' \
     'session_created\t"Time session created"' \
     'session_format\t"1 if format is for a session"' \
     'session_group\t"Name of session group"' \
     'session_group_attached\t"Number of clients sessions in group are attached to"' \
     'session_group_attached_list\t"List of clients sessions in group are attached to"' \
     'session_group_list\t"List of sessions in group"' \
     'session_group_many_attached\t"1 if multiple clients attached to sessions in group"' \
     'session_group_size\t"Size of session group"' \
     'session_grouped\t"1 if session in a group"' \
     'session_id\t"Unique session ID"' \
     'session_last_attached\t"Time session last attached"' \
     'session_many_attached\t"1 if multiple clients attached"' \
     'session_marked\t"1 if this session contains the marked pane"' \
     'session_name\t"Name of session"' \
     'session_path\t"Working directory of session"' \
     'session_stack\t"Window indexes in most recent order"' \
     'session_windows\t"Number of windows in session"' \
     'socket_path\t"Server socket path"' \
     'start_time\t"Server start time"' \
     'uid\t"Server UID"' \
     'user\t"Server user"' \
     'version\t"Server version"' \
     'window_active\t"1 if window active"' \
     'window_active_clients\t"Number of clients viewing this window"' \
     'window_active_clients_list\t"List of clients viewing this window"' \
     'window_active_sessions\t"Number of sessions on which this window is active"' \
     'window_active_sessions_list\t"List of sessions on which this window is active"' \
     'window_activity\t"Time of window last activity"' \
     'window_activity_flag\t"1 if window has activity"' \
     'window_bell_flag\t"1 if window has bell"' \
     'window_bigger\t"1 if window is larger than client"' \
     'window_cell_height\t"Height of each cell in pixels"' \
     'window_cell_width\t"Width of each cell in pixels"' \
     'window_end_flag\t"1 if window has the highest index"' \
     'window_flags\t"Window flags with # escaped as ##"' \
     'window_format\t"1 if format is for a window"' \
     'window_height\t"Height of window"' \
     'window_id\t"Unique window ID"' \
     'window_index\t"Index of window"' \
     'window_last_flag\t"1 if window is the last used"' \
     'window_layout\t"Window layout description, ignoring zoomed window panes"' \
     'window_linked\t"1 if window is linked across sessions"' \
     'window_linked_sessions\t"Number of sessions this window is linked to"' \
     'window_linked_sessions_list\t"List of sessions this window is linked to"' \
     'window_marked_flag\t"1 if window contains the marked pane"' \
     'window_name\t"Name of window"' \
     'window_offset_x\t"X offset into window if larger than client"' \
     'window_offset_y\t"Y offset into window if larger than client"' \
     'window_panes\t"Number of panes in window"' \
     'window_raw_flags\t"Window flags with nothing escaped"' \
     'window_silence_flag\t"1 if window has silence alert"' \
     'window_stack_index\t"Index in session most recent stack"' \
     'window_start_flag\t"1 if window has the lowest index"' \
     'window_visible_layout\t"Window layout description, respecting zoomed window panes"' \
     'window_width\t"Width of window"' \
     'window_zoomed_flag\t"1 if window is zoomed"' \
     'wrap_flag\t"Pane wrap flag"'

complete -c tmux-info \
    -xa "$_tmux_variables"
