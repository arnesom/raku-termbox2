#! /usr/bin/env raku

use v6;
use Termbox2;

# Source: https://metacpan.org/release/SANKO/Termbox-2.00/source/eg/editor.pl
#
# Re-themed from the original's 24-bit solarized colors to this module's
# 16-bit TB_* colors/attributes: this distribution's build doesn't enable
# TB_OPT_ATTR_W=32, the flag that would be needed for truecolor support
# (see README's "Not bound behavior").

my $code = tb-init();
die tb-strerror($code) if $code != TB_OK;

my %theme =
    base03  => TB_BLACK,
    base02  => TB_BLACK,
    base0   => TB_WHITE,
    base1   => TB_WHITE,
    blue    => TB_BLUE,
    magenta => TB_MAGENTA,
;

tb-set-input-mode( TB_INPUT_ESC +| TB_INPUT_ALT +| TB_INPUT_MOUSE );
tb-set-clear-attrs( %theme<base0>, %theme<base03> );

my $spos   = 3;    # scroll position
my $status = '';

sub draw {
    tb-clear();

    # title
    tb-print( 0, 0, %theme<base02>, %theme<base1>, ' ' x tb-width() );
    tb-print( 0, 0, %theme<base02> +| TB_BOLD, %theme<base1>,
        " 🦪 $*PROGRAM-NAME - [New File]" );

    for 1 .. tb-height() - 2 -> $line {
        tb-print( 0, $line, %theme<base0>, %theme<base02>, sprintf ' %3d ', $line );

        # scrollbar
        tb-print( tb-width() - 1, $line, %theme<base0>, %theme<base02>,
            $line == $spos ?? '◧' !! '┃' );
    }

    # status bar
    tb-print( 0,  tb-height() - 1, %theme<blue>,    %theme<base02>, ' ' x tb-width() );
    tb-print( 0,  tb-height() - 1, %theme<blue>,    %theme<base02>, 'Press Ctrl-Q to quit' );
    tb-print( 22, tb-height() - 1, %theme<magenta>, %theme<base02>, $status );

    tb-present();
}

draw();
my Event $ev .= new;
while !tb-poll-event($ev) {
    $status = sprintf 'event: type=%d mod=%d key=%d ch=%d w=%d h=%d x=%d y=%d',
        $ev.type, $ev.mod, $ev.key, $ev.ch, $ev.w, $ev.h, $ev.x, $ev.y;
    last if $ev.key == TB_KEY_CTRL_Q && $ev.mod == TB_MOD_CTRL;
    $spos-- if $ev.key == TB_KEY_MOUSE_WHEEL_UP   && $spos > 1;
    $spos++ if $ev.key == TB_KEY_MOUSE_WHEEL_DOWN && $spos < tb-height() - 2;
    draw();
}
tb-shutdown();
