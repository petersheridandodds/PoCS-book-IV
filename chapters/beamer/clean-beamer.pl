#!/usr/bin/perl

$usage = "clean-beamer.pl file1.beamer.tex [file2.beamer.tex ...]

remove main beamer structures, replacing as necessary,
to prepare for book or article format.

replaces beamer with cleaned

move to directory above and shift into .body.tex format

do not overwrite edited .body files!

";

undef $/;
foreach $file (@ARGV) {
    if ($file =~ m/\.beamer\.tex/) {
	($outfile = $file) =~ s/beamer/cleaned/;
	open (FILE, "$file") or die "can't open $file: $!\n";
	open (OUTFILE, ">$outfile") or die "can't open $file: $!\n";

	$beamerlatex = <FILE>;

	$beamerlatex =~ s/<.*?>//g;

	$beamerlatex =~ s/\\begin{frame}.*?$//msg;
	$beamerlatex =~ s/\\end{frame}.*?$//msg;

	$beamerlatex =~ s/\\frametitle/\\textbf/g;

	$beamerlatex =~ s/\\begin{block}/\\textbf/g;
	$beamerlatex =~ s/\\end{block}//g;

	$beamerlatex =~ s/\\uncover//g;
	$beamerlatex =~ s/\\only//g;
	$beamerlatex =~ s/\\visible//g;
	$beamerlatex =~ s/\\invisible//g;
	$beamerlatex =~ s/\\onslide//g;

	$beamerlatex =~ s/\\changelecturelogo/\\changelogo/g;
	
	$beamerlatex =~ s/\\begin{columns}.*?$//msg;
	$beamerlatex =~ s/\\end{columns}.*?$//msg;
	$beamerlatex =~ s/\\begin{column}.*?$//msg;
	$beamerlatex =~ s/\\end{column}.*?$//msg;
	$beamerlatex =~ s/\\column{.*?}//msg;

	$beamerlatex =~ s/\\begin{overprint}$//msg;
	$beamerlatex =~ s/\\end{overprint}$//msg;
	
        # remove all lists?
	# some will need to be rebuilt
	$beamerlatex =~ s/\\item//msg;
	$beamerlatex =~ s/\\begin{itemize}//msg;
	$beamerlatex =~ s/\\end{itemize}//msg;
	$beamerlatex =~ s/\\begin{enumerate}//msg;
	$beamerlatex =~ s/\\end{enumerate}//msg;

	# remove center environment
	$beamerlatex =~ s/\\begin{center}//msg;
	$beamerlatex =~ s/\\end{center}//msg;
	$beamerlatex =~ s/\\centering//msg;

	# restructure figures as margin figures by default
	$beamerlatex =~ s/\\includegraphics\[.*?\]{(.*?)}/\n\\begin{marginfigure}[]\n  \\includegraphics[width=\\textwidth]{\1}\n\\end{marginfigure}\n/msg;

#	$beamerlatex =~ s/\\includegraphics\[.*?\]{(.*?)}/fooooooooooo/msg;

	# remove debris
	$beamerlatex =~ s/\\textbf{}//g;
	$beamerlatex =~ s/\[\]//msg;

	# remove multiple blank lines
	$beamerlatex =~ s/\n\s*?\n\s*?\n+/\n/g;
	

	print "Cleaning $file ...\n";
	print OUTFILE $beamerlatex;

	close FILE;
	close OUTFILE;
    } else {
	print "Ignoring $file ... (expecting *.beamer.tex) \n";
    }
}
