Termbox2
========

Raku `NativeCall` bindings to [termbox2](https://github.com/termbox/termbox2), a
small C library for writing text-based user interfaces.

termbox2 is a single-header, dependency-free C library, vendored in this
distribution as `resources/termbox2.h` (MIT licensed, see the header for the
full license text). It is compiled into a shared library at install time by
`Build.rakumod`, using [`LibraryMake`](https://github.com/retupmoca/P6-LibraryMake)
for cross-platform compiler/linker flags — no external build system, and no
dependency beyond a C compiler.

This distribution's `eg/` examples are adapted from Sanko Robinson's
[`Termbox`](https://metacpan.org/release/SANKO/Termbox-2.00) Perl module,
which binds the same termbox2 library. This module's own design — in
particular the tagged exports described under "Import tags" below — was
inspired by [José Joaquín Atria's `Termbox`](https://raku.land/cpan:JJATRIA/Termbox),
the original Raku binding to termbox2's predecessor, the now-unmaintained
`termbox` v1 library.

`resources/termbox2.h` carries two local patches on top of upstream:

- In `init_cap_trie()`: terminfo databases (e.g. `xterm-256color`) often
  declare arrow/Home/End keys only in their "application mode" (SS3, `\eOA`-
  style) form, but not every terminal emulator reliably switches into that
  mode even though termbox2 requests it (`smkx`) on init — leaving those keys
  dead. The patch registers the classic ANSI/CSI normal-mode forms (`\e[A`,
  etc.) as fallback aliases alongside whatever terminfo provides, so those
  keys work regardless of the terminal's actual cursor-key mode.
- In the `struct tb_event` doc comment: upstream claims `TB_MOD_CTRL`/
  `TB_MOD_SHIFT` are "only set as modifiers to `TB_KEY_ARROW_*`", which
  contradicts its own `extract_event()` (ASCII control keys also set
  `TB_MOD_CTRL`) and cap-trie mod tables (Home/End/Insert/Delete/PgUp/PgDn/
  F1-F12 also carry `TB_MOD_*` combinations). The patch corrects the comment
  to match the actual behavior.

Reapply both patches if `termbox2.h` is ever updated from upstream.

Usage
-----

```raku
use Termbox2 :ALL;

tb-init();
tb-set-cell(0, 0, 'X'.ord, TB_WHITE, TB_BLACK);
tb-present();

my $event = Event.new;
tb-poll-event($event);

tb-shutdown();
```

API
---

Every public, non-deprecated function in the vendored `termbox2.h` is bound
except for a handful documented under "Not bound" below. All `tb-*`
functions return `TB_OK` (`0`) on success, or a negative `TB_ERR_*` code
(`tb-strerror`/`tb-version`/`tb-wcwidth`/`tb-iswprint` return something else;
noted below).

- **Init / shutdown**
  - `tb-init()` — equivalent to `tb-init-file('/dev/tty')`.
  - `tb-init-file($path)`, `tb-init-fd($ttyfd)`, `tb-init-rwfd($rfd, $wfd)` —
    initialize against a specific path or file descriptor(s) instead of
    `/dev/tty`.
  - `tb-shutdown()`.
- **Screen**
  - `tb-width()`, `tb-height()` — current terminal dimensions.
  - `tb-clear()` — clear the back buffer, using `TB_DEFAULT` or the attributes
    set by `tb-set-clear-attrs`.
  - `tb-set-clear-attrs($fg, $bg)`.
  - `tb-present()` — flush the back buffer to the terminal.
  - `tb-invalidate()` — force the next `tb-present()` to redraw everything,
    rather than just what changed.
- **Cursor**
  - `tb-set-cursor($cx, $cy)`, `tb-hide-cursor()`.
- **Cells**
  - `tb-set-cell($x, $y, $ch, $fg, $bg)` — set a single cell. `$ch` is a
    Unicode codepoint (e.g. `'X'.ord`); `$fg`/`$bg` are `TB_*` colors,
    optionally combined with `TB_BOLD`/`TB_UNDERLINE`/etc. via `+|`.
  - `tb-set-cell-ex($x, $y, $ch, $nch, $fg, $bg)` — as `tb-set-cell`, but
    `$ch` is a `CArray[uint32]` of `$nch` codepoints rendered together as one
    grapheme cluster (e.g. a base character plus combining marks).
  - `tb-extend-cell($x, $y, $ch)` — append one codepoint to the cell at
    `($x, $y)`, as set by a prior `tb-set-cell`/`tb-set-cell-ex` call.
  - `tb-get-cell($x, $y, $back, $cell)` — read a cell back. `$cell` must be a
    defined `Pointer` (`my Pointer $cell .= new`) before the call; on success
    it points into the internal buffer, so use `nativecast(Cell, $cell)` to
    read its `.ch`/`.fg`/`.bg`. `$back` selects the back buffer (true) or the
    front buffer (false, i.e. what's actually on screen after the last
    `tb-present()`).
  - `Cell` — a `CStruct` with `ch`, `fg`, `bg` fields, matching termbox2's
    `struct tb_cell` (grapheme-cluster fields are omitted — see "Not bound
    behavior" below).
- **Printing**
  - `tb-print($x, $y, $fg, $bg, $str)` — print a UTF-8 string starting at
    `($x, $y)`.
  - `tb-print-ex($x, $y, $fg, $bg, $out-w, $str)` — as `tb-print`, but also
    reports the printed width in cells via `$out-w` (a `size_t $out-w is
    rw`).
  - `tb-send($buf, $nbuf)` — write `$nbuf` raw bytes straight to the
    terminal, bypassing the cell buffer.
- **Input**
  - `tb-set-input-mode($mode)`, `tb-set-output-mode($mode)` — see
    `TB_INPUT_*` and `TB_OUTPUT_*`.
  - `tb-poll-event($event)`, `tb-peek-event($event, $timeout-ms)` — block (or
    block with a timeout) for the next `Event`.
  - `tb-get-fds($ttyfd, $resizefd)` — termbox's internal file descriptors
    (both `int32 is rw` out-params), for integrating into an external
    `poll(2)`/`select(2)` loop instead of calling `tb-poll-event` directly.
    `tb-poll-event`/`tb-peek-event` must still be called once either becomes
    readable.
  - `Event` — a `CStruct` with `type`, `mod`, `key`, `ch`, `w`, `h`, `x`, `y`
    fields, matching termbox2's `struct tb_event` exactly.
- **Introspection**
  - `tb-last-errno()` — the C `errno` behind the last error, where
    applicable.
  - `tb-strerror($err)` — a human-readable `Str` for a `TB_ERR_*` code.
  - `tb-has-truecolor()`, `tb-has-egc()` — whether this build was compiled
    with 32/64-bit attributes and extended grapheme cluster support,
    respectively (both `0`/false in this distribution's default build — see
    below).
  - `tb-attr-width()` — bit width of `fg`/`bg` attributes for this build
    (`16` in this distribution's default build).
  - `tb-version()` — the linked termbox2 version, as a `Str`.
  - `tb-iswprint($ch)` — whether codepoint `$ch` is printable.
  - `tb-wcwidth($ch)` — display width (in cells) of codepoint `$ch`.
- `TB_*` constants for colors, attributes, keys, modifiers, event types,
  input/output modes, and error codes — see `lib/Termbox2.rakumod`,
  transcribed directly from the vendored header.

### Import tags

`use Termbox2;` (bare, or with `:ALL`) imports everything, as in the
example above. Everything is also available under a narrower tag, to avoid
pulling the full symbol set into scope:

| Tag        | Contents                                                     |
|------------|----------------------------------------------------------------|
| `:errors`  | `TB_OK`, `TB_ERR*`                                            |
| `:keys`    | `TB_KEY_*`, `TB_MOD_*`                                        |
| `:styles`  | Colors (`TB_DEFAULT`..`TB_WHITE`) and attributes (`TB_BOLD`..`TB_DIM`) |
| `:events`  | `TB_EVENT_*`, `Event`                                         |
| `:modes`   | `TB_INPUT_*`, `TB_OUTPUT_*`                                   |
| `:cells`   | `Cell`                                                        |
| `:subs`    | Every `tb-*` function                                          |

For example, `use Termbox2 :keys, :subs;` imports just the key constants and
functions, without the color/style/event/mode constants. `t/03-exports.t`
asserts that each tag (and bare `use`/`:ALL`) imports exactly its documented
symbols — no more, no less.

### Not bound

- **`tb_printf`, `tb_printf_ex`, `tb_sendf`** — these are variadic C
  functions (`const char *fmt, ...`). NativeCall in the Rakudo version this
  was developed against (2025.02) has no support for calling variadic C
  functions, and binding them with a fixed, argument-less signature would be
  unsafe: termbox2's C implementation would read uninitialized stack memory
  for any `%`-specifier in the format string with no corresponding argument.
  Use Raku's own `sprintf` followed by `tb-print`/`tb-send` instead (see
  `eg/editor.raku`), which covers the same use case safely.
- **`tb_set_func`** — upstream marks this "Deprecated" in the header itself.
  Binding it would additionally require marshalling a Raku closure as a C
  function pointer callback, which is fragile territory in NativeCall. Given
  the deprecation, that risk isn't worth taking on.
- **`tb_cell_buffer`** — upstream marks this "Deprecated" in the header.
- **`tb_utf8_char_length`, `tb_utf8_char_to_unicode`, `tb_utf8_unicode_to_char`**
  — UTF-8 byte-length/codepoint conversions that Raku's native `Str`,
  `.ord`, and `.chr` already provide; binding them would just duplicate
  built-in functionality.

### Not bound *behavior*

This distribution's shared library is built with termbox2's defaults: 16-bit
`fg`/`bg` attributes (`TB_OPT_ATTR_W` unset) and extended grapheme cluster
support disabled (`TB_OPT_EGC` unset) — confirmed at runtime by
`tb-attr-width()` returning `16` and `tb-has-egc()` returning `0`. Practical
effects:

- `TB_OUTPUT_TRUECOLOR` mode and 24-bit hex colors are not usable — `fg`/`bg`
  truncate to 16 bits. Stick to the 8 basic `TB_*` colors (or 256-color mode
  via `tb-set-output-mode(TB_OUTPUT_256)`, which fits in 16 bits).
  `eg/editor.raku` documents this in more detail, having hit it directly.
  Rebuilding with `-DTB_OPT_ATTR_W=32` (and widening the `uint16`
  `fg`/`bg` parameters throughout `lib/Termbox2.rakumod` to `uint32`) would
  enable it, at the cost of changing already-committed public signatures.
  This is a library-wide, deliberate build choice — see the git history for
  the discussion, if considering it.
- `tb-extend-cell` always returns `TB_ERR`, and `tb-set-cell-ex` silently
  ignores any codepoints past the first — both need `TB_OPT_EGC`.
- `Cell` omits termbox2's `ech`/`nech`/`cech` fields (only present under
  `TB_OPT_EGC`); adding them would require conditionally compiling two
  different `struct tb_cell` layouts, which none of this binding's callers
  currently need.

Migrating from Termbox (v1)
----------------------------

[José Joaquín Atria's `Termbox`](https://raku.land/cpan:JJATRIA/Termbox) binds
the older, now-unmaintained `termbox` v1 C library. termbox2 is a distinct,
actively developed successor — not a drop-in `.so` swap — so moving code from
`Termbox` to `Termbox2` means updating the Raku call sites, not just the
`use` line. The two APIs are similar enough that most of that is mechanical:

- **Change the `use` line.** `use Termbox :ALL;` becomes `use Termbox2;` —
  bare `use Termbox2;` already imports everything (see "Import tags" above).
  `Termbox` exports nothing without a tag; `Termbox2` exports everything
  *without* one, and the same tag names (`:keys`, `:styles`, `:events`,
  `:modes`, `:errors`, `:subs`) carry over if you were relying on `Termbox`'s
  tagged imports, plus a new `:cells` tag for `Cell`.

- **Three functions were renamed** (same signature, new name):

  | `Termbox` (v1)              | `Termbox2`         |
  |------------------------------|---------------------|
  | `tb-select-input-mode($m)`   | `tb-set-input-mode($m)`  |
  | `tb-select-output-mode($m)`  | `tb-set-output-mode($m)` |
  | `tb-change-cell($x,$y,$ch,$fg,$bg)` | `tb-set-cell($x,$y,$ch,$fg,$bg)` |

- **Some `Termbox` functions have no direct replacement:**
  - `tb-put-cell($x, $y, $cell)` — call `tb-set-cell($x, $y, $cell.ch, $cell.fg, $cell.bg)` instead.
  - `tb-blit($x, $y, $w, $h, $cell)` — loop `tb-set-cell` over the region instead; termbox2 has no blit-a-rect call.
  - `tb-cell-buffer()` — upstream marks the underlying `tb_cell_buffer` deprecated; not bound (see "Not bound" above). Read cells back one at a time with `tb-get-cell` instead.
  - `tb-utf8-char-to-unicode`/`tb-utf8-unicode-to-char` (and the `tb-encode-string`/`tb-decode-string` wrappers built on them) — use Raku's own `.ord`/`.chr` (see "Not bound" above).
  - `TB_HIDE_CURSOR` — `Termbox` exported this constant but never actually bound a function that accepted it; `Termbox2` instead has a real `tb-hide-cursor()` (and `tb-set-cursor($cx, $cy)` to show/move it).

- **Error handling is far more thorough.** `Termbox` only reports failure
  from `tb-init()`, as one of 3 negative constants (`TB_EUNSUPPORTED_TERMINAL`,
  `TB_EFAILED_TO_OPEN_TTY`, `TB_EPIPE_TRAP_ERROR`) — there's no named success
  value, just check for a negative return. In `Termbox2`, nearly every
  `tb-*` function returns `TB_OK` (`0`) on success or one of 22 `TB_ERR_*`
  codes (see the "API" section above) — check `!= TB_OK` throughout, not
  just after init.

- **Always use the named `TB_*` constants, never hardcoded numbers.**
  termbox2 added `TB_KEY_BACK_TAB`, which didn't exist in v1 — this shifts
  every terminal-dependent key constant from `TB_KEY_MOUSE_LEFT` onward down
  by one raw value (e.g. `TB_KEY_MOUSE_LEFT` is `0xffff - 22` in `Termbox`
  but `0xffff - 23` in `Termbox2`). Code that already used the constant
  names migrates transparently; code with hardcoded integers won't.

- **New attributes and an output mode**: `TB_ITALIC`, `TB_BLINK`,
  `TB_HI_BLACK`, `TB_BRIGHT`, `TB_DIM`, and `TB_OUTPUT_TRUECOLOR` don't exist
  in `Termbox`.

- **`Event.key` no longer needs a manual sign fix.** `Termbox`'s `Event`
  wraps its private `$!key` in a `method key` that corrects for negative
  values (`$!key < 0 ?? $!key + 0xFFFF + 1 !! $!key`) — a workaround for a
  NativeCall `uint16`-in-`CStruct` signedness quirk. `Termbox2`'s
  `Event.key` is a plain `uint16 $.key is rw` and returns the correct
  unsigned value directly (confirmed by this distribution's own tests); drop
  any equivalent correction in migrated code.

Development
-----------

```
zef install . --force-test
```

requires only a C compiler (`cc`) and `make` — no Python, no git submodules,
unlike the original `Termbox` binding to the (now unmaintained) `termbox` v1
library.

Source
------

Source code, issues, and pull requests: [github.com/arnesom/raku-termbox2](https://github.com/arnesom/raku-termbox2)

Author
------

Arne Sommer <arne@sommer.pm>

Parts of this distribution were developed with AI assistance (Claude and Qwen).

License
-------

This Raku binding is licensed under the Artistic License 2.0, the same
license as Raku itself. See [LICENSE](LICENSE) for the full text.

The vendored `resources/termbox2.h` (and the `termbox2-impl.c` wrapper
compiled from it) is termbox2, MIT licensed — see the header for the full
license text.
