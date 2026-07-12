#! /usr/bin/env raku

use v6;
use Termbox2;

# Source: https://metacpan.org/release/SANKO/Termbox-2.00/source/eg/hello.pl

my @chars = 'hello, world!'.comb;
my $code  = tb-init();
die tb-strerror($code) if $code != TB_OK;
tb-clear();
my @rows = (
    ( TB_WHITE,   TB_BLACK   ),
    ( TB_BLACK,   TB_DEFAULT ),
    ( TB_RED,     TB_GREEN   ),
    ( TB_GREEN,   TB_RED     ),
    ( TB_YELLOW,  TB_BLUE    ),
    ( TB_MAGENTA, TB_CYAN    ),
);
for @rows.kv -> $row, @colors {
    for @chars.kv -> $col, $chr {
        tb-set-cell( $col, $row, $chr.ord, |@colors );
    }
}
tb-present();
sleep 3;
tb-shutdown();
