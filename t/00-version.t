use v6;
use Test;
use lib 'lib';
use JSON::Fast;
use Termbox2;

plan 2;

my $meta = from-json 'META6.json'.IO.slurp;

is Termbox2.^ver.Str, $meta<version>,
    'module :ver matches META6.json version';

my @versions = 'Changes'.IO.lines.map({ /^ (\d+ '.' \d+ '.' \d+) ' - '/ ?? ~$0 !! Empty });

is @versions.tail, $meta<version>,
    'META6.json version matches the latest (last-listed) Changes entry';
