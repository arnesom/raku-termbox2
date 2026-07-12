use v6;
use Test;
use lib 'lib';

# Smoke-tests eg/*.raku: each one must at least parse and compile cleanly
# against the current Termbox2 exports, catching e.g. a renamed sub or a
# symbol dropped from an import tag that an example still relies on. This
# runs unconditionally, no TTY required, so it also runs under CI.
#
# Interactive functional coverage (actually running each example and quitting
# via Ctrl-Q) was tried here too, via `script`/`bash`/`timeout` plumbing, but
# proved flaky: it hinges on a fixed delay landing after tb-init's TCSAFLUSH
# switch and before raku itself finishes starting up, a race that varies with
# machine load and isn't worth the fragility for a check that's gated on
# having a real TTY and thus never runs in CI anyway. That verification was
# instead done manually once (see the commit history) and is easy to redo by
# hand: `printf '\x11' | script -qec 'raku -I lib eg/editor.raku' /dev/null`.

my @examples = <eg/hello.raku eg/editor.raku eg/editor-full.raku>;

for @examples -> $eg {
    my $proc = run 'raku', '-c', '-I', 'lib', $eg, :out, :err;
    is $proc.exitcode, 0, "$eg passes a syntax check";
}

done-testing;
