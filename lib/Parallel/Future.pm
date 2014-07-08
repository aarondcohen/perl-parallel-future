package Parallel::Future;

use strict;
use warnings;

use overload
	'""'     => 'value',
	'bool'   => 'value',
	'0+'     => 'value',
	'${}'    => 'value',
	'@{}'    => 'value',
	'%{}'    => 'value',
	fallback => 1;

sub new { die "Must override new in the child class" }
sub value { die "Must override value in the child class" }

sub _value {
	my $self = shift;

	my $original_package = ref $self;
	bless $self, join '::', __PACKAGE__ , time, 'PREVENT_INFINITE_LOOP';
	my $value = $$self;
	bless $self, $original_package;

	return $value;
}

sub _finalize {
	my $self = shift;
	my ($final_value, $final_class) = @_;

	bless $self, join '::', __PACKAGE__ , time, 'PREVENT_INFINITE_LOOP';
	$$self = $final_value;
	bless $self, $final_class;
}

1;
