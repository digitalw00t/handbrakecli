#! /usr/bin/perl

# hdtv, anim, movie

# usage:  batch_mp4.pl <preset>


use strict;
use File::Copy;

my $preset = lc $ARGV[0];
my $doit   = lc $ARGV[1];

my $indir      = "/opt/cli_handbrake/drop/";
my $outdir     = "/opt/cli_handbrake/dump/";
my $ext        = "TS";
my $ext1       = "mp4";
my $hbcli      = "/usr/bin/HandBrakeCLI";
$hbcli         = "/opt/cli_handbrake/bin/HandBrakeCLI";
my $cmd = "ls -1 $indir | egrep '\.(mp4|MP4|M2TS|TS)'";
print "CMD: $cmd\n";
my @files      = `$cmd`;
my $flags      = &get_flags($preset);
my @test;
my $tmpVar       = 0;
my $count=@files;

$SIG{INT} = sub {
    print "Yup.. we're outta here!\n";
    exit();
};

print "\n$count Files to process:\n\n";
print "################\n";

foreach my $foo (@files) {
   chomp $foo;
   if ($foo =~ /\.$ext$/) {
   	print "$foo\n";
   } else {
   	print "$foo : Wont process not a .$ext file\n";
   }
}
print "\n\n";

while (@files ne @test) {
	
	if ($tmpVar > 0) { @files = @test; }
	&process;
	@test = `ls -1 $indir | grep .$ext`;
	$tmpVar++;
}

sub process {

	print "Starting processing...\n\n";

	foreach my $infile (@files) {
        	chomp $infile;
        	print "FILE : $infile\n\n";

		my $foo = $infile;
		$foo =~ s/\.$ext$//;
		print "$foo\n\n";
		my $outfile = $foo . ".$ext1";
		my $logfile = $foo . ".log";

		if (-e "$outdir/$outfile") {
			print "$outdir/$outfile -- EXISTS!!!! SKIPPING!!!\n\n";
			if (-e "$outdir/$foo.lock") { next; }
			elsif ($doit eq "doit") { move ("$indir/$infile", "$indir/done/"); }
                        next;
		}

        	if (-e "$outdir/$foo.lock") {
                	print "FILE processed by parallel process\n\n";
        	} else {

                	# lock
                	system ("touch '$outdir/$foo.lock'");

                	my $cmd = "$hbcli $flags -i \"$indir/$infile\" -o \"$outdir/$outfile\"";
			print "CLI CMD: ---> $cmd\n\n";

			print "Command: $cmd\n";
                	if ($doit eq "doit") { system($cmd); }

                	if (-e "$outdir/$outfile") {
                        	print "Encode seems to have produced something!\n";
				if ($doit eq "doit") {
					# make the done directory if it doesn't already exist
					mkdir "$indir/done" if (! -e "$indir/done/");
                                	move ("$indir/$infile", "$indir/done/");
                        	}
                	} else {
				# error detected
                        	#system ("mv \"$infile\" error");
                	}

                	# unlock
#			unlink "$outdoor/$foo.lock";
                	system ("rm '$outdir/$foo.lock'");
       
        	}
	}
}

sub get_flags {

	my $preset = shift;
	my ($x264_opts,$video_opts,$audio_opts);
	my @psets;
	my %validArgs = (
		'hdtv' => 1,
		'anim' => 1,
		'movie' => 1
	);

	foreach my $foo (sort keys %validArgs) {
		push (@psets, $foo);
	}

	my $pset = join ('|',@psets);

	if (not defined $validArgs{$preset}) {
		print "\n\t --usage $0 preset [doit]\n\n";
		print "\t $0 $pset [doit]\n\n";
		exit 1;
	}


	if ($preset eq "hdtv") {

		$x264_opts  = 'mixed-refs:bframes=6:weightb:direct=auto:b-pyramid=0:me=umh:subme=9:analyse=all:nr=150:no-fast-pskip=1:psy-rd=1,1';
		$video_opts = "-b 1500";
		$audio_opts = "-E copy";
	
	} elsif ($preset eq "anim") {

		$x264_opts  = 'mixed-refs:bframes=6:weightb:direct=auto:b-pyramid=0:me=umh:subme=9:analyse=all:nr=150:no-fast-pskip=1:psy-rd=1,1';
		$video_opts = "-b 1000";
		$audio_opts = "-E copy";
	
	} elsif ($preset eq "movie") {

		$x264_opts  = 'mixed-refs:bframes=6:weightb:direct=auto:b-pyramid=0:me=umh:subme=9:analyse=all:nr=150:no-fast-pskip=1:psy-rd=1,1';
		$video_opts = "-b 3000";
		$audio_opts = "-E copy";
	
	}
	
	my $flags = "--optimize -f $ext1 -m -2 -T -e x264 -x $x264_opts $video_opts $audio_opts";

	return($flags);
}
