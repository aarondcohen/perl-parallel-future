package Parallel::Future::Failure;

use strict;
use warnings;

use base qw{Parallel::Future};

sub value { die ((shift)->_value) }

1;
