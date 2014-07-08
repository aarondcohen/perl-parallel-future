package Parallel::Future::Thread;

use strict;
use warnings;

use base qw{Parallel::Future};

use Exporter qw{import};
use Storable ();
use threads;

use Parallel::Future::Failure;
use Parallel::Future::Success;

our @EXPORT_OK = qw{future thread_future};

sub future(&) {
	die "future expects a function as the only argument" unless ref($_[0]) eq 'CODE';
	Parallel::Future::Thread->new(@_);
}
sub thread_future(&) { goto &future }

sub new {
	my $class = shift;
	$class = ref $class || $class;
	my ($function) = shift;

	my $thread = threads->new({'exit' => 'thread_only'}, $function);

	return bless \$thread, $class;
}

sub value {
	my $self = shift;

	my $thread = $self->_value;
	my $result = $thread->join;

	my $value = defined $thread->error
		? $self->_finalize($thread->error, 'Parallel::Future::Failure')
		: $self->_finalize($result, 'Parallel::Future::Success')
		;

	return $value->value;
}

1;
