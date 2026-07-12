#! /usr/bin/env raku

use v6;
use Termbox2;

# Source: https://metacpan.org/release/SANKO/Termbox-2.00/source/eg/editor.pl
#
# Re-themed from the original's 24-bit solarized colors to this module's
# 16-bit TB_* colors/attributes: this distribution's build doesn't enable
# TB_OPT_ATTR_W=32, the flag that would be needed for truecolor support
# (see README's "Not bound behavior"). Also extended beyond the original,
# which only reacted to the mouse wheel and Ctrl-Q: arrow keys now move the
# cursor, typed characters are inserted into the buffer, a filename given on
# the command line is opened for editing, and Ctrl-S saves it.

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

my $filename = @*ARGS[0];
my @lines = $filename.defined && $filename.IO.f
    ?? ( $filename.IO.lines.List || ('',) )
    !! ('',);

my $title = $filename.defined ?? $filename !! $*PROGRAM-NAME;
$title ~= ' [New File]' unless $filename.defined && $filename.IO.f;

my $cx     = 0;      # cursor column (0-indexed, into @lines[$cy])
my $cy     = 0;      # cursor row (0-indexed, into @lines)
my $top    = 0;      # index of the first visible buffer line
my $status = '';

sub visible-rows { tb-height() - 2 }

sub scroll-to-cursor {
    $top = $cy if $cy < $top;
    $top = $cy - visible-rows() + 1 if $cy > $top + visible-rows() - 1;
    $top = 0 if $top < 0;
}

sub draw {
    scroll-to-cursor();
    tb-clear();

    # title
    tb-print( 0, 0, %theme<base02>, %theme<base1>, ' ' x tb-width() );
    tb-print( 0, 0, %theme<base02> +| TB_BOLD, %theme<base1>, " 🦪 $title" );

    my $text-width = tb-width() - 6;    # gutter (5 cols) + scrollbar (1 col)
    for 1 .. visible-rows() -> $line {
        my $idx = $top + $line - 1;
        tb-print( 0, $line, %theme<base0>, %theme<base02>, sprintf ' %3d ', $idx + 1 );
        tb-print( 5, $line, %theme<base0>, %theme<base03>, @lines[$idx].substr( 0, $text-width ) )
            if $idx < @lines.elems;

        # scrollbar
        my $thumb = @lines.elems > visible-rows()
            ?? 1 + ( $top * ( visible-rows() - 1 ) / ( @lines.elems - visible-rows() ) ).round
            !! 1;
        tb-print( tb-width() - 1, $line, %theme<base0>, %theme<base02>,
            $line == $thumb ?? '◧' !! '┃' );
    }

    # status bar
    my $help = 'Press Ctrl-Q to quit' ~ ( $filename.defined ?? ', Ctrl-S to save' !! '' );
    tb-print( 0, tb-height() - 1, %theme<blue>, %theme<base02>, ' ' x tb-width() );
    tb-print( 0, tb-height() - 1, %theme<blue>, %theme<base02>, $help );
    tb-print( $help.chars + 2, tb-height() - 1, %theme<magenta>, %theme<base02>, $status );

    tb-set-cursor( 5 + $cx, 1 + $cy - $top );
    tb-present();
}

draw();
my Event $ev .= new;
while !tb-poll-event($ev) {
    $status = sprintf 'event: type=%d mod=%d key=%d ch=%d w=%d h=%d x=%d y=%d',
        $ev.type, $ev.mod, $ev.key, $ev.ch, $ev.w, $ev.h, $ev.x, $ev.y;

    last if $ev.key == TB_KEY_CTRL_Q && $ev.mod == TB_MOD_CTRL;

    if $ev.type == TB_EVENT_KEY {
        given $ev.key {
            when TB_KEY_ARROW_LEFT {
                if $cx > 0    { $cx-- }
                elsif $cy > 0 { $cy--; $cx = @lines[$cy].chars }
            }
            when TB_KEY_ARROW_RIGHT {
                if $cx < @lines[$cy].chars { $cx++ }
                elsif $cy < @lines.end     { $cy++; $cx = 0 }
            }
            when TB_KEY_ARROW_UP {
                if $cy > 0 { $cy--; $cx = min( $cx, @lines[$cy].chars ) }
            }
            when TB_KEY_ARROW_DOWN {
                if $cy < @lines.end { $cy++; $cx = min( $cx, @lines[$cy].chars ) }
            }
            when TB_KEY_ENTER {
                my $line = @lines[$cy];
                @lines[$cy] = $line.substr( 0, $cx );
                @lines.splice( $cy + 1, 0, $line.substr($cx) );
                $cy++; $cx = 0;
            }
            when TB_KEY_BACKSPACE | TB_KEY_BACKSPACE2 {
                if $cx > 0 {
                    my $line = @lines[$cy];
                    @lines[$cy] = $line.substr( 0, $cx - 1 ) ~ $line.substr($cx);
                    $cx--;
                }
                elsif $cy > 0 {
                    $cx = @lines[ $cy - 1 ].chars;
                    @lines[ $cy - 1 ] ~= @lines[$cy];
                    @lines.splice( $cy, 1 );
                    $cy--;
                }
            }
            when TB_KEY_DELETE {
                if $cx < @lines[$cy].chars {
                    my $line = @lines[$cy];
                    @lines[$cy] = $line.substr( 0, $cx ) ~ $line.substr( $cx + 1 );
                }
                elsif $cy < @lines.end {
                    @lines[$cy] ~= @lines[ $cy + 1 ];
                    @lines.splice( $cy + 1, 1 );
                }
            }
            when TB_KEY_CTRL_S {
                if $filename.defined {
                    spurt $filename, @lines.join("\n") ~ "\n";
                    $title  = $filename;
                    $status ~= ' -- saved';
                }
                else {
                    $status ~= ' -- no filename to save to';
                }
            }
            default {
                if $ev.ch {
                    my $line = @lines[$cy];
                    @lines[$cy] = $line.substr( 0, $cx ) ~ $ev.ch.chr ~ $line.substr($cx);
                    $cx++;
                }
            }
        }
    }
    elsif $ev.type == TB_EVENT_MOUSE {
        $top-- if $ev.key == TB_KEY_MOUSE_WHEEL_UP   && $top > 0;
        $top++ if $ev.key == TB_KEY_MOUSE_WHEEL_DOWN && $top < @lines.elems - visible-rows();
    }

    draw();
}
tb-shutdown();
