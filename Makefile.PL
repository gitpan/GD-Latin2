
use ExtUtils::MakeMaker;
use Cwd;
use Config;
use File::Copy;

$| = 1;

use subs qw( prompt );

print <<EOF;
This package is not an actual package. It's just a patch that adds
ISO-8859-2 fonts into libdg. Please read the README file if you are
curious what's going on.
First, we will look around for the GD module distribution. You have to
have it untarred somewhere around.
EOF

my @dirs = <../GD-[0-9]* GD-[0-9]*>;
push @dirs, <~/.cpan/build/GD-[0-9]*> unless getcwd =~ /\.cpan/;

my %versionhash = map { my ($ver) = /GD-([-.\d]+)/;
		defined $ver ? ($_, /GD-([-.\d]+)/) : () } @dirs;
my @sorted = sort { $versionhash{$b} cmp $versionhash{$a} } keys %versionhash;

my $gddir;
unless (@sorted)
	{
	$gddir = prompt "I couldn't find any GD distribution around. You can tell me where it is or\n'q' will abort:";
	}
elsif (@sorted == 1)
	{
	$gddir = prompt "I have found the GD distribution in $sorted[0] but you can correct me if I am\nwrong ('q' aborts):";
	}
else
	{
	print "The following GD distributions were found\n";
	for (@dirs)
		{ print "$_\n"; }
	$gddir = prompt "Which is the correct one? ('q' aborts)\n[$sorted[0]]";
	}

if ($gddir =~ /^\s*$/ and @sorted)
	{ $gddir = $sorted[0];}

if ($gddir =~ /^\s*q\s*$/)
	{
	print "Empty gddir, aborting\n";
	exit;
	}

if (! -d $gddir)
	{ die "Directory $gddir doesn't seem to exist, aborting\n"; }


print "Copying fonts to $gddir/libgd\n";
my $name;
for $name (<fonts/*>)
	{
	$name =~ s!fonts/!!;
	### print "Copying fonts/$name to $gddir/libgd\n";
	copy "fonts/$name", "$gddir/libgd" or die "Copy failed: $!\n";
	}

print "Copying test.out.5.gif to $gddir/t\n";
copy 'test.out.5.gif', "$gddir/t";


print "Patching $gddir/libgd/libgd.c\n";
open IN, "$gddir/libgd/libgd.c" or die "Error reading $gddir/libgd/libgd.c: $!\n";
open OUT, "> $gddir/libgd/libgd.c.new" or die "Error writing $gddir/libgd/libgd.c.new: $!\b";
while (<IN>)
	{
	s/void gdImageCharUp\(gdImagePtr im, gdFontPtr f, int x, int y, char c, int color\)/void gdImageCharUp(gdImagePtr im, gdFontPtr f, int x, int y, int c, int color)/;
	s/gdImageChar(Up)?\(im, f, x, y, s\[i\], color\);/gdImageChar$1(im, f, x, y, (unsigned char)s[i], color);/;
	print OUT $_;
	}
close OUT;
close IN;

rename "$gddir/libgd/libgd.c.new", "$gddir/libgd/libgd.c" or die "Rename $gddir/libgd/libgd.c.new $gddir/libgd/libgd.c failed: $!\n";



print "Patching $gddir/libgd/gd.h\n";
open IN, "$gddir/libgd/gd.h" or die "Error reading $gddir/libgd/gd.h: $!\n";
open OUT, "> $gddir/libgd/gd.h.new" or die "Error writing $gddir/libgd/gd.h.new: $!\b";
while (<IN>)
	{
	s/void gdImageCharUp\(gdImagePtr im, gdFontPtr f, int x, int y, char c, int color\)/void gdImageCharUp(gdImagePtr im, gdFontPtr f, int x, int y, int c, int color)/;
	print OUT $_;
	}
close OUT;
close IN;

rename "$gddir/libgd/gd.h.new", "$gddir/libgd/gd.h" or die "Rename $gddir/libgd/gd.h.new $gddir/libgd/gd.h failed: $!\n";




my $lns = $Config{'lns'};
unlink 'gddir' if -r 'gddir';
system "$lns $gddir gddir";

sub MY::install
	{
	package MY;
	my $install = shift->SUPER::install(@_);
	$install =~ s/doc_install/doc_install install_gd/;
	$install;
	}

sub MY::postamble
	{
	"
install_gd :
	cd $gddir && $^X Makefile.PL && make && make test && make install

";
	}

WriteMakefile(
	NAME		=> 'GD::Latin2',
	VERSION		=> 0.53,
	MAN3PODS	=> { 'Latin2.pm' => '$(INST_MAN3DIR)/GD::Latin2.3' },
	PM		=> {},
	### DIR		=> [ 'gddir' ],
	macro		=> { 'GD_DIR' => $answer },
	dist		=> { COMPRESS => 'gzip -9f', SUFFIX => 'gz',
		POSTOP => 'mv $(DISTNAME)-$(VERSION).tar.gz ../' },
);


