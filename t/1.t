# Before `make install' is performed this script should be runnable with
# `make test'. After `make install' it should work as `perl 1.t'

#########################

# $Id: 1.t,v 1.7 2003/02/08 18:19:42 xmath Exp $

use lib 't/lib';
use Test::More tests => 21;
no strict;
no warnings;

BEGIN { use_ok('Attribute::Property') };

{
	package X;
	sub new { bless { }, shift }
	sub digits : Property { /^\d+$/ }
	sub any : Property;
	sub fail : Property { 0 }
}

my $x = X->new;

can_ok($x, qw(digits any fail));

ok($x->digits = 123, "lvalue assignment");
ok($x->digits == 123, "lvalue assignment succeeded");
ok($x->digits == 123, "value didn't change after test");

ok($x->digits(456), "archaic assignment");
ok($x->digits == 456, "archaic assignment succeeded");
ok($x->digits == 456, "value didn't change after test");

ok($x->any = "foo", "validationless lvalue assignment");
ok($x->any eq "foo", "validationless lvalue assignment succeeded");
ok($x->any eq "foo", "value didn't change after test");

ok($x->any("bar"), "validationless archaic assignment");
ok($x->any eq "bar", "validationless archaic assignment succeeded");

ok(!eval { $x->fail = 1 }, "invalid lvalue assignment 1");
ok($x->fail != 1, "invalid lvalue assignment 1 failed");

ok(!eval { $x->digits = "abc" }, "invalid lvalue assignment 2");
ok($x->digits ne 'abc', "invalid lvalue assignment 2 failed succesfully");

ok(!eval { $x->fail(2) }, "invalid archaic assignment 1");
ok($x->fail != 2, "invalid archaic assignment 1 failed succesfully");

ok(!eval { $x->digits("def") }, "invalid archaic assignment 2");
ok($x->digits ne 'def', "invalid archaic assignment 2 failed succesfully");

# vim: ft=perl sts=0 noet sw=8 ts=8
