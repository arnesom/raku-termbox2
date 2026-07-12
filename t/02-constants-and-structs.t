use v6;
use Test;
use lib 'lib';
use NativeCall;
use Termbox2;

# Expected values are transcribed directly from the vendored
# resources/termbox2.h, independently of lib/Termbox2.rakumod, so a typo in
# the module's constants is caught rather than compared against itself.
#
# Nothing in this file touches termbox's internal (tb_init-allocated) state,
# so it runs unconditionally, without a TTY or CI skip logic.

# Error / status codes
is TB_OK,                   0, 'TB_OK';
is TB_ERR,                  -1, 'TB_ERR';
is TB_ERR_NEED_MORE,        -2, 'TB_ERR_NEED_MORE';
is TB_ERR_INIT_ALREADY,     -3, 'TB_ERR_INIT_ALREADY';
is TB_ERR_INIT_OPEN,        -4, 'TB_ERR_INIT_OPEN';
is TB_ERR_MEM,              -5, 'TB_ERR_MEM';
is TB_ERR_NO_EVENT,         -6, 'TB_ERR_NO_EVENT';
is TB_ERR_NO_TERM,          -7, 'TB_ERR_NO_TERM';
is TB_ERR_NOT_INIT,         -8, 'TB_ERR_NOT_INIT';
is TB_ERR_OUT_OF_BOUNDS,    -9, 'TB_ERR_OUT_OF_BOUNDS';
is TB_ERR_READ,             -10, 'TB_ERR_READ';
is TB_ERR_RESIZE_IOCTL,     -11, 'TB_ERR_RESIZE_IOCTL';
is TB_ERR_RESIZE_PIPE,      -12, 'TB_ERR_RESIZE_PIPE';
is TB_ERR_RESIZE_SIGACTION, -13, 'TB_ERR_RESIZE_SIGACTION';
is TB_ERR_POLL,             -14, 'TB_ERR_POLL';
is TB_ERR_TCGETATTR,        -15, 'TB_ERR_TCGETATTR';
is TB_ERR_TCSETATTR,        -16, 'TB_ERR_TCSETATTR';
is TB_ERR_UNSUPPORTED_TERM, -17, 'TB_ERR_UNSUPPORTED_TERM';
is TB_ERR_RESIZE_WRITE,     -18, 'TB_ERR_RESIZE_WRITE';
is TB_ERR_RESIZE_POLL,      -19, 'TB_ERR_RESIZE_POLL';
is TB_ERR_RESIZE_READ,      -20, 'TB_ERR_RESIZE_READ';
is TB_ERR_RESIZE_SSCANF,    -21, 'TB_ERR_RESIZE_SSCANF';
is TB_ERR_CAP_COLLISION,    -22, 'TB_ERR_CAP_COLLISION';

# ASCII key constants
is TB_KEY_CTRL_TILDE,       0x00, 'TB_KEY_CTRL_TILDE';
is TB_KEY_CTRL_2,           0x00, 'TB_KEY_CTRL_2';
is TB_KEY_CTRL_A,           0x01, 'TB_KEY_CTRL_A';
is TB_KEY_CTRL_B,           0x02, 'TB_KEY_CTRL_B';
is TB_KEY_CTRL_C,           0x03, 'TB_KEY_CTRL_C';
is TB_KEY_CTRL_D,           0x04, 'TB_KEY_CTRL_D';
is TB_KEY_CTRL_E,           0x05, 'TB_KEY_CTRL_E';
is TB_KEY_CTRL_F,           0x06, 'TB_KEY_CTRL_F';
is TB_KEY_CTRL_G,           0x07, 'TB_KEY_CTRL_G';
is TB_KEY_BACKSPACE,        0x08, 'TB_KEY_BACKSPACE';
is TB_KEY_CTRL_H,           0x08, 'TB_KEY_CTRL_H';
is TB_KEY_TAB,              0x09, 'TB_KEY_TAB';
is TB_KEY_CTRL_I,           0x09, 'TB_KEY_CTRL_I';
is TB_KEY_CTRL_J,           0x0a, 'TB_KEY_CTRL_J';
is TB_KEY_CTRL_K,           0x0b, 'TB_KEY_CTRL_K';
is TB_KEY_CTRL_L,           0x0c, 'TB_KEY_CTRL_L';
is TB_KEY_ENTER,            0x0d, 'TB_KEY_ENTER';
is TB_KEY_CTRL_M,           0x0d, 'TB_KEY_CTRL_M';
is TB_KEY_CTRL_N,           0x0e, 'TB_KEY_CTRL_N';
is TB_KEY_CTRL_O,           0x0f, 'TB_KEY_CTRL_O';
is TB_KEY_CTRL_P,           0x10, 'TB_KEY_CTRL_P';
is TB_KEY_CTRL_Q,           0x11, 'TB_KEY_CTRL_Q';
is TB_KEY_CTRL_R,           0x12, 'TB_KEY_CTRL_R';
is TB_KEY_CTRL_S,           0x13, 'TB_KEY_CTRL_S';
is TB_KEY_CTRL_T,           0x14, 'TB_KEY_CTRL_T';
is TB_KEY_CTRL_U,           0x15, 'TB_KEY_CTRL_U';
is TB_KEY_CTRL_V,           0x16, 'TB_KEY_CTRL_V';
is TB_KEY_CTRL_W,           0x17, 'TB_KEY_CTRL_W';
is TB_KEY_CTRL_X,           0x18, 'TB_KEY_CTRL_X';
is TB_KEY_CTRL_Y,           0x19, 'TB_KEY_CTRL_Y';
is TB_KEY_CTRL_Z,           0x1a, 'TB_KEY_CTRL_Z';
is TB_KEY_ESC,              0x1b, 'TB_KEY_ESC';
is TB_KEY_CTRL_LSQ_BRACKET, 0x1b, 'TB_KEY_CTRL_LSQ_BRACKET';
is TB_KEY_CTRL_3,           0x1b, 'TB_KEY_CTRL_3';
is TB_KEY_CTRL_4,           0x1c, 'TB_KEY_CTRL_4';
is TB_KEY_CTRL_BACKSLASH,   0x1c, 'TB_KEY_CTRL_BACKSLASH';
is TB_KEY_CTRL_5,           0x1d, 'TB_KEY_CTRL_5';
is TB_KEY_CTRL_RSQ_BRACKET, 0x1d, 'TB_KEY_CTRL_RSQ_BRACKET';
is TB_KEY_CTRL_6,           0x1e, 'TB_KEY_CTRL_6';
is TB_KEY_CTRL_7,           0x1f, 'TB_KEY_CTRL_7';
is TB_KEY_CTRL_SLASH,       0x1f, 'TB_KEY_CTRL_SLASH';
is TB_KEY_CTRL_UNDERSCORE,  0x1f, 'TB_KEY_CTRL_UNDERSCORE';
is TB_KEY_SPACE,            0x20, 'TB_KEY_SPACE';
is TB_KEY_BACKSPACE2,       0x7f, 'TB_KEY_BACKSPACE2';
is TB_KEY_CTRL_8,           0x7f, 'TB_KEY_CTRL_8';

# Terminal-dependent key constants
is TB_KEY_F1,               0xffff -  0, 'TB_KEY_F1';
is TB_KEY_F2,               0xffff -  1, 'TB_KEY_F2';
is TB_KEY_F3,               0xffff -  2, 'TB_KEY_F3';
is TB_KEY_F4,               0xffff -  3, 'TB_KEY_F4';
is TB_KEY_F5,               0xffff -  4, 'TB_KEY_F5';
is TB_KEY_F6,               0xffff -  5, 'TB_KEY_F6';
is TB_KEY_F7,               0xffff -  6, 'TB_KEY_F7';
is TB_KEY_F8,               0xffff -  7, 'TB_KEY_F8';
is TB_KEY_F9,               0xffff -  8, 'TB_KEY_F9';
is TB_KEY_F10,              0xffff -  9, 'TB_KEY_F10';
is TB_KEY_F11,              0xffff - 10, 'TB_KEY_F11';
is TB_KEY_F12,              0xffff - 11, 'TB_KEY_F12';
is TB_KEY_INSERT,           0xffff - 12, 'TB_KEY_INSERT';
is TB_KEY_DELETE,           0xffff - 13, 'TB_KEY_DELETE';
is TB_KEY_HOME,             0xffff - 14, 'TB_KEY_HOME';
is TB_KEY_END,              0xffff - 15, 'TB_KEY_END';
is TB_KEY_PGUP,             0xffff - 16, 'TB_KEY_PGUP';
is TB_KEY_PGDN,             0xffff - 17, 'TB_KEY_PGDN';
is TB_KEY_ARROW_UP,         0xffff - 18, 'TB_KEY_ARROW_UP';
is TB_KEY_ARROW_DOWN,       0xffff - 19, 'TB_KEY_ARROW_DOWN';
is TB_KEY_ARROW_LEFT,       0xffff - 20, 'TB_KEY_ARROW_LEFT';
is TB_KEY_ARROW_RIGHT,      0xffff - 21, 'TB_KEY_ARROW_RIGHT';
is TB_KEY_BACK_TAB,         0xffff - 22, 'TB_KEY_BACK_TAB';
is TB_KEY_MOUSE_LEFT,       0xffff - 23, 'TB_KEY_MOUSE_LEFT';
is TB_KEY_MOUSE_RIGHT,      0xffff - 24, 'TB_KEY_MOUSE_RIGHT';
is TB_KEY_MOUSE_MIDDLE,     0xffff - 25, 'TB_KEY_MOUSE_MIDDLE';
is TB_KEY_MOUSE_RELEASE,    0xffff - 26, 'TB_KEY_MOUSE_RELEASE';
is TB_KEY_MOUSE_WHEEL_UP,   0xffff - 27, 'TB_KEY_MOUSE_WHEEL_UP';
is TB_KEY_MOUSE_WHEEL_DOWN, 0xffff - 28, 'TB_KEY_MOUSE_WHEEL_DOWN';

# Modifiers
is TB_MOD_ALT,    1, 'TB_MOD_ALT';
is TB_MOD_CTRL,   2, 'TB_MOD_CTRL';
is TB_MOD_SHIFT,  4, 'TB_MOD_SHIFT';
is TB_MOD_MOTION, 8, 'TB_MOD_MOTION';

# Colors
is TB_DEFAULT, 0x0000, 'TB_DEFAULT';
is TB_BLACK,   0x0001, 'TB_BLACK';
is TB_RED,     0x0002, 'TB_RED';
is TB_GREEN,   0x0003, 'TB_GREEN';
is TB_YELLOW,  0x0004, 'TB_YELLOW';
is TB_BLUE,    0x0005, 'TB_BLUE';
is TB_MAGENTA, 0x0006, 'TB_MAGENTA';
is TB_CYAN,    0x0007, 'TB_CYAN';
is TB_WHITE,   0x0008, 'TB_WHITE';

# Attributes (16-bit build, the vendored header's default TB_OPT_ATTR_W)
is TB_BOLD,      0x0100, 'TB_BOLD';
is TB_UNDERLINE, 0x0200, 'TB_UNDERLINE';
is TB_REVERSE,   0x0400, 'TB_REVERSE';
is TB_ITALIC,    0x0800, 'TB_ITALIC';
is TB_BLINK,     0x1000, 'TB_BLINK';
is TB_HI_BLACK,  0x2000, 'TB_HI_BLACK';
is TB_BRIGHT,    0x4000, 'TB_BRIGHT';
is TB_DIM,       0x8000, 'TB_DIM';

# Event types
is TB_EVENT_KEY,    1, 'TB_EVENT_KEY';
is TB_EVENT_RESIZE, 2, 'TB_EVENT_RESIZE';
is TB_EVENT_MOUSE,  3, 'TB_EVENT_MOUSE';

# Input / output modes
is TB_INPUT_CURRENT,    0, 'TB_INPUT_CURRENT';
is TB_INPUT_ESC,        1, 'TB_INPUT_ESC';
is TB_INPUT_ALT,        2, 'TB_INPUT_ALT';
is TB_INPUT_MOUSE,      4, 'TB_INPUT_MOUSE';
is TB_OUTPUT_CURRENT,   0, 'TB_OUTPUT_CURRENT';
is TB_OUTPUT_NORMAL,    1, 'TB_OUTPUT_NORMAL';
is TB_OUTPUT_256,       2, 'TB_OUTPUT_256';
is TB_OUTPUT_216,       3, 'TB_OUTPUT_216';
is TB_OUTPUT_GRAYSCALE, 4, 'TB_OUTPUT_GRAYSCALE';
is TB_OUTPUT_TRUECOLOR, 5, 'TB_OUTPUT_TRUECOLOR';

# Event/Cell structs: plain CStructs, constructible and settable without an
# initialized terminal.
{
    my Event $event .= new;
    $event.type = TB_EVENT_KEY;
    $event.mod  = TB_MOD_CTRL;
    $event.key  = TB_KEY_CTRL_C;
    $event.ch   = 0;
    $event.x    = 5;
    $event.y    = 7;
    is $event.type, TB_EVENT_KEY, 'Event.type round-trips';
    is $event.mod,  TB_MOD_CTRL,  'Event.mod round-trips';
    is $event.key,  TB_KEY_CTRL_C, 'Event.key round-trips';
    is $event.x,    5, 'Event.x round-trips';
    is $event.y,    7, 'Event.y round-trips';

    my Cell $cell .= new;
    $cell.ch = 'A'.ord;
    $cell.fg = TB_RED;
    $cell.bg = TB_BLACK;
    is $cell.ch, 'A'.ord, 'Cell.ch round-trips';
    is $cell.fg, TB_RED,   'Cell.fg round-trips';
    is $cell.bg, TB_BLACK, 'Cell.bg round-trips';
}

# Functions that don't touch termbox's internal (tb_init-allocated) state, so
# they're safe to call unconditionally, without a TTY.
is tb-strerror(TB_ERR_MEM), 'Out of memory', 'tb-strerror maps a known error code';
ok tb-version().chars > 0, 'tb-version returns a non-empty string';
is tb-attr-width(), 16, 'tb-attr-width matches the vendored header\'s default TB_OPT_ATTR_W';
is tb-has-truecolor(), 0, 'tb-has-truecolor is false at this attr width';
ok tb-wcwidth('A'.ord) >= 0, 'tb-wcwidth of an ASCII char is non-negative';
ok tb-iswprint('A'.ord), 'tb-iswprint is true for a printable ASCII char';

done-testing;
