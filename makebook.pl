#!/usr/bin/perl

foreach $switch (@ARGV) {
    if (($switch eq "-quick") or ($switch eq "-q"))
    {
	$quickswitch = 1;
    }
}

$bodylist = `ls *.body.tex`;
@bodies = split(/\s+/,$bodylist);

($sec,$min,$hour,$numday,$month,$year,$wday,$yday,$isdst) = localtime(time);
$year += 1900;
$timestamp = "$year $month $numday $hour $min $sec";

foreach $body (@bodies) {
    ($bookfilename = $body) =~ s/\.body\.tex$//;
    if (-e $bookfilename.".tex") {
	($logfilename = "log/progress-$body") =~ s/\.body\.tex$/-log/;
	print "processing $bookfilename...\n";

	# check for postscript
	open (BODY, "$body") or die "can't open $body: $!\n";
	undef $/;
	$bodytex = <BODY>;
	close BODY;
	if ($bodytex =~ m/\.ps\}/msg) {
	    $pdfswitch = 0;
	}
	else {
	    $pdfswitch = 1;
	}
	    
	if ($pdfswitch == 1) {
	    `perltex --nosafe --latex=xelatex $bookfilename 1>&2`;
	}
	else {
	    `latex $bookfilename 1>&2`;
	}
	unless ($quickswitch == 1) {
	    `bibtex $bookfilename 1>&2`;
	    if ($pdfswitch == 1) {
		`perltex --nosafe --latex=xelatex $bookfilename 1>&2`;
		`perltex --nosafe --latex=xelatex $bookfilename 1>&2`;
	    }
	    else {
		`latex $bookfilename 1>&2`;
		`latex $bookfilename 1>&2`;
	    }
	}
	if ($pdfswitch == 0) {
	    `dvips -o $bookfilename.ps $bookfilename 1>&2`;
	    `epstopdf $bookfilename.ps 1>&2`;
	}

	# if open, bring to front
	# `open $bookfilename.pdf`;
	`open -a preview`;

#	$bookfilename.abs.tex
	`countcheckboxes  $bookfilename.body.tex $bookfilename.supplementary.tex 1>&2`;

#	$bookfilename.abs.tex
	$numtodos = `countcheckboxes-total $bookfilename.body.tex chapters/*.body.tex`;
	chomp $numtodos;

	# extract page and byte numbers
	$texlogfile = $bookfilename.".log";
	open (TEXLOGFILE, "$texlogfile") or die "can't open $texlogfile: $!\n";
	
	undef $/;
	$log = <TEXLOGFILE>;
	$log =~ m/Output written on (.*\)\.)$/ms;
	($line = $1) =~ s/\n//g;
##	print "\n$line\n\n";
	$line =~ m/\((\d+) (pag.*?)/;
	$numpages = $1;

	$numbytes = `stat -f "%z" pocsbook.pdf`;

	close TEXLOGFILE;

	if (($numpages ne "") and ($numbytes ne "")) {
	    open (LOGFILE, ">>$logfilename") or die "Can't open $logfilename: $!\n";
	    print LOGFILE "$timestamp $numtodos $numpages $numbytes\n";
	    close LOGFILE;
	}
	else
	{
	    print "No data logged\n";
	}
	
	$citenum = `grep \"Warning--I didn\'t find a database entry for\" $bookfilename.blg | wc -l`;
	$citenum =~ s/\s//g;
	print "Number of missing citations = $citenum\n";
    }
}
