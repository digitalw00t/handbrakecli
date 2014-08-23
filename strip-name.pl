#!/usr/bin/perl

# Purpose:  to make sure there are recursive mp4 extensions on the tail end of the files in the cwd


my @extensions = (
	'mp4',
	'MP4'
);

my $pwd = `pwd`; chomp $pwd;


my @rec = ();

foreach $foo (`find . -maxdepth 1 -type f`)
{
	chomp $foo;

	if (valid_extension( $foo ))
	{
		print "Valid\n";
		push @rec, $foo;
	}
}

foreach $foo (@rec) {
	undef $new;

	$new = $1 if ($foo =~ /^(.*)\.0.M2TS$/);
	$new = $1 if ($foo =~ /^(.*)\.0.MP4$/);
	$new = $1 if ($foo =~ /^(.*)\.MP4.mp4$/i);
	$new = $1 if ($foo =~ /^(.*)\.TS.0.mp4$/i);
	$new = $1 if ($foo =~ /^(.*)\.MP4.0.MP4.mp4$/i);

	print "New: $new\tOld: $foo\n";

	system("mv $foo $new.mp4") if ($new ne '');
}
sub valid_extension( $ )
{
	my $tmp = shift @_;

	my $bobo = undef;

	foreach $bobo (@extensions)
	{
		return 1 if ($tmp =~ /.*$bobo$/i);
	}
}

__END__
Another way to do this
ls vandread-s02e*.TS.0.mp4|sed 's/\(.*\).TS.0.mp4/ mv & \1.mp4/'|bash
