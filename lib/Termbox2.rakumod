unit module Termbox2;

use NativeCall;

# Values below are transcribed from the vendored resources/termbox2.h
# (termbox2, MIT licensed) and must stay in sync with it.

# Error / status codes, returned by most tb-* functions.

constant TB_OK                   is export(:DEFAULT, :errors) = 0;
constant TB_ERR                  is export(:DEFAULT, :errors) = -1;
constant TB_ERR_NEED_MORE        is export(:DEFAULT, :errors) = -2;
constant TB_ERR_INIT_ALREADY     is export(:DEFAULT, :errors) = -3;
constant TB_ERR_INIT_OPEN        is export(:DEFAULT, :errors) = -4;
constant TB_ERR_MEM              is export(:DEFAULT, :errors) = -5;
constant TB_ERR_NO_EVENT         is export(:DEFAULT, :errors) = -6;
constant TB_ERR_NO_TERM          is export(:DEFAULT, :errors) = -7;
constant TB_ERR_NOT_INIT         is export(:DEFAULT, :errors) = -8;
constant TB_ERR_OUT_OF_BOUNDS    is export(:DEFAULT, :errors) = -9;
constant TB_ERR_READ             is export(:DEFAULT, :errors) = -10;
constant TB_ERR_RESIZE_IOCTL     is export(:DEFAULT, :errors) = -11;
constant TB_ERR_RESIZE_PIPE      is export(:DEFAULT, :errors) = -12;
constant TB_ERR_RESIZE_SIGACTION is export(:DEFAULT, :errors) = -13;
constant TB_ERR_POLL             is export(:DEFAULT, :errors) = -14;
constant TB_ERR_TCGETATTR        is export(:DEFAULT, :errors) = -15;
constant TB_ERR_TCSETATTR        is export(:DEFAULT, :errors) = -16;
constant TB_ERR_UNSUPPORTED_TERM is export(:DEFAULT, :errors) = -17;
constant TB_ERR_RESIZE_WRITE     is export(:DEFAULT, :errors) = -18;
constant TB_ERR_RESIZE_POLL      is export(:DEFAULT, :errors) = -19;
constant TB_ERR_RESIZE_READ      is export(:DEFAULT, :errors) = -20;
constant TB_ERR_RESIZE_SSCANF    is export(:DEFAULT, :errors) = -21;
constant TB_ERR_CAP_COLLISION    is export(:DEFAULT, :errors) = -22;

# ASCII key constants (Event.key)

constant TB_KEY_CTRL_TILDE       is export(:DEFAULT, :keys) = 0x00;
constant TB_KEY_CTRL_2           is export(:DEFAULT, :keys) = 0x00;
constant TB_KEY_CTRL_A           is export(:DEFAULT, :keys) = 0x01;
constant TB_KEY_CTRL_B           is export(:DEFAULT, :keys) = 0x02;
constant TB_KEY_CTRL_C           is export(:DEFAULT, :keys) = 0x03;
constant TB_KEY_CTRL_D           is export(:DEFAULT, :keys) = 0x04;
constant TB_KEY_CTRL_E           is export(:DEFAULT, :keys) = 0x05;
constant TB_KEY_CTRL_F           is export(:DEFAULT, :keys) = 0x06;
constant TB_KEY_CTRL_G           is export(:DEFAULT, :keys) = 0x07;
constant TB_KEY_BACKSPACE        is export(:DEFAULT, :keys) = 0x08;
constant TB_KEY_CTRL_H           is export(:DEFAULT, :keys) = 0x08;
constant TB_KEY_TAB              is export(:DEFAULT, :keys) = 0x09;
constant TB_KEY_CTRL_I           is export(:DEFAULT, :keys) = 0x09;
constant TB_KEY_CTRL_J           is export(:DEFAULT, :keys) = 0x0a;
constant TB_KEY_CTRL_K           is export(:DEFAULT, :keys) = 0x0b;
constant TB_KEY_CTRL_L           is export(:DEFAULT, :keys) = 0x0c;
constant TB_KEY_ENTER            is export(:DEFAULT, :keys) = 0x0d;
constant TB_KEY_CTRL_M           is export(:DEFAULT, :keys) = 0x0d;
constant TB_KEY_CTRL_N           is export(:DEFAULT, :keys) = 0x0e;
constant TB_KEY_CTRL_O           is export(:DEFAULT, :keys) = 0x0f;
constant TB_KEY_CTRL_P           is export(:DEFAULT, :keys) = 0x10;
constant TB_KEY_CTRL_Q           is export(:DEFAULT, :keys) = 0x11;
constant TB_KEY_CTRL_R           is export(:DEFAULT, :keys) = 0x12;
constant TB_KEY_CTRL_S           is export(:DEFAULT, :keys) = 0x13;
constant TB_KEY_CTRL_T           is export(:DEFAULT, :keys) = 0x14;
constant TB_KEY_CTRL_U           is export(:DEFAULT, :keys) = 0x15;
constant TB_KEY_CTRL_V           is export(:DEFAULT, :keys) = 0x16;
constant TB_KEY_CTRL_W           is export(:DEFAULT, :keys) = 0x17;
constant TB_KEY_CTRL_X           is export(:DEFAULT, :keys) = 0x18;
constant TB_KEY_CTRL_Y           is export(:DEFAULT, :keys) = 0x19;
constant TB_KEY_CTRL_Z           is export(:DEFAULT, :keys) = 0x1a;
constant TB_KEY_ESC              is export(:DEFAULT, :keys) = 0x1b;
constant TB_KEY_CTRL_LSQ_BRACKET is export(:DEFAULT, :keys) = 0x1b;
constant TB_KEY_CTRL_3           is export(:DEFAULT, :keys) = 0x1b;
constant TB_KEY_CTRL_4           is export(:DEFAULT, :keys) = 0x1c;
constant TB_KEY_CTRL_BACKSLASH   is export(:DEFAULT, :keys) = 0x1c;
constant TB_KEY_CTRL_5           is export(:DEFAULT, :keys) = 0x1d;
constant TB_KEY_CTRL_RSQ_BRACKET is export(:DEFAULT, :keys) = 0x1d;
constant TB_KEY_CTRL_6           is export(:DEFAULT, :keys) = 0x1e;
constant TB_KEY_CTRL_7           is export(:DEFAULT, :keys) = 0x1f;
constant TB_KEY_CTRL_SLASH       is export(:DEFAULT, :keys) = 0x1f;
constant TB_KEY_CTRL_UNDERSCORE  is export(:DEFAULT, :keys) = 0x1f;
constant TB_KEY_SPACE            is export(:DEFAULT, :keys) = 0x20;
constant TB_KEY_BACKSPACE2       is export(:DEFAULT, :keys) = 0x7f;
constant TB_KEY_CTRL_8           is export(:DEFAULT, :keys) = 0x7f;

# Terminal-dependent key constants (Event.key)

constant TB_KEY_F1               is export(:DEFAULT, :keys) = 0xffff -  0;
constant TB_KEY_F2               is export(:DEFAULT, :keys) = 0xffff -  1;
constant TB_KEY_F3               is export(:DEFAULT, :keys) = 0xffff -  2;
constant TB_KEY_F4               is export(:DEFAULT, :keys) = 0xffff -  3;
constant TB_KEY_F5               is export(:DEFAULT, :keys) = 0xffff -  4;
constant TB_KEY_F6               is export(:DEFAULT, :keys) = 0xffff -  5;
constant TB_KEY_F7               is export(:DEFAULT, :keys) = 0xffff -  6;
constant TB_KEY_F8               is export(:DEFAULT, :keys) = 0xffff -  7;
constant TB_KEY_F9               is export(:DEFAULT, :keys) = 0xffff -  8;
constant TB_KEY_F10              is export(:DEFAULT, :keys) = 0xffff -  9;
constant TB_KEY_F11              is export(:DEFAULT, :keys) = 0xffff - 10;
constant TB_KEY_F12              is export(:DEFAULT, :keys) = 0xffff - 11;
constant TB_KEY_INSERT           is export(:DEFAULT, :keys) = 0xffff - 12;
constant TB_KEY_DELETE           is export(:DEFAULT, :keys) = 0xffff - 13;
constant TB_KEY_HOME             is export(:DEFAULT, :keys) = 0xffff - 14;
constant TB_KEY_END              is export(:DEFAULT, :keys) = 0xffff - 15;
constant TB_KEY_PGUP             is export(:DEFAULT, :keys) = 0xffff - 16;
constant TB_KEY_PGDN             is export(:DEFAULT, :keys) = 0xffff - 17;
constant TB_KEY_ARROW_UP         is export(:DEFAULT, :keys) = 0xffff - 18;
constant TB_KEY_ARROW_DOWN       is export(:DEFAULT, :keys) = 0xffff - 19;
constant TB_KEY_ARROW_LEFT       is export(:DEFAULT, :keys) = 0xffff - 20;
constant TB_KEY_ARROW_RIGHT      is export(:DEFAULT, :keys) = 0xffff - 21;
constant TB_KEY_BACK_TAB         is export(:DEFAULT, :keys) = 0xffff - 22;
constant TB_KEY_MOUSE_LEFT       is export(:DEFAULT, :keys) = 0xffff - 23;
constant TB_KEY_MOUSE_RIGHT      is export(:DEFAULT, :keys) = 0xffff - 24;
constant TB_KEY_MOUSE_MIDDLE     is export(:DEFAULT, :keys) = 0xffff - 25;
constant TB_KEY_MOUSE_RELEASE    is export(:DEFAULT, :keys) = 0xffff - 26;
constant TB_KEY_MOUSE_WHEEL_UP   is export(:DEFAULT, :keys) = 0xffff - 27;
constant TB_KEY_MOUSE_WHEEL_DOWN is export(:DEFAULT, :keys) = 0xffff - 28;

# Modifiers (Event.mod, bitwise)

constant TB_MOD_ALT               is export(:DEFAULT, :keys) = 1;
constant TB_MOD_CTRL              is export(:DEFAULT, :keys) = 2;
constant TB_MOD_SHIFT             is export(:DEFAULT, :keys) = 4;
constant TB_MOD_MOTION            is export(:DEFAULT, :keys) = 8;

# Colors (Cell fg/bg, numeric)

constant TB_DEFAULT               is export(:DEFAULT, :styles) = 0x0000;
constant TB_BLACK                 is export(:DEFAULT, :styles) = 0x0001;
constant TB_RED                   is export(:DEFAULT, :styles) = 0x0002;
constant TB_GREEN                 is export(:DEFAULT, :styles) = 0x0003;
constant TB_YELLOW                is export(:DEFAULT, :styles) = 0x0004;
constant TB_BLUE                  is export(:DEFAULT, :styles) = 0x0005;
constant TB_MAGENTA               is export(:DEFAULT, :styles) = 0x0006;
constant TB_CYAN                  is export(:DEFAULT, :styles) = 0x0007;
constant TB_WHITE                 is export(:DEFAULT, :styles) = 0x0008;

# Attributes (Cell fg/bg, bitwise, combinable with a single color)

constant TB_BOLD                  is export(:DEFAULT, :styles) = 0x0100;
constant TB_UNDERLINE             is export(:DEFAULT, :styles) = 0x0200;
constant TB_REVERSE               is export(:DEFAULT, :styles) = 0x0400;
constant TB_ITALIC                is export(:DEFAULT, :styles) = 0x0800;
constant TB_BLINK                 is export(:DEFAULT, :styles) = 0x1000;
constant TB_HI_BLACK              is export(:DEFAULT, :styles) = 0x2000;
constant TB_BRIGHT                is export(:DEFAULT, :styles) = 0x4000;
constant TB_DIM                   is export(:DEFAULT, :styles) = 0x8000;

# Event types (Event.type)

constant TB_EVENT_KEY             is export(:DEFAULT, :events) = 1;
constant TB_EVENT_RESIZE          is export(:DEFAULT, :events) = 2;
constant TB_EVENT_MOUSE           is export(:DEFAULT, :events) = 3;

# Input / output modes

constant TB_INPUT_CURRENT         is export(:DEFAULT, :modes) = 0;
constant TB_INPUT_ESC             is export(:DEFAULT, :modes) = 1;
constant TB_INPUT_ALT             is export(:DEFAULT, :modes) = 2;
constant TB_INPUT_MOUSE           is export(:DEFAULT, :modes) = 4;

constant TB_OUTPUT_CURRENT        is export(:DEFAULT, :modes) = 0;
constant TB_OUTPUT_NORMAL         is export(:DEFAULT, :modes) = 1;
constant TB_OUTPUT_256            is export(:DEFAULT, :modes) = 2;
constant TB_OUTPUT_216            is export(:DEFAULT, :modes) = 3;
constant TB_OUTPUT_GRAYSCALE      is export(:DEFAULT, :modes) = 4;
constant TB_OUTPUT_TRUECOLOR      is export(:DEFAULT, :modes) = 5;

# A single interaction from the user or the terminal.
#
# 'mod' and 'ch' are valid when 'type' is TB_EVENT_KEY. 'w' and 'h' are valid
# when 'type' is TB_EVENT_RESIZE. 'x' and 'y' are valid when 'type' is
# TB_EVENT_MOUSE. 'key' is valid when 'type' is either TB_EVENT_KEY or
# TB_EVENT_MOUSE. 'key' and 'ch' are mutually exclusive; only one of them is
# non-zero at a time.
class Event is repr('CStruct') is export(:DEFAULT, :events) {
    has uint8  $.type is rw;
    has uint8  $.mod  is rw;
    has uint16 $.key  is rw;
    has uint32 $.ch   is rw;
    has int32  $.w    is rw;
    has int32  $.h    is rw;
    has int32  $.x    is rw;
    has int32  $.y    is rw;
}

# A single cell in the terminal's cell grid (tb-get-cell).
class Cell is repr('CStruct') is export(:DEFAULT, :cells) {
    has uint32 $.ch is rw;
    has uint16 $.fg is rw;
    has uint16 $.bg is rw;
}

constant TERMBOX2 = %?RESOURCES<libraries/termbox2>;

sub tb-init ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_init') {*}

sub tb-init-file ( Str $path --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_init_file') {*}

sub tb-init-fd ( int32 $ttyfd --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_init_fd') {*}

sub tb-init-rwfd ( int32 $rfd, int32 $wfd --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_init_rwfd') {*}

sub tb-shutdown ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_shutdown') {*}

sub tb-width ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_width') {*}

sub tb-height ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_height') {*}

sub tb-clear ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_clear') {*}

sub tb-set-clear-attrs ( uint16 $fg, uint16 $bg --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_clear_attrs') {*}

sub tb-present ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_present') {*}

sub tb-invalidate ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_invalidate') {*}

sub tb-set-cursor ( int32 $cx, int32 $cy --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_cursor') {*}

sub tb-hide-cursor ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_hide_cursor') {*}

sub tb-set-cell ( int32 $x, int32 $y, uint32 $ch, uint16 $fg, uint16 $bg --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_cell') {*}

# For rendering grapheme clusters (e.g. combining diacritical marks); $ch
# holds $nch codepoints that are rendered together in the one cell at (x, y).
sub tb-set-cell-ex ( int32 $x, int32 $y, CArray[uint32] $ch, size_t $nch, uint16 $fg, uint16 $bg --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_cell_ex') {*}

# Shortcut for appending one codepoint to the cell at (x, y), as set by a
# prior tb-set-cell/tb-set-cell-ex call.
sub tb-extend-cell ( int32 $x, int32 $y, uint32 $ch --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_extend_cell') {*}

# $cell must be a defined Pointer (e.g. `my Pointer $cell .= new`) before the
# call; on success it points into the internal cell buffer at (x, y) — use
# `nativecast(Cell, $cell)` to access its fields. That memory may become
# invalid after subsequent calls into the library.
sub tb-get-cell ( int32 $x, int32 $y, int32 $back, Pointer $cell is rw --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_get_cell') {*}

sub tb-print ( int32 $x, int32 $y, uint16 $fg, uint16 $bg, Str $str is encoded('utf8') --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_print') {*}

# As tb-print, but also reports the printed width (in cells) via $out-w.
sub tb-print-ex ( int32 $x, int32 $y, uint16 $fg, uint16 $bg, size_t $out-w is rw, Str $str is encoded('utf8') --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_print_ex') {*}

# Send raw bytes straight to the terminal, bypassing the cell buffer.
# Note on $nbuf: because of is encoded('utf8'), $buf is encoded to UTF-8
# bytes before the native call. Pass the UTF-8 *byte* count (e.g.
# $buf.encode('utf8').bytes), NOT the Raku Str character count ($buf.chars),
# to avoid incorrect length for multi-byte characters.
sub tb-send ( Str $buf is encoded('utf8'), size_t $nbuf --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_send') {*}

sub tb-set-input-mode ( int32 $mode --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_input_mode') {*}

sub tb-set-output-mode ( int32 $mode --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_set_output_mode') {*}

sub tb-peek-event ( Event $event is rw, int32 $timeout-ms --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_peek_event') {*}

sub tb-poll-event ( Event $event is rw --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_poll_event') {*}

# Termbox's internal fds, for integrating into an external poll(2)/select(2)
# loop. tb-poll-event/tb-peek-event must still be called once either becomes
# readable.
sub tb-get-fds ( int32 $ttyfd is rw, int32 $resizefd is rw --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_get_fds') {*}

sub tb-last-errno ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_last_errno') {*}

sub tb-strerror ( int32 $err --> Str )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_strerror') {*}

sub tb-has-truecolor ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_has_truecolor') {*}

sub tb-has-egc ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_has_egc') {*}

sub tb-attr-width ( --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_attr_width') {*}

sub tb-version ( --> Str )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_version') {*}

sub tb-iswprint ( uint32 $ch --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_iswprint') {*}

sub tb-wcwidth ( uint32 $ch --> int32 )
    is native(TERMBOX2) is export(:DEFAULT, :subs) is symbol('tb_wcwidth') {*}

=begin pod

=head1 SOURCE

Source code, issues, and pull requests: L<https://github.com/arnesom/raku-termbox2>

=head1 AUTHOR

Arne Sommer <arne@sommer.pm>

Parts of this distribution were developed with AI assistance (Claude and Qwen).

=head1 COPYRIGHT AND LICENSE

Copyright (c) 2026 Arne Sommer

This Raku binding is licensed under the Artistic License 2.0, the same
license as Raku itself. See the C<LICENSE> file for the full license text.

The vendored C library C<resources/termbox2.h> (and the C<termbox2-impl.c>
wrapper compiled from it) is termbox2, MIT licensed. See the header for the
full license text.

=end pod
