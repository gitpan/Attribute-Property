package Attribute::Property;

# $Id: Property.pm,v 1.25 2003/02/10 08:35:45 juerd Exp $
# v 1.25 -> CPAN as 1.02

use 5.006;
use Attribute::Handlers;
use Carp;
no strict;
no warnings;

our $VERSION = '1.02';

$Carp::Internal{Attribute::Handlers}++;	 # may we be forgiven for our sins
$Carp::Internal{+__PACKAGE__}++;

sub UNIVERSAL::Property : ATTR(CODE,INIT) {
	my (undef, $s, $r) = @_;
	croak "Cannot use Property attribute with anonymous sub" unless ref $s;
	my $n = *$s{NAME};
	*$s = defined &$s
		? sub : lvalue {
			croak "Too many arguments for $n method" if @_ > 2;
			tie my $foo, __PACKAGE__, ${ \$_[0]{$n} }, $r, $_[0],$n;
			@_ == 2 ? ( $foo = $_[1] ) : $foo
		}
		: sub : lvalue {
			croak "Too many arguments for $n method" if @_ > 2;
			@_ == 2 ? ( $_[0]{$n} = $_[1] ) : ${ \$_[0]{$n} }
		};
}

sub TIESCALAR { bless \@_, shift }  # @_ = (class, ref, sub, name)
sub FETCH { $_[0][0] }

sub STORE {
	local $_ = $_[1];
	$_[0][1]->($_[2], $_) or croak "Invalid value for $_[0][3] property";
	$_[0][0] = $_;
}

1;

=head1 NAME

Attribute::Property - Easy lvalue accessors with validation. ($foo->bar = 42)

=head1 SYNOPSIS

=head2 CLASS

    package SomeClass;

    use Attribute::Property;
    use Carp;

    sub new { bless { }, shift }

    sub nondigits : Property { /^\D+\z/ }
    sub digits    : Property { /^\d+\z/ or croak "custom error message" }
    sub anyvalue  : Property;
    sub another   : Property;

    sub value     : Property {
	my $self = shift;  # Object is accessible as $_[0]
	s/^\s+//;          # New value can be altered through $_ or $_[1]

	$_ <= $self->maximum or croak "Value exceeds maximum";
    }

=head2 USAGE

    my $object = SomeClass->new;

    $object->nondigits = "abc";
    $object->digits    = "123";
    $object->anyvalue  = "abc123\n";

    $object->anyvalue('archaic style still works');

    # These would croak
    $object->nondigits = "987";
    $object->digits    = "xyz";

=head1 DESCRIPTION

This module introduces the C<Property> attribute, which turns your method into
an object property.  The original code block is used only to validate new
values, the module croaks if it returns false.

Feel free to croak explicitly if you don't want the default error message.

Undefined subs (subs that have been declared but do not have a code block) with
the C<Property> attribute will be properties without any validation.

In the validation code block, the object is in C<$_[0]> and the value to be
validated is aliased as C<$_[1]> and for regexing convenience as C<$_>.

=head1 PREREQUISITES

Your object must be a blessed hash reference.  The property names will be used
for the hash keys.
    
For class properties of C<Some::Module>, the hash C<%Some::Module> is used, for
class properties of C<Module>, the hash C<%Attribute::Property::Module> is
used.

In short: C<< $foo->bar = 14 >> and C<< $foo->bar(14) >> assign 14 to
C<< $foo->{bar} >> after positive validation.

=head1 COMPATIBILITY

Old fashioned C<< $object->property(VALUE) >> is still available.

This module requires a modern Perl, fossils like Perl 5.00x don't support our
chicanery.

=head1 LICENSE

There is no license.  This software was released into the public domain.  Do
with it what you want, but on your own risk.  Both authors disclaim any
responsibility.

=head1 AUTHORS

Juerd Waalboer <juerd@cpan.org> <http://juerd.nl/>

Matthijs van Duin <pl@nubz.org>

=cut

# vim: ft=perl sts=0 noet sw=8 ts=8

