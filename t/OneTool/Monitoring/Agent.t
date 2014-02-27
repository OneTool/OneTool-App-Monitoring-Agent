#!/usr/bin/perl

=head1 NAME

t/OneTool/Monitoring/Agent.t

=head1 DESCRIPTION

Tests for OneTool::Monitoring::Agent module

=cut

use strict;
use warnings;

use FindBin;
use Test::More;

use lib "$FindBin::Bin/../../../lib/";

my $CHECK = 'OneTool.Monitoring.Agent.Version';

require_ok('OneTool::Monitoring::Agent');

my $response = OneTool::Monitoring::Agent::Version();
my $version = $response->{data}->{Version};
like($version, qr/\d+\.\d+/, 'OneTool::Monitoring::Agent::Version()');

my $os = OneTool::Monitoring::Agent::Operating_System();
like($os, qr/^(Linux|Mac OS X|Windows)$/, 'OneTool::Monitoring::Agent::Operating_System()');

my @availables = OneTool::Monitoring::Agent::Checks_Available();
ok((grep /$CHECK/, map { $_->{name} } @availables), 
    'OneTool::Monitoring::Agent::Checks_Available() => ... OneTool.Monitoring.Agent.Version ...');
    
#my $agent = OneTool::Monitoring::Agent->new();
#my $value = $agent->Check($CHECK);
#cmp_ok($value, 'eq', $version, "\$agent->Check('$CHECK') => $version");

done_testing(4);

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut