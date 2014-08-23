#!/usr/bin/perl

my $filename = $ARGV[0];


foreach $foo (@ARGV) {
	chomp $foo;
	print "Foo: $foo\n";
	$filename = $foo;
	$filename =~ s/\.mkv/\.mp4/gi;
	$filename =~ s/\.flv/\.mp4/gi;
	$filename =~ s/\.avi/\.mp4/gi;

	$cmd = "ffmpeg -acodec copy -vcodec copy -i $foo $filename";
	print "CMD: $cmd\n";
	system($cmd);
}

