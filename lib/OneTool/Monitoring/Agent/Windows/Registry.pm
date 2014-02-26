package OneTool::Monitoring::Agent::Windows::Registry;

=head1 NAME

OneTool::Monitoring::Agent::Windows::Registry - OneTool Windows Registry Monitoring Agent module

=cut

use strict;
use warnings;

use Win32::TieRegistry;

my %DATA_KEY = (
	Installed_Software => 
		'HKEY_CURRENT_USER\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
		#'HKEY_LOCAL_MACHINE\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
	);

# TODO Rights problem on HKEY_LOCAL_MACHINE
	
# HKEY_LOCAL_MACHINE\Software\Microsoft\Windows\CurrentVersion\Uninstall
# HKEY_LOCAL_MACHINE\SOFTWARE\Wow6432Node\Microsoft\Windows\CurrentVersion\Uninstall

=head1 FUNCTIONS

=head2 Data

=cut

sub Data
{
	my $name = shift;
	
	return (Key($DATA_KEY{$name}));
}

=head2 Key($key)

=cut

sub Key
{
	my $key = shift;
	
	return ($Registry->{$key});
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut