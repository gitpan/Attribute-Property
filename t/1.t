# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# $Id: 1.t,v 1.8 2003/02/09 00:45:46 juerd Exp $

use lib 't/lib';
use Test::More tests => 33;
no strict;
no warnings;

BEGIN { use_ok('Attribute::Property') };

our $ok;

{
	package X;
	sub new { bless { }, shift }
	sub digits : Property { /^\d+$/ }
	sub any : Property;
	sub fail : Property { 0 }
	sub du_is_13 : Property { $ok = $_ == 13; 1 }
	sub du1_is_13 : Property { $ok = $_[1] == 13; 1 }
	sub du1_is_du : Property { $_ = 14; $ok = $_[1] == $_; 1 }
	sub du_is_du1 : Property { $_[1] = 14; $ok = $_ == $_[1]; 1 }
	sub foo2bar_du : Property { s/foo/bar/ }
	sub foo2bar_du1 : Property { $_[1] =~ s/foo/bar/ }
	sub ok2one : Property { $ok = 1 }
	sub ok2zero : Property { $ok = 0 }
}

my $x = X->new;

can_ok($x, qw(digits any fail));

$ok = 0; $x->ok2one = 1;
ok($ok, "assignment executes code");
$ok = 1; $x->ok2zero;
ok($ok, "retrieval doesn't execute code");

ok($x->digits = 123, "lvalue assignment");
ok($x->digits == 123, "lvalue assignment succeededs");
ok($x->digits == 123, "value doesn't change after test");

ok($x->digits(456), "archaic assignment");
ok($x->digits == 456, "archaic assignment succeeded");
ok($x->digits == 456, "value doesn't change after test");

ok($x->any = "foo", "validationless lvalue assignment");
ok($x->any eq "foo", "validationless lvalue assignment succeeds");
ok($x->any eq "foo", "value doesn't change after test");

ok($x->any("bar"), "validationless archaic assignment");
ok($x->any eq "bar", "validationless archaic assignment succeeds");

ok(!eval { $x->fail = 1 }, "invalid lvalue assignment #1");
ok($x->fail != 1, "invalid lvalue assignment #1 fails succesfully");

ok(!eval { $x->digits = "abc" }, "invalid lvalue assignment #2");
ok($x->digits ne 'abc', "invalid lvalue assignment #2 fails succesfully");

ok(!eval { $x->fail(2) }, "invalid archaic assignment #1");
ok($x->fail != 2, "invalid archaic assignment #1 fails succesfully");

ok(!eval { $x->digits("def") }, "invalid archaic assignment #2");
ok($x->digits ne 'def', "invalid archaic assignment #2 fails succesfully");

$ok = 0; $x->du_is_13 = 13;
ok($ok, "\$_ is set properly");
$ok = 0; $x->du1_is_13 = 13;
ok($ok, "\$_[1] is set properly");

$ok = 0; $x->du_is_du1 = 1;
ok($ok, "\$_ and \$_[1] are proper aliases #1");
$ok = 0; $x->du1_is_du = 1;
ok($ok, "\$_ and \$_[1] are proper aliases #2");

$x->foo2bar_du = 'foo';
ok($x->foo2bar_du eq 'bar', "Changing \$_ changes property value");

$x->foo2bar_du1 = 'foo';
ok($x->foo2bar_du1 eq 'bar', "Changing \$_[1] changes property value");

{ $x->any = 1; my $foo = \$x->any; $$foo = 2; }
ok($x->any == 2, "reference holds #1");

{ my $foo = \($x->any = 3); $$foo = 4; }
ok($x->any == 4, "reference holds #2");

{
    my $foo = \$x->digits; 
    ok(!eval { $$foo = "abc"; 1 }, "changing reference fails");
    ok($x->digits ne "abc", "changing reference fails succesfully");
}

# vim: ft=perl sts=0 noet sw=8 ts=8
