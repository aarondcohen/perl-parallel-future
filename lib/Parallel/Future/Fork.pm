package Parallel::Future::Fork;

use strict;
use warnings;

use base qw{Parallel::Future};

use Exporter qw{import};
use Storable ();

use Parallel::Future::Failure;
use Parallel::Future::Success;

our @EXPORT_OK = qw{future fork_future};

sub future(&) {
	die "future expects a function as the only argument" unless ref($_[0]) eq 'CODE';
	Parallel::Future::Fork->new(@_);
}
sub fork_future(&) { goto &future }

sub new {
	my $class = shift;
	$class = ref $class || $class;
	my ($function) = shift;

	my $pid = open(my $value_pipe, '-|');
	defined($pid) || die "Failed to create future";

	unless ($pid) {
		my ($error, $has_error, $value);

		eval { $value = $function->(); 1 }
		|| do { $has_error = 1; $error = $@ };

		++$|;
		print Storable::freeze({
			error => $error,
			has_error => $has_error,
			value => $value,
		});
		exit(0);
	}

	return bless \$value_pipe, $class;
}

sub value {
	my $self = shift;

	my $value_pipe = $self->_value;
	my $result = do { local $/; Storable::thaw(scalar <$value_pipe>) };
	close $value_pipe;

	my $value = $result->{has_error}
		? $self->_finalize($result->{error}, 'Parallel::Future::Failure')
		: $self->_finalize($result->{value}, 'Parallel::Future::Success')
		;

	return $value->value;
}

1;
