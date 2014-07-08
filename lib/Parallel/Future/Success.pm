package Parallel::Future::Success;

use strict;
use warnings;

use base qw{Parallel::Future};

sub value { (shift)->_value }

1;
