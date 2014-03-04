package OneTool::Monitoring::Agent::Windows::WMI;

=head1 NAME

OneTool::Monitoring::Agent::Windows::WMI - OneTool WMI (Windows Management Instrumentation) for Windows Monitoring Agent module

http://msdn.microsoft.com/en-us/library/windows/desktop/aa394585(v=vs.85).aspx

=cut

use strict;
use warnings;

use DBI;

my %QUERY =
	(
	COMPUTER => 'SELECT * FROM Win32_ComputerSystem',
	DISK => 'SELECT * FROM Win32_LogicalDisk',
	PRINTER_DEFAULT => 'SELECT * FROM Win32_Printer WHERE Default = TRUE',
	PROCESSOR => 'SELECT * FROM Win32_Processor',
	);
	
my $dbh = DBI->connect('dbi:WMI:');

=head1 SUBROUTINES/METHODS

=head2 Query($query)

Launches the WMI query '$query'

=cut

sub Query
{
	my $query = shift;
	
	my $sth = $dbh->prepare($QUERY{$query});
	$sth->execute();
	
	return ($sth->fetchrow);
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut