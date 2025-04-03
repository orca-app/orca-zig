//! Input, windowing, dialogs.

pub const window = u64;

// @Cleanup events should be in their own namespace

//------------------------------------------------------------------------------------------
// [Events] Application events.
//------------------------------------------------------------------------------------------

/// This enum defines the type events that can be sent to the application by the runtime. This determines which member of the `oc_event` union field is active.
pub const EventType = enum(u32) {
    /// No event. That could be used simply to wake up the application.
    none = 0,
    /// A modifier key event. This event is sent when a key such as <kbd>Alt</kbd>, <kbd>Control</kbd>, <kbd>Command</kbd> or <kbd>Shift</kbd> are pressed, released, or repeated. The `key` field contains the event's details.
    keyboard_mods = 1,
    /// A key event. This event is sent when a normal key is pressed, released, or repeated. The `key` field contains the event's details.
    keyboard_key = 2,
    /// A character input event. This event is sent when an input character is produced by the keyboard. The `character` field contains the event's details.
    keyboard_char = 3,
    /// A mouse button event. This is event sent when one of the mouse buttons is pressed, released, or clicked. The `key` field contains the event's details.
    mouse_button = 4,
    /// A mouse move event. This is event sent when the mouse is moved. The `mouse` field contains the event's details.
    mouse_move = 5,
    /// A mouse wheel event. This is event sent when the mouse wheel is moved (or when a trackpad is scrolled). The `mouse` field contains the event's details.
    mouse_wheel = 6,
    /// A mouse enter event. This event is sent when the mouse enters the application's window. The `mouse` field contains the event's details.
    mouse_enter = 7,
    /// A mouse leave event. This event is sent when the mouse leaves the application's window.
    mouse_leave = 8,
    /// A clipboard paste event. This event is sent when the user uses the paste shortcut while the application window has focus.
    clipboard_paste = 9,
    /// A resize event. This event is sent when the application's window is resized. The `move` field contains the event's details.
    window_resize = 10,
    /// A move event. This event is sent when the window is moved. The `move` field contains the event's details.
    window_move = 11,
    /// A focus event. This event is sent when the application gains focus.
    window_focus = 12,
    /// An unfocus event. This event is sent when the application looses focus.
    window_unfocus = 13,
    /// A hide event. This event is sent when the application's window is hidden or minimized.
    window_hide = 14,
    /// A show event. This event is sent when the application's window is shown or de-minimized.
    window_show = 15,
    /// A close event. This event is sent when the window is about to be closed.
    window_close = 16,
    /// A path drop event. This event is sent when the user drops files onto the application's window. The `paths` field contains the event's details.
    pathdrop = 17,
    /// A frame event. This event is sent when the application should render a frame.
    frame = 18,
    /// A quit event. This event is sent when the application has been requested to quit.
    quit = 19,
};
/// This enum describes the actions that can happen to a key.
pub const KeyAction = enum(u32) {
    /// No action happened on that key.
    no_action = 0,
    /// The key was pressed.
    press = 1,
    /// The key was released.
    release = 2,
    /// The key was maintained pressed at least for the system's key repeat period.
    repeat = 3,
};
/// A code representing a key's physical location. This is independent of the system's keyboard layout.
pub const ScanCode = enum(u32) {
    unknown = 0,
    space = 32,
    apostrophe = 39,
    comma = 44,
    minus = 45,
    period = 46,
    slash = 47,
    @"0" = 48,
    @"1" = 49,
    @"2" = 50,
    @"3" = 51,
    @"4" = 52,
    @"5" = 53,
    @"6" = 54,
    @"7" = 55,
    @"8" = 56,
    @"9" = 57,
    semicolon = 59,
    equal = 61,
    left_bracket = 91,
    backslash = 92,
    right_bracket = 93,
    grave_accent = 96,
    a = 97,
    b = 98,
    c = 99,
    d = 100,
    e = 101,
    f = 102,
    g = 103,
    h = 104,
    i = 105,
    j = 106,
    k = 107,
    l = 108,
    m = 109,
    n = 110,
    o = 111,
    p = 112,
    q = 113,
    r = 114,
    s = 115,
    t = 116,
    u = 117,
    v = 118,
    w = 119,
    x = 120,
    y = 121,
    z = 122,
    world_1 = 161,
    world_2 = 162,
    escape = 256,
    enter = 257,
    tab = 258,
    backspace = 259,
    insert = 260,
    delete = 261,
    right = 262,
    left = 263,
    down = 264,
    up = 265,
    page_up = 266,
    page_down = 267,
    home = 268,
    end = 269,
    caps_lock = 280,
    scroll_lock = 281,
    num_lock = 282,
    print_screen = 283,
    pause = 284,
    f1 = 290,
    f2 = 291,
    f3 = 292,
    f4 = 293,
    f5 = 294,
    f6 = 295,
    f7 = 296,
    f8 = 297,
    f9 = 298,
    f10 = 299,
    f11 = 300,
    f12 = 301,
    f13 = 302,
    f14 = 303,
    f15 = 304,
    f16 = 305,
    f17 = 306,
    f18 = 307,
    f19 = 308,
    f20 = 309,
    f21 = 310,
    f22 = 311,
    f23 = 312,
    f24 = 313,
    f25 = 314,
    kp_0 = 320,
    kp_1 = 321,
    kp_2 = 322,
    kp_3 = 323,
    kp_4 = 324,
    kp_5 = 325,
    kp_6 = 326,
    kp_7 = 327,
    kp_8 = 328,
    kp_9 = 329,
    kp_decimal = 330,
    kp_divide = 331,
    kp_multiply = 332,
    kp_subtract = 333,
    kp_add = 334,
    kp_enter = 335,
    kp_equal = 336,
    left_shift = 340,
    left_control = 341,
    left_alt = 342,
    left_super = 343,
    right_shift = 344,
    right_control = 345,
    right_alt = 346,
    right_super = 347,
    menu = 348,
};
/// A code identifying a key. The physical location of the key corresponding to a given key code depends on the system's keyboard layout.
pub const KeyCode = enum(u32) {
    unknown = 0,
    space = 32,
    apostrophe = 39,
    comma = 44,
    minus = 45,
    period = 46,
    slash = 47,
    @"0" = 48,
    @"1" = 49,
    @"2" = 50,
    @"3" = 51,
    @"4" = 52,
    @"5" = 53,
    @"6" = 54,
    @"7" = 55,
    @"8" = 56,
    @"9" = 57,
    semicolon = 59,
    equal = 61,
    left_bracket = 91,
    backslash = 92,
    right_bracket = 93,
    grave_accent = 96,
    a = 97,
    b = 98,
    c = 99,
    d = 100,
    e = 101,
    f = 102,
    g = 103,
    h = 104,
    i = 105,
    j = 106,
    k = 107,
    l = 108,
    m = 109,
    n = 110,
    o = 111,
    p = 112,
    q = 113,
    r = 114,
    s = 115,
    t = 116,
    u = 117,
    v = 118,
    w = 119,
    x = 120,
    y = 121,
    z = 122,
    world_1 = 161,
    world_2 = 162,
    escape = 256,
    enter = 257,
    tab = 258,
    backspace = 259,
    insert = 260,
    delete = 261,
    right = 262,
    left = 263,
    down = 264,
    up = 265,
    page_up = 266,
    page_down = 267,
    home = 268,
    end = 269,
    caps_lock = 280,
    scroll_lock = 281,
    num_lock = 282,
    print_screen = 283,
    pause = 284,
    f1 = 290,
    f2 = 291,
    f3 = 292,
    f4 = 293,
    f5 = 294,
    f6 = 295,
    f7 = 296,
    f8 = 297,
    f9 = 298,
    f10 = 299,
    f11 = 300,
    f12 = 301,
    f13 = 302,
    f14 = 303,
    f15 = 304,
    f16 = 305,
    f17 = 306,
    f18 = 307,
    f19 = 308,
    f20 = 309,
    f21 = 310,
    f22 = 311,
    f23 = 312,
    f24 = 313,
    f25 = 314,
    kp_0 = 320,
    kp_1 = 321,
    kp_2 = 322,
    kp_3 = 323,
    kp_4 = 324,
    kp_5 = 325,
    kp_6 = 326,
    kp_7 = 327,
    kp_8 = 328,
    kp_9 = 329,
    kp_decimal = 330,
    kp_divide = 331,
    kp_multiply = 332,
    kp_subtract = 333,
    kp_add = 334,
    kp_enter = 335,
    kp_equal = 336,
    left_shift = 340,
    left_control = 341,
    left_alt = 342,
    left_super = 343,
    right_shift = 344,
    right_control = 345,
    right_alt = 346,
    right_super = 347,
    menu = 348,
};
// @Api should mark this as a bitflag type
pub const KeymodFlags = packed struct(u32) {
    alt: bool = false,
    shift: bool = false,
    ctrl: bool = false,
    cmd: bool = false,
    main_modifier: bool = false,

    _padding: u27 = 0,
};
/// A code identifying a mouse button.
pub const MouseButton = enum(u32) {
    left = 0,
    right = 1,
    middle = 2,
    ext1 = 3,
    ext2 = 4,
    button_count = 5,
};
/// A structure describing a key event or a mouse button event.
pub const KeyEvent = extern struct {
    /// The action that was done on the key.
    action: KeyAction,
    /// The scan code of the key. Only valid for key events.
    scanCode: ScanCode,
    /// The key code of the key. Only valid for key events.
    keyCode: KeyCode,
    /// The button of the mouse. Only valid for mouse button events.
    button: MouseButton,
    /// Modifier flags indicating which modifier keys where pressed at the time of the event.
    mods: KeymodFlags,
    /// The number of clicks that where detected for the button. Only valid for mouse button events.
    clickCount: u8,
};
/// A structure describing a character input event.
pub const CharEvent = extern struct {
    /// The unicode codepoint of the character.
    codepoint: oc.utf32,
    /// The utf8 sequence of the character.
    sequence: [8]u8,
    /// The utf8 sequence length.
    seqLen: u8,
};
/// A structure describing a mouse move or a mouse wheel event. Mouse coordinates have their origin at the top-left corner of the window, with the y axis going down.
pub const MouseEvent = extern struct {
    /// The x coordinate of the mouse.
    x: f32,
    /// The y coordinate of the mouse.
    y: f32,
    /// The delta from the last x coordinate of the mouse, or the scroll value along the x coordinate.
    deltaX: f32,
    /// The delta from the last y coordinate of the mouse, or the scoll value along the y  coordinate.
    deltaY: f32,
    /// Modifier flags indicating which modifier keys where pressed at the time of the event.
    mods: KeymodFlags,
};
/// A structure describing a window move or resize event.
pub const MoveEvent = extern struct {
    /// The position and dimension of the frame rectangle, i.e. including the window title bar and border.
    frame: oc.math.Rect,
    /// The position and dimension of the content rectangle, relative to the frame rectangle.
    content: oc.math.Rect,
};
/// A structure describing an event sent to the application.
pub const Event = extern struct {
    /// The window in which this event happened.
    window: window,
    /// The type of the event. This determines which member of the event union is active.
    type: EventType,
    unnamed_0: extern union {
        /// Details for a key or mouse button event.
        key: KeyEvent,
        /// Details for a character input event.
        character: CharEvent,
        /// Details for a mouse move or mouse wheel event.
        mouse: MouseEvent,
        /// Details for a window move or resize event.
        move: MoveEvent,
        /// Details for a drag and drop event.
        paths: oc.strings.Str8List,
    },
};
// @Api @Cleanup could be moved into io/dialogs namespace
/// This enum describes the kinds of possible file dialogs.
pub const FileDialogKind = enum(u32) {
    /// The file dialog is a save dialog.
    save = 0,
    /// The file dialog is an open dialog.
    open = 1,
};
// @Api this should be marked as a bitflag type
/// A type for flags describing various file dialog options.
pub const FileDialogFlags = packed struct(u32) {
    /// This dialog allows selecting files.
    files: bool = true,
    /// This dialog allows selecting directories.
    directories: bool = false,
    /// This dialog allows selecting multiple items.
    multiple: bool = false,
    /// This dialog allows creating directories.
    create_directories: bool = false,

    _padding: u28 = 0,
};
/// A structure describing a file dialog.
pub const FileDialogDesc = extern struct {
    /// The kind of file dialog, see `oc_file_dialog_kind`.
    kind: FileDialogKind,
    /// A combination of file dialog flags used to enable file dialog options.
    flags: FileDialogFlags,
    /// The title of the dialog, displayed in the dialog title bar.
    title: oc.strings.Str8,
    /// Optional. The label of the OK button, e.g. "Save" or "Open".
    okLabel: oc.strings.Str8,
    /// Optional. A file handle to the root directory for the dialog. If set to zero, the root directory is the application's default data directory.
    startAt: oc.file,
    /// Optional. The path of the starting directory of the dialog, relative to its root directory. If set to nil, the dialog starts at its root directory.
    startPath: oc.strings.Str8,
    /// A list of file extensions used to restrict which files can be selected in this dialog. An empty list allows all files to be selected. Extensions should be provided without a leading dot.
    filters: oc.strings.Str8List,
};
/// An enum identifying the button clicked by the user when a file dialog returns.
pub const FileDialogButton = enum(u32) {
    /// The user clicked the "Cancel" button, or closed the dialog box.
    cancel = 0,
    /// The user clicked the "OK" button.
    ok = 1,
};
/// A structure describing the result of a file dialog.
pub const FileDialogResult = extern struct {
    /// The button clicked by the user.
    button: FileDialogButton,
    /// The path that was selected when the user clicked the OK button. If the dialog box had the `OC_FILE_DIALOG_MULTIPLE` flag set, this is the first file of the list of selected paths.
    path: oc.strings.Str8,
    /// If the dialog box had the `OC_FILE_DIALOG_MULTIPLE` flag set and the user clicked the OK button, this list contains the selected paths.
    selection: oc.strings.Str8List,
};
/// Set the title of the application's window.
pub const windowSetTitle = oc_window_set_title;
extern fn oc_window_set_title(
    /// The title to display in the title bar of the application.
    title: oc.strings.Str8,
) callconv(.C) void;
/// Set the size of the application's window.
pub const windowSetSize = oc_window_set_size;
extern fn oc_window_set_size(
    /// The new size of the application's window.
    size: oc.math.Vec2,
) callconv(.C) void;
/// Request the system to quit the application.
pub const requestQuit = oc_request_quit;
extern fn oc_request_quit() callconv(.C) void;
/// Convert a scancode to a keycode, according to current keyboard layout.
pub const scancodeToKeycode = oc_scancode_to_keycode;
extern fn oc_scancode_to_keycode(
    /// The scan code to convert.
    scanCode: ScanCode,
) callconv(.C) KeyCode;
/// Put a string in the clipboard.
pub const clipboardSetString = oc_clipboard_set_string;
extern fn oc_clipboard_set_string(
    /// A string to put in the clipboard.
    string: oc.strings.Str8,
) callconv(.C) void;

const oc = @import("orca.zig");
