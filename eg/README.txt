The programs 'hello.raku' and 'editor.raku' are translated from Perl, see
https://metacpan.org/release/SANKO/Termbox-2.00/source/eg

  raku -Ilib eg/hello.raku
  raku -Ilib eg/editor.raku

'eg/editor.raku' is just a framework (mouse-wheel scrolling only), so
'editor-partial.raku' extends it into a partial text editor: arrow-key
cursor movement, character insertion/deletion, and loading/saving a file
given on the command line.

  raku -Ilib eg/editor-partial.raku somefile.txt
