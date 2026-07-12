use v6;
use Test;
use lib 'lib';
use NativeCall;
use Termbox2;

my $can-init = $*IN.t && !$*ENV<TERMBOX_SKIP_TTY>;
if $can-init {
    # Error path: opening a nonexistent tty file fails before anything is
    # initialized, and tb-last-errno reflects the underlying open(2) errno.
    is tb-init-file('/nonexistent/path/for/termbox2-test'), TB_ERR_INIT_OPEN,
        'tb-init-file fails with TB_ERR_INIT_OPEN for a bad path';
    ok tb-last-errno() > 0, 'tb-last-errno reflects the open(2) failure';

    # tb-init() itself — the entry point every eg/*.raku example calls on
    # startup — equivalent to tb-init-file('/dev/tty').
    is tb-init(), TB_OK, 'tb-init succeeds on a TTY';
    is tb-shutdown(), TB_OK, 'tb-shutdown succeeds after tb-init';

    # Each alternate init entry point (tb-init-file, tb-init-fd,
    # tb-init-rwfd) is exercised in its own short init/shutdown cycle. These
    # deliberately avoid fd 0/1: when run under `prove`, fd 1 is the pipe it
    # reads TAP output from, and termbox2 writing raw escape codes into that
    # same fd would corrupt the TAP stream. Fresh /dev/tty opens sidestep
    # that entirely. tb_deinit only closes fds it opened itself (i.e. via
    # tb-init-file), so fds handed to tb-init-fd/tb-init-rwfd are ours to
    # close after shutdown.
    is tb-init-file('/dev/tty'), TB_OK, 'tb-init-file succeeds on a TTY path';
    is tb-shutdown(), TB_OK, 'tb-shutdown succeeds after tb-init-file';

    my $fd-tty = '/dev/tty'.IO.open(:rw);
    is tb-init-fd($fd-tty.native-descriptor), TB_OK,
        'tb-init-fd succeeds on a dedicated /dev/tty fd';
    is tb-shutdown(), TB_OK, 'tb-shutdown succeeds after tb-init-fd';
    $fd-tty.close;

    my $rfd-tty = '/dev/tty'.IO.open(:r);
    my $wfd-tty = '/dev/tty'.IO.open(:w);
    is tb-init-rwfd($rfd-tty.native-descriptor, $wfd-tty.native-descriptor), TB_OK,
        'tb-init-rwfd succeeds on dedicated, distinct /dev/tty read/write fds';

    ok tb-width() > 0,  'tb-width is positive once initialized';
    ok tb-height() > 0, 'tb-height is positive once initialized';

    is tb-set-cursor(2, 3), TB_OK, 'tb-set-cursor succeeds';
    is tb-hide-cursor(),    TB_OK, 'tb-hide-cursor succeeds';
    is tb-invalidate(),     TB_OK, 'tb-invalidate succeeds';

    is tb-set-clear-attrs(TB_YELLOW, TB_BLUE), TB_OK,
        'tb-set-clear-attrs succeeds';
    is tb-clear(), TB_OK, 'tb-clear succeeds';
    my Pointer $cleared-ptr .= new;
    is tb-get-cell(0, 0, 1, $cleared-ptr), TB_OK,
        'tb-get-cell succeeds on a cleared cell';
    my $cleared-cell = nativecast(Cell, $cleared-ptr);
    is $cleared-cell.fg, TB_YELLOW,
        'tb-clear applies the fg set by tb-set-clear-attrs';
    is $cleared-cell.bg, TB_BLUE,
        'tb-clear applies the bg set by tb-set-clear-attrs';

    is tb-set-cell(0, 0, 'X'.ord, TB_RED, TB_BLACK), TB_OK, 'tb-set-cell succeeds';
    my Pointer $cell-ptr .= new;
    is tb-get-cell(0, 0, 1, $cell-ptr), TB_OK, 'tb-get-cell succeeds';
    my $cell = nativecast(Cell, $cell-ptr);
    is $cell.ch, 'X'.ord, 'tb-get-cell reflects the cell set by tb-set-cell';
    is $cell.fg, TB_RED,   'tb-get-cell reflects the fg set by tb-set-cell';
    is $cell.bg, TB_BLACK, 'tb-get-cell reflects the bg set by tb-set-cell';

    # Without TB_OPT_EGC, tb-set-cell-ex stores only the first codepoint,
    # silently ignoring the rest (see README's "Not bound behavior").
    my $cluster = CArray[uint32].new;
    $cluster[0] = 'Y'.ord;
    $cluster[1] = 'Z'.ord;
    is tb-set-cell-ex(1, 0, $cluster, 2, TB_GREEN, TB_DEFAULT), TB_OK,
        'tb-set-cell-ex succeeds';
    my Pointer $ex-cell-ptr .= new;
    is tb-get-cell(1, 0, 1, $ex-cell-ptr), TB_OK,
        'tb-get-cell succeeds on the tb-set-cell-ex cell';
    my $ex-cell = nativecast(Cell, $ex-cell-ptr);
    is $ex-cell.ch, 'Y'.ord,
        'tb-set-cell-ex keeps only the first codepoint without TB_OPT_EGC';

    # Also documented in README: needs TB_OPT_EGC, so always TB_ERR here.
    is tb-extend-cell(1, 0, 'W'.ord), TB_ERR,
        'tb-extend-cell returns TB_ERR without TB_OPT_EGC';

    my size_t $out-w = 0;
    is tb-print-ex(0, 1, TB_DEFAULT, TB_DEFAULT, $out-w, 'hi'), TB_OK,
        'tb-print-ex succeeds';
    is $out-w, 2, 'tb-print-ex reports the printed width in cells';

    is tb-send(' ', ' '.encode('utf8').bytes), TB_OK, 'tb-send succeeds';

    is tb-set-input-mode(TB_INPUT_ESC), TB_OK,
        'tb-set-input-mode returns TB_OK when setting a mode';
    is tb-set-input-mode(TB_INPUT_CURRENT), TB_INPUT_ESC,
        'tb-set-input-mode(TB_INPUT_CURRENT) reports the mode set earlier';

    is tb-set-output-mode(TB_OUTPUT_256), TB_OK,
        'tb-set-output-mode returns TB_OK when setting a mode';
    is tb-set-output-mode(TB_OUTPUT_CURRENT), TB_OUTPUT_256,
        'tb-set-output-mode(TB_OUTPUT_CURRENT) reports the mode set earlier';

    my Event $event .= new;
    is tb-peek-event($event, 10), TB_ERR_NO_EVENT,
        'tb-peek-event times out with TB_ERR_NO_EVENT when nothing is typed';

    my int32 $ttyfd = -1;
    my int32 $resizefd = -1;
    is tb-get-fds($ttyfd, $resizefd), TB_OK, 'tb-get-fds succeeds';
    ok $ttyfd >= 0,    'tb-get-fds reports a valid ttyfd';
    ok $resizefd >= 0, 'tb-get-fds reports a valid resizefd';

    is tb-present(), TB_OK, 'tb-present succeeds';

    is tb-shutdown(), TB_OK, 'tb-shutdown succeeds after tb-init-rwfd';
    $rfd-tty.close;
    $wfd-tty.close;
}
else {
    skip 'requires an interactive TTY (set TERMBOX_SKIP_TTY=1 to force-skip in CI)', 41;
}

done-testing;
