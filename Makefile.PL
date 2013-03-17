package MY;
use 5.008009;
use ExtUtils::MakeMaker;
# See lib/ExtUtils/MakeMaker.pm for details of how to influence
# the contents of the Makefile that is written.
use warnings;
use strict;
$| = 1;
my @filenames = glob;

our $sf_webaddr = 'http://github.com/LaurentGomila/SFML/tarball/master';

our $sf_tarball = "SFML-source.tgz";

our $sf_cflags      = '';
our $sf_libs        = '';
our $sf_folder      = undef;
our $cmaking_source = 0;

print "
Alien::SFML presents an important message to you:
================>>>IMPORTANT!<<<================
Due to platform inconsistancies, Windows being a pain,
the lack of mice on titan and the general state of the
universe, Alien::SFML has decided to not actually bother
testing your computer to see if it has SFML 2.0 RC
installed unless you use pkg-config.  As a result of this,

IF YOU DO NOT WANT Alien::SFML TO INSTALL ANOTHER COPY
OF SFML 2.0 RC ON YOUR SYSTEM, CTRL+C AND ABORT NOW!

If you choose this method, please tell this script about it:
Set the variables \$PERLSFMLLIBS and \$PERLSFMLCFLAGS to
the appropriate values (the same format as what pkg-config
would give. Makefile.PL will check the above environment
variables first, then try pkg-config then finally just go
ahead and install it. \$PERLSFMLLIBS will be rejected if
it doesn't appear to include a '-l' in it.

Ctrl+C to abort.  Installing in:
";

for (my $i = 10 ; $i >= 0 ; $i--) {
	sleep 1;
	print "$i ";
}
print "\n";

$sf_libs   = $ENV{'PERLSFMLLIBS'};
$sf_cflags = $ENV{'PERLSFMLINCLUDEDIR'};

=pod
if((!defined $sf_libs || !($sf_libs =~ m/\-l/ )) && `pkg-config --modversion sfml-system` =~ /2\.0\.0/){
	print "Using pkg-config!\n";
	$sf_libs = `pkg-config --libs sfml-system sfml-window sfml-graphics`;
	$sf_cflags = `pkg-config --cflags sfml-system sfml-window sfml-graphics`;
	$sf_libs =~ s/\n+//g ;
	$sf_cflags =~ s/\n+//g ;
} else {
	print "Using environment variables\n";
}
=cut

if (!defined $sf_libs || !($sf_libs =~ m/\-l/)) {
	print "Fetching and building sources\n";
	print "Searching for $sf_tarball\n";
	if (!(-e $sf_tarball)) {
		print "Fetching $sf_tarball from $sf_webaddr...\n";
		use HTTP::Tiny;
		my $response = HTTP::Tiny->new->get($sf_webaddr);
		unless ($response->{success}) {
			print STDERR "Fatal: Could not get tarball: " . $response->{status} . " " . $response->{reason} . "\n";
			exit 0;    #Quietly exit for CPANtester's benefit
		}
		open FILE, ">$sf_tarball";
		binmode FILE;
		print FILE $response->{content} if length $response->{content};
		close FILE;
	}

	use Archive::Tar;

	my $tarball = new Archive::Tar($sf_tarball);

	($sf_folder) = $tarball->list_files(['name']);
	print "OK! We should have found ourselves a tarball!\nLets see if we need to unpack it ...\n";

	if (!(-e $sf_folder . "CMakeLists.txt")) {
		print "Yes, it seems to need unpacking. Archive::Tar'ing it...\n";

		$tarball->extract();
	} else {
		print "No, already unpacked!\n";
	}

	if (!((-e $sf_folder . "CMakeLists.txt") && (-e $sf_folder . "readme.txt"))) {
		print STDERR "Fatal: There are vital files missing!\n";
		exit 0;    #Quietly exit for CPANtester's benefit
	} else {
		print "We seem to have a valid setup.\n";
	}

	# And now we have something that looks like some sources in $sf_folder.
	# Of course, we could now run more checks to make sure it is actually
	#  source code from SFML itself, but I don't feel like it.

	# Now looks like a pretty neat time to call in cmake!

	chdir $sf_folder;
	print "Beginning CMAKE\n";
	open FILE, "cmake.log";
	if (-e $sf_folder . "CMakeCache.txt") {
		my $cmake = `cmake CMakeCache.txt`;
		print $cmake;
	} else {
		my $cmake = `cmake CMakeCache.txt`;
		print $cmake;
	}
	print "End CMAKE\n";
	close FILE;
	# Parse what we want from the CMakeCache
	my $ptmp = '';
	open(FILE, "CMakeCache.txt") or die $!;
	while (<FILE>) {
		if ($_ =~ m!CMAKE_INSTALL_PREFIX\:PATH=(.+)\n!ms) {
			$ptmp = $1;
		}
	}
	close(FILE);
	$sf_libs   = "-L" . $ptmp . "/lib/ -lsfml-audio -lsfml-graphics -lsfml-window -lsfml-system";
	$sf_cflags = "-I$ptmp/include/";
}
chdir '..';

print "Using options of libs: '$sf_libs' and cflags: '$sf_cflags'\n";

open(FILE, ">lib/Alien/SFML.pm");

print FILE "package Alien::SFML;

use 5.008009;
use strict;
use warnings;

our \$VERSION = '0.01';

use constant {
	LIBS   => \"$sf_libs\",
	CFLAGS => \"$sf_cflags\" };

1;
__END__

=head1 NAME

Alien::SFML

=head1 SYNOPSIS

  use Alien::SFML;
  \$libs = Alien::SFML::LIBS;
  \$cflags = Alien::SFML::CFLAGS;

=head1 DESCRIPTION

Installs SFML 2.0 RC

=head2 EXPORT

None by default.

=head1 SEE ALSO

Alien::SFML github page:
https://github.com/jakeanq/perl-alien-sfml

SFML github page
https://github.com/jakeanq/perl-sfml

http://www.sfml-dev.org/

=head1 AUTHOR

Jake Bott, E<lt>jake.anq\@gmail.comE<gt>

=head1 COPYRIGHT

Copyright (C) 2013 by Jake Bott

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.

=cut";
close FILE;

WriteMakefile(
	NAME               => 'Alien::SFML',
	clean              => { FILES => 'lib/Alien/SFML.pm' },
	CONFIGURE_REQUIRES => { 'Archive::Tar' => 0, 'HTTP::Tiny' => 0, },
	VERSION_FROM       => 'lib/Alien/SFML.pm',                           # finds $VERSION
	PREREQ_PM          => {},                                            # e.g., Module::Name => 1.1
	AUTHOR             => 'Jake Bott <jake.anq@gmail.com>',);

sub install {                                                            # The code here works, but it doesn't get substituted in the makefile itself.
	my $inherited = shift->SUPER::install(@_);
	if (defined $sf_folder) {
		$inherited .= "
cmake_install : all
	\$(NOECHO) cd $sf_folder; make install

cmake_make : all
	\$(NOECHO) cd $sf_folder; make
";
		$inherited =~ s/(install :: pure_install doc_install)/$1 cmake_install/;
		print "Adding custom makefile sections\n";
	}
	$inherited;
}

sub top_targets {    # The code here should work, although it doesn't get called and all_target might not be correct (A method of MM_Any)
	my $inherited = shift->SUPER::top_targets(@_);
	$inherited =~ s/(all :: pure_all manifypods)/$1 cmake_make/ if defined $sf_folder;
	$inherited;
}


=head1 COPYRIGHT

Copyright (C) 2013 by Jake Bott

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
