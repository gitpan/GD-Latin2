=head1 NAME

GD::Latin2 - ISO-8859-2 support for GD module

=head1 SYNOPSIS

If you have successfully aplied this patch and reinstalled GD, you can
call string with parameters containing ISO-Latin-2 characters and they
will be correctly displayed in the gifs.

=head1 DESCRIPTION

This is a patch that replaces standard ASCII-only fonts in libgd, used
by GD module, by those with full 256 char Latin2 support. In order to
put new fonts into the library, the source has to be changed and the
library recompiled. That's why you need to have untarred GD library
ready before aplying this patch.

=head1 INSTALLATION

This is my attempt to make the patch easily installable. However, it
may fail on your configuration, but do not worry -- you can patch the
GD/gdlib yourself, see below.

Unpack this distribution next to unpacked GD distribution. Then run

	perl Makefile.PL
	make
	make install

You will be prompted for a directory containing the untarred GD
distribution. Then the files containing the fonts are replaced with
those with ISO-8859-2. Also, one minor patch is aplied to the libgd.c
in order to make it 8-bit clean. And, the fifth test output gif (that
contains some texts) is also replaced, so that the tests run OK.

You can of course do all this by hand: the fonts are in the fonts
directory, you should copy them into the libgd directory in GD
distribution. Then apply the patch in file libgd.diff to libgd.c file
in GD distribution.

=head1 OTHER CHARSETS

In this package, I have also included my little script B<bdftogd> that
creates gd font definitions from those in bdf file format. So you can
run your favorite ISO-8859-1 or so fonts through it and make use of
them.

=head1 BUGS

You have to reinstal this patch whenever you upgrade your GD package.

The small font has changed from 6x12 to 6x13 in ISO-8859-2 version.

The bdftogd convertor is really a simple hack that suits my needs. You
are welcome to find problems and send me patches to make it more general.

=head1 VERSION

0.51

=head1 AUTHOR

Jan Pazdziora, adelton@fi.muni.cz

http://www.fi.muni.cz/~adelton/

at Faculty of Informatics, Masaryk University in Brno, Czech Republic

