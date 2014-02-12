#!/usr/bin/perl

=head1 NAME

onetool_monitoring_agent.pl - Monitoring Agent Program from the OneTool Suite

=cut

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

use OneTool::Monitoring::Agent::App;

OneTool::Monitoring::Agent::App->run(@ARGV);

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
