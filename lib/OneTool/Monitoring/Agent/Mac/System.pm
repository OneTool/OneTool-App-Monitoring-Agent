package OneTool::Monitoring::Agent::Mac::System;

=head1 NAME

OneTool::Monitoring::Agent::Mac::System - OneTool Mac System Monitoring Agent module

=cut

use strict;
use warnings;

my $BIN_UPTIME = '/usr/bin/uptime';

=head1 SUBROUTINES/METHODS

=head2 Load()

=cut

sub Load
{
    my ($load1, $load5, $load15) = (undef, undef, undef);

    if (defined open my $FILE, '-|', $BIN_UPTIME)
    {
        while (<$FILE>)
        {
            ($load1, $load5, $load15) = $_ =~ qr/load averages:\s+(\S+)\s+(\S+)\s+(\S+)/;
        }
        close $FILE;

        return ({ status => 'ok', 
            data => { Load1 => $load1, Load5 => $load5, Load15 => $load15 } });
    }

    return ({ status => 'error', 
            data => "Unable to execute '$BIN_UPTIME'" });
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut