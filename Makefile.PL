use 5.006;
use ExtUtils::MakeMaker;

# $Id: Makefile.PL,v 1.9 2003/02/08 18:19:42 xmath Exp $
# vim: ft=perl sts=0 noet sw=8 ts=8

WriteMakefile(
	NAME		=> 'Attribute::Property',
	VERSION_FROM	=> 'Property.pm',
	PREREQ_PM	=> { Attribute::Handlers => 0 },
	ABSTRACT_FROM	=> 'Property.pm',
	AUTHOR		=> 'Juerd <juerd@cpan.org>',
);
