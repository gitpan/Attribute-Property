# $Id: 1.t,v 1.16 2003/02/10 08:30:07 juerd Exp $
# make; perl -Iblib/lib t/1.t

use lib 't/lib';
use Test::More tests => 99;
no strict;
no warnings;

BEGIN { use_ok('Attribute::Property') };

my $ok;

{
	package X::X;
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
	sub DESTROY { $ok = 2; }
	BEGIN { *begin = sub : Property { 1 } }
}

my $object = X::X->new;

for my $y ([ $object => 'object' ], [ "X::X" => 'class' ]) {

my $x = $y->[0];
my $z = "($y->[1])";

can_ok($x, qw(digits any fail du_is_13 du1_is_13 du1_is_du du_is_du1 foo2bar_du
              foo2bar_du1 ok2one ok2zero DESTROY));

$ok = 0; $x->ok2one = 1;
ok($ok, "$z assignment executes code");
$ok = 1; $x->ok2zero;
ok($ok, "$z retrieval doesn't execute code");

ok($x->digits = 123, "$z lvalue assignment");
ok($x->digits == 123, "$z lvalue assignment succeeds");
ok($x->digits == 123, "$z value doesn't change after test");
ok($x->{digits} == 123, "$z hash element gets set with lvalue assignment");

ok($x->digits(456), "$z archaic assignment");
ok($x->digits == 456, "$z archaic assignment succeeds");
ok($x->digits == 456, "$z value doesn't change after test");
ok($x->{digits} == 456, "$z hash element gets set with archaic assignment");

ok($x->any = "foo", "$z validationless lvalue assignment");
ok($x->any eq "foo", "$z validationless lvalue assignment succeeds");
ok($x->any eq "foo", "$z value doesn't change after test");
ok($x->{any} eq "foo", "$z hash element gets set with validationless lvalue " .
                       "assignment");

ok($x->any("bar"), "$z validationless archaic assignment");
ok($x->any eq "bar", "$z validationless archaic assignment succeeds");

ok(!eval { $x->fail = 1 }, "$z invalid lvalue assignment #1");
ok($@ =~ /fail property/, "$z error message mentions property name 'fail'");
ok($x->fail != 1, "$z invalid lvalue assignment #1 fails succesfully #1");
ok($x->{fail}!=1, "$z invalid lvalue assignment #1 fails succesfully #2");

ok(!eval { $x->digits = "abc" }, "$z invalid lvalue assignment #2");
ok($@ =~ /digits property/, "$z error message mentions property name 'digits'");
ok($x->digits ne 'abc', "$z invalid lvalue assignment #2 fails succesfully #1");
ok($x->{digits}ne'abc', "$z invalid lvalue assignment #2 fails succesfully #2");

ok(!eval { $x->fail(2) }, "$z invalid archaic assignment #1");
ok($@ =~ /fail property/, "$z error message mentions property name 'fail'");
ok($x->fail != 2, "$z invalid archaic assignment #1 fails succesfully #1");
ok($x->{fail}!=2, "$z invalid archaic assignment #1 fails succesfully #2");

ok(!eval { $x->digits("def") }, "$z invalid archaic assignment #2");
ok($@ =~ /digits property/, "$z error message mentions property name 'digits'");
ok($x->digits ne 'def',"$z invalid archaic assignment #2 fails succesfully #1");
ok($x->{digits}ne'def',"$z invalid archaic assignment #2 fails succesfully #2");

$ok = 0; $x->du_is_13 = 13;
ok($ok, "$z \$_ is set properly");
$ok = 0; $x->du1_is_13 = 13;
ok($ok, "$z \$_[1] is set properly");

$ok = 0; $x->du_is_du1 = 1;
ok($ok, "$z \$_ and \$_[1] are proper aliases #1");
$ok = 0; $x->du1_is_du = 1;
ok($ok, "$z \$_ and \$_[1] are proper aliases #2");

$x->foo2bar_du = 'foo';
ok($x->foo2bar_du eq 'bar', "$z Changing \$_ changes property value");

$x->foo2bar_du1 = 'foo';
ok($x->foo2bar_du1 eq 'bar', "$z Changing \$_[1] changes property value");

{ $x->any = 1; my $foo = \$x->any; $$foo = 2; }
ok($x->any == 2, "$z reference holds #1");

{ my $foo = \($x->any = 3); $$foo = 4; }
ok($x->any == 4, "$z reference holds #2");

my $foo = \$x->digits; 
ok(!eval { $$foo = "abc"; 1 }, "$z invalid reference assignment");
ok($x->digits ne"abc", "$z invalid reference assignment fails succesfully");
ok($$foo = 234, "$z reference assignment");
ok($$foo == 234, "$z reference assignment succeeds");
ok($$foo == 234, "$z value doesn't change after test");
ok($x->{digits} == 234, "$z hash element gets set with reference assignment");

} # end of for (object, class)

ok($object->begin = 1, "generated property functions");

undef $object;
ok($ok == 2, "object gets destroyed correctly");

ok(!eval q{my$a= sub : Property { }; 1 }, "anonymous sub can't be a property");
ok($@ =~ /Property attribute.*anonymous sub/, "error message says so");

# vim: ft=perl sts=0 noet sw=8 ts=8
