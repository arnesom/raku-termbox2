use v6;
use Test;
use lib 'lib';
use MONKEY-SEE-NO-EVAL;

# Verifies the export set itself, complementing t/02-constants-and-structs.t (which
# checks constant *values*): that `use Termbox2;` imports exactly the
# expected symbols — no more, no less — and that each import tag exposes
# exactly its own category. A typo dropping `is export` from a new symbol,
# or an accidental extra export, would slip past t/02-constants-and-structs.t but is
# caught here.

my constant ALL-SYMBOLS = <
    &tb-attr-width &tb-clear &tb-extend-cell &tb-get-cell &tb-get-fds
    &tb-has-egc &tb-has-truecolor &tb-height &tb-hide-cursor &tb-init
    &tb-init-fd &tb-init-file &tb-init-rwfd &tb-invalidate &tb-iswprint
    &tb-last-errno &tb-peek-event &tb-poll-event &tb-present &tb-print
    &tb-print-ex &tb-send &tb-set-cell &tb-set-cell-ex &tb-set-clear-attrs
    &tb-set-cursor &tb-set-input-mode &tb-set-output-mode &tb-shutdown
    &tb-strerror &tb-version &tb-wcwidth &tb-width

    Cell Event

    TB_BLACK TB_BLINK TB_BLUE TB_BOLD TB_BRIGHT TB_CYAN TB_DEFAULT TB_DIM
    TB_GREEN TB_HI_BLACK TB_ITALIC TB_MAGENTA TB_RED TB_REVERSE TB_UNDERLINE
    TB_WHITE TB_YELLOW

    TB_ERR TB_ERR_CAP_COLLISION TB_ERR_INIT_ALREADY TB_ERR_INIT_OPEN
    TB_ERR_MEM TB_ERR_NEED_MORE TB_ERR_NOT_INIT TB_ERR_NO_EVENT
    TB_ERR_NO_TERM TB_ERR_OUT_OF_BOUNDS TB_ERR_POLL TB_ERR_READ
    TB_ERR_RESIZE_IOCTL TB_ERR_RESIZE_PIPE TB_ERR_RESIZE_POLL
    TB_ERR_RESIZE_READ TB_ERR_RESIZE_SIGACTION TB_ERR_RESIZE_SSCANF
    TB_ERR_RESIZE_WRITE TB_ERR_TCGETATTR TB_ERR_TCSETATTR
    TB_ERR_UNSUPPORTED_TERM TB_OK

    TB_EVENT_KEY TB_EVENT_MOUSE TB_EVENT_RESIZE

    TB_INPUT_ALT TB_INPUT_CURRENT TB_INPUT_ESC TB_INPUT_MOUSE TB_OUTPUT_216
    TB_OUTPUT_256 TB_OUTPUT_CURRENT TB_OUTPUT_GRAYSCALE TB_OUTPUT_NORMAL
    TB_OUTPUT_TRUECOLOR

    TB_KEY_ARROW_DOWN TB_KEY_ARROW_LEFT TB_KEY_ARROW_RIGHT TB_KEY_ARROW_UP
    TB_KEY_BACKSPACE TB_KEY_BACKSPACE2 TB_KEY_BACK_TAB TB_KEY_CTRL_2
    TB_KEY_CTRL_3 TB_KEY_CTRL_4 TB_KEY_CTRL_5 TB_KEY_CTRL_6 TB_KEY_CTRL_7
    TB_KEY_CTRL_8 TB_KEY_CTRL_A TB_KEY_CTRL_B TB_KEY_CTRL_BACKSLASH
    TB_KEY_CTRL_C TB_KEY_CTRL_D TB_KEY_CTRL_E TB_KEY_CTRL_F TB_KEY_CTRL_G
    TB_KEY_CTRL_H TB_KEY_CTRL_I TB_KEY_CTRL_J TB_KEY_CTRL_K TB_KEY_CTRL_L
    TB_KEY_CTRL_LSQ_BRACKET TB_KEY_CTRL_M TB_KEY_CTRL_N TB_KEY_CTRL_O
    TB_KEY_CTRL_P TB_KEY_CTRL_Q TB_KEY_CTRL_R TB_KEY_CTRL_RSQ_BRACKET
    TB_KEY_CTRL_S TB_KEY_CTRL_SLASH TB_KEY_CTRL_T TB_KEY_CTRL_TILDE
    TB_KEY_CTRL_U TB_KEY_CTRL_UNDERSCORE TB_KEY_CTRL_V TB_KEY_CTRL_W
    TB_KEY_CTRL_X TB_KEY_CTRL_Y TB_KEY_CTRL_Z TB_KEY_DELETE TB_KEY_END
    TB_KEY_ENTER TB_KEY_ESC TB_KEY_F1 TB_KEY_F10 TB_KEY_F11 TB_KEY_F12
    TB_KEY_F2 TB_KEY_F3 TB_KEY_F4 TB_KEY_F5 TB_KEY_F6 TB_KEY_F7 TB_KEY_F8
    TB_KEY_F9 TB_KEY_HOME TB_KEY_INSERT TB_KEY_MOUSE_LEFT
    TB_KEY_MOUSE_MIDDLE TB_KEY_MOUSE_RELEASE TB_KEY_MOUSE_RIGHT
    TB_KEY_MOUSE_WHEEL_DOWN TB_KEY_MOUSE_WHEEL_UP TB_KEY_PGDN TB_KEY_PGUP
    TB_KEY_SPACE TB_KEY_TAB TB_MOD_ALT TB_MOD_CTRL TB_MOD_MOTION TB_MOD_SHIFT
>.Set;

my constant TAGGED = %(
    errors => <
        TB_ERR TB_ERR_CAP_COLLISION TB_ERR_INIT_ALREADY TB_ERR_INIT_OPEN
        TB_ERR_MEM TB_ERR_NEED_MORE TB_ERR_NOT_INIT TB_ERR_NO_EVENT
        TB_ERR_NO_TERM TB_ERR_OUT_OF_BOUNDS TB_ERR_POLL TB_ERR_READ
        TB_ERR_RESIZE_IOCTL TB_ERR_RESIZE_PIPE TB_ERR_RESIZE_POLL
        TB_ERR_RESIZE_READ TB_ERR_RESIZE_SIGACTION TB_ERR_RESIZE_SSCANF
        TB_ERR_RESIZE_WRITE TB_ERR_TCGETATTR TB_ERR_TCSETATTR
        TB_ERR_UNSUPPORTED_TERM TB_OK
    >.Set,
    keys => <
        TB_KEY_ARROW_DOWN TB_KEY_ARROW_LEFT TB_KEY_ARROW_RIGHT
        TB_KEY_ARROW_UP TB_KEY_BACKSPACE TB_KEY_BACKSPACE2 TB_KEY_BACK_TAB
        TB_KEY_CTRL_2 TB_KEY_CTRL_3 TB_KEY_CTRL_4 TB_KEY_CTRL_5
        TB_KEY_CTRL_6 TB_KEY_CTRL_7 TB_KEY_CTRL_8 TB_KEY_CTRL_A
        TB_KEY_CTRL_B TB_KEY_CTRL_BACKSLASH TB_KEY_CTRL_C TB_KEY_CTRL_D
        TB_KEY_CTRL_E TB_KEY_CTRL_F TB_KEY_CTRL_G TB_KEY_CTRL_H
        TB_KEY_CTRL_I TB_KEY_CTRL_J TB_KEY_CTRL_K TB_KEY_CTRL_L
        TB_KEY_CTRL_LSQ_BRACKET TB_KEY_CTRL_M TB_KEY_CTRL_N TB_KEY_CTRL_O
        TB_KEY_CTRL_P TB_KEY_CTRL_Q TB_KEY_CTRL_R TB_KEY_CTRL_RSQ_BRACKET
        TB_KEY_CTRL_S TB_KEY_CTRL_SLASH TB_KEY_CTRL_T TB_KEY_CTRL_TILDE
        TB_KEY_CTRL_U TB_KEY_CTRL_UNDERSCORE TB_KEY_CTRL_V TB_KEY_CTRL_W
        TB_KEY_CTRL_X TB_KEY_CTRL_Y TB_KEY_CTRL_Z TB_KEY_DELETE TB_KEY_END
        TB_KEY_ENTER TB_KEY_ESC TB_KEY_F1 TB_KEY_F10 TB_KEY_F11 TB_KEY_F12
        TB_KEY_F2 TB_KEY_F3 TB_KEY_F4 TB_KEY_F5 TB_KEY_F6 TB_KEY_F7
        TB_KEY_F8 TB_KEY_F9 TB_KEY_HOME TB_KEY_INSERT TB_KEY_MOUSE_LEFT
        TB_KEY_MOUSE_MIDDLE TB_KEY_MOUSE_RELEASE TB_KEY_MOUSE_RIGHT
        TB_KEY_MOUSE_WHEEL_DOWN TB_KEY_MOUSE_WHEEL_UP TB_KEY_PGDN
        TB_KEY_PGUP TB_KEY_SPACE TB_KEY_TAB TB_MOD_ALT TB_MOD_CTRL
        TB_MOD_MOTION TB_MOD_SHIFT
    >.Set,
    styles => <
        TB_BLACK TB_BLINK TB_BLUE TB_BOLD TB_BRIGHT TB_CYAN TB_DEFAULT
        TB_DIM TB_GREEN TB_HI_BLACK TB_ITALIC TB_MAGENTA TB_RED TB_REVERSE
        TB_UNDERLINE TB_WHITE TB_YELLOW
    >.Set,
    events => < Event TB_EVENT_KEY TB_EVENT_MOUSE TB_EVENT_RESIZE >.Set,
    modes => <
        TB_INPUT_ALT TB_INPUT_CURRENT TB_INPUT_ESC TB_INPUT_MOUSE
        TB_OUTPUT_216 TB_OUTPUT_256 TB_OUTPUT_CURRENT TB_OUTPUT_GRAYSCALE
        TB_OUTPUT_NORMAL TB_OUTPUT_TRUECOLOR
    >.Set,
    subs => <
        &tb-attr-width &tb-clear &tb-extend-cell &tb-get-cell &tb-get-fds
        &tb-has-egc &tb-has-truecolor &tb-height &tb-hide-cursor &tb-init
        &tb-init-fd &tb-init-file &tb-init-rwfd &tb-invalidate
        &tb-iswprint &tb-last-errno &tb-peek-event &tb-poll-event
        &tb-present &tb-print &tb-print-ex &tb-send &tb-set-cell
        &tb-set-cell-ex &tb-set-clear-attrs &tb-set-cursor
        &tb-set-input-mode &tb-set-output-mode &tb-shutdown &tb-strerror
        &tb-version &tb-wcwidth &tb-width
    >.Set,
    cells => < Cell >.Set,
);

sub termbox2-symbols ($keys) {
    $keys.keys.grep({ .starts-with('TB_') || .starts-with('&tb-')
                       || $_ eq 'Event' || $_ eq 'Cell' }).Set;
}

subtest 'Bare use imports every symbol, and nothing else' => {
    my @before = MY::.keys;
    my @after  = do { use Termbox2; MY::.keys };
    is-deeply termbox2-symbols(@after (-) @before),
        ALL-SYMBOLS, 'use Termbox2 (bare) imports exactly the full symbol set';
}

subtest ':ALL imports every symbol, same as bare use' => {
    my @before = MY::.keys;
    my @after  = do { use Termbox2 :ALL; MY::.keys };
    is-deeply termbox2-symbols(@after (-) @before),
        ALL-SYMBOLS, 'use Termbox2 :ALL imports exactly the full symbol set';
}

for TAGGED.kv -> $tag, $expected {
    subtest ":$tag imports exactly its own category" => {
        my @before = MY::.keys;
        my @after  = EVAL "use Termbox2 :$tag; MY::.keys";
        is-deeply termbox2-symbols(@after (-) @before),
            $expected, ":$tag imports exactly the expected symbols";
    }
}

done-testing;
