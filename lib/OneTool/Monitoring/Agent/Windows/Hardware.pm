package OneTool::Monitoring::Agent::Windows::Hardware;

=head1 NAME

OneTool::Monitoring::Agent::Windows::Hardware - OneTool Windows Hardware Monitoring Agent module

=cut

use strict;
use warnings;

use OneTool::Monitoring::Agent::Windows::WMI;

=head1 SUBROUTINES/METHODS

=head2 CPU_Info()

Gets CPU Information (Name, Description)

=cut

sub CPU_Info
{	
	while (my @row = OneTool::Monitoring::Agent::Windows::WMI::Query('PROCESSOR'))
	{
		my $p = $row[0];
		
		return ({ status => 'ok', data => { 
			Name => $p->{name}, Description => $p->{Description} } });
	}

    return ({ status => 'error', 
		data => "Unable to get default printer" });
}


=head2 Printer_Default()

Gets default Printer

=cut

sub Printer_Default
{
	while (my @row = OneTool::Monitoring::Agent::Windows::WMI::Query('PRINTER_DEFAULT'))
	{
		my $printer = $row[0];
		
		return ({ status => 'ok', data => { Name => $printer->{Name} }});
	}

    return ({ status => 'error', 
		data => "Unable to get default printer" });
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut