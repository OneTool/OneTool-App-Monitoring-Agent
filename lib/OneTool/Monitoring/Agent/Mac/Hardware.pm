=head1 NAME

OneTool::Monitoring::Agent::Mac::Hardware

=head1 DESCRIPTION

OneTool Mac Hardware Monitoring Agent module

=cut

package OneTool::Monitoring::Agent::Mac::Hardware;

use strict;
use warnings;

my $BIN_SYS_PROFILER = '/usr/sbin/system_profiler';
my $BIN_SYSCTL       = '/usr/sbin/sysctl';

=head1 FUNCTIONS

=head2 CPU_Info()

Returns CPU Information

=cut

sub CPU_Info
{
    my ($cache_size, $flags, $model_name) = (undef, undef, undef);

    if (defined open my $FILE, '-|', "$BIN_SYSCTL -n machdep.cpu.brand_string")
    {
    	$model_name = <$FILE>;
    	$model_name =~ s/\s{2,}/ /g;
        close($FILE);
        
        return ({ status => 'ok', data => { ModelName => $model_name } });
    }

    return ({ status => 'error', data => "Unable to execute '$BIN_SYSCTL -n machdep.cpu.brand_string'" });
}

1;

# /usr/sbin/system_profiler SPHardwareDataType
# /usr/sbin/system_profiler SPSoftwareDataType

# hostinfo

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
