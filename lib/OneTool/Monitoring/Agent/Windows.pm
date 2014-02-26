package OneTool::Monitoring::Agent::Windows;

=head1 NAME

OneTool::Monitoring::Agent::Windows - OneTool Windows Monitoring Agent module

=cut

use strict;
use warnings;

use FindBin;

use lib "$FindBin::Bin/../lib/";

use OneTool::Monitoring::Agent::Windows::Hardware;
use OneTool::Monitoring::Agent::Windows::System;

my %check = (
	'Hardware.CPU.Information' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::Hardware::CPU_Info,
        args => [],
		type => 'string'
    },
	'Hardware.Printer.Default' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::Hardware::Printer_Default,
        args => [],
		type => 'string'
    },
	'System.DiskUsage' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::System::Disk_Usage,
        args => [],
		type => 'byte'
    },
	'System.Domainname' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::System::Domainname,
        args => [],
		type => 'string'
    },
	'System.Hostname' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::System::Hostname,
        args => [],
		type => 'string'
    },
	'System.Software.InstalledList' => {
        fct  => \&OneTool::Monitoring::Agent::Windows::System::Software_Installed_List,
        args => [],
		type => 'string'
    },
	);

=head1 FUNCTIONS

=head2 Check($name, $args)

Launches Check named $name with args $args

=cut

sub Check
{
    my ($name, $args) = shift;

	if (defined $check{$name})
	{
		my $check_args = (defined $args 
			? $args 
			: (defined $check{$name}{args} 
				? $check{$name}{args} 
				: undef));	

		return (&{$check{$name}{fct}}($check_args));
	}
	
	return ({ status => 'error', data => "Check '$name' doesn't exist" });
}

=head2 Checks_Available()

Returns list of available Checks

=cut

sub Checks_Available
{
	my @list = ();
	
	foreach my $k (sort keys %check)
	{
		push @list, { name => $k, type => $check{$k}{type} };
	}
	
    return (@list);
}

=head2 Search_In_File($file, $regexp)

=cut

sub Search_In_File
{
    my ($file, $regexp) = @_;
    my $value = undef;

    if (defined open my $FILE, '<', $file)
    {
        while (<$FILE>)
        {
            $value = $_ if (!defined $regexp);
            $value = $1 if ((defined $regexp) && ($_ =~ $regexp));
        }
        close $FILE;
		chomp $value;

		return ({ status => 'ok', data => $value });
    }

    return ({ status => 'error', data => "Unable to open file '$file'" });
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
