use v6;
use LibraryMake;

class Build {
    method build ($dir) {
        my %vars = get-vars($dir);
        %vars<termbox2> = $*VM.platform-library-name('termbox2'.IO);

        mkdir "$dir/resources" unless "$dir/resources".IO.e;
        mkdir "$dir/resources/libraries" unless "$dir/resources/libraries".IO.e;

        # 1. Fetch the permitted .txt file and write it to the root as Makefile.in
        my $template = "$dir/resources/build-instructions.txt".IO;
        if $template.e {
            $template.copy("$dir/Makefile.in");
        } else {
            die "Could not find build-instructions.txt in resources!";
        }

        # 2. Run LibraryMake process-makefile (it reads root Makefile.in -> Makefile)
        process-makefile($dir, %vars);

        my $goback = $*CWD;
        chdir($dir);
        shell(%vars<MAKE>);
        chdir($goback);

        # 3. Clean up the generated root Makefile and temp layout files
        "$dir/Makefile".IO.unlink if "$dir/Makefile".IO.e;
        "$dir/Makefile.in".IO.unlink if "$dir/Makefile.in".IO.e;
    }
}
