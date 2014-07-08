use strict;
use warnings;

use Benchmark qw{cmpthese};

use Parallel::Future::Fork qw{fork_future};
use Parallel::Future::Thread qw{thread_future};
use Time::HiRes qw{gettimeofday tv_interval sleep};
use Test::Most;
use Data::Dumper;
use Storable qw{freeze thaw};

#my @values = map { my $value = $_; future { sleep($value); die "Bad Value" if $value % 2; [bless {val => $value + 10}, 'FOO'] } } (1 .. 5);
#my @values = map { my $value = $_; future { my $val = +{map { ($_ => $_ x (500 * rand)) } ('a' .. 'z')}; sleep(2); $val } } (1 .. 1000);
#
#local $\="\n";
#local $,=" : ";
#my $time = [gettimeofday];
#do { eval { print ref($_->[0]), $_, 'Elapsed:' . tv_interval($time); 1 } || warn $@ } for reverse @values;
#do { eval { print ref($_->[0]), 'Elapsed:' . tv_interval($time); 1 } || warn $@ } for reverse @values;
#do { eval { print ref($_), $_, 'Elapsed:' . tv_interval($time); 1 } || warn $@ } for reverse @values;
#do { eval { print $_->[0]{val}, 'Elapsed:' . tv_interval($time); 1 } || warn $@ } for reverse @values;
#print "Elapsed: " . tv_interval $time;

#cmpthese(-5, {
#	base => sub { '' . +{map { ($_ => $_ x (500 * rand)) } ('a' .. 'z')} },
#	fork_future => sub { '' . fork_future { +{map { ($_ => $_ x (500 * rand)) } ('a' .. 'z')} } },
#	thread_future => sub { '' . thread_future { +{map { ($_ => $_ x (500 * rand)) } ('a' .. 'z')} } },
#});

sub repeat(&$) {
	my ($code, $count) = @_;
	map { $code->() } (1..$count);
}

my $struct = +{map { ($_ => $_ x (500 * rand)) } ('a' .. 'z')};
my $sub = sub { $struct };

my (@results, @other);

#my $time1 = [gettimeofday];
#@results = repeat { fork_future { $sub->() } } 100;
#@other = map { $_->{a} } @results;
#my $dur1 = tv_interval $time1;
#
#undef @results;
#undef @other;
#
#my $time2 = [gettimeofday];
#@results = repeat { thread_future { $sub->() } } 100;
#@other = map { $_->{a} } @results;
#my $dur2 = tv_interval $time2;
#
#
#local $\="\n";
#print "Elapsed: " . $dur1;
#print "Elapsed: " . $dur2;

#cmpthese(10, {
#	base          => sub { @other = map { $_->{a} } repeat {                 $sub->()   } 100 },
#	deep_clone    => sub { @other = map { $_->{a} } repeat { thaw freeze     $sub->()   } 100 },
#	fork_future   => sub { @other = map { $_->{a} } repeat { fork_future   { $sub->() } } 100 },
#	thread_future => sub { @other = map { $_->{a} } repeat { thread_future { $sub->() } } 100 },
#});

cmpthese(1, {
	base          => sub { @results = repeat {                 $sub->()   } 100; @other = map { $_->{a} } @results },
	deep_clone    => sub { @results = repeat { thaw freeze     $sub->()   } 100; @other = map { $_->{a} } @results },
	fork_future   => sub { @results = repeat { fork_future   { $sub->() } } 100; @other = map { $_->{a} } @results },
	thread_future => sub { @results = repeat { thread_future { $sub->() } } 100; @other = map { $_->{a} } @results },
});
