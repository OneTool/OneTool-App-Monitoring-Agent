package OneTool::Monitoring::Agent;

=head1 NAME

OneTool::Monitoring::Agent - OneTool Monitoring Agent module

=cut

use strict;
use warnings;

use FindBin;
use JSON;
use Log::Log4perl;
use Moose;

use lib "$FindBin::Bin/../lib/";

use OneTool::Configuration;
use OneTool::Monitoring::Agent::API  qw( %agent_api );
use OneTool::Monitoring::Check;
use OneTool::Monitoring::Check_Type;
use OneTool::Monitoring::Software;

BEGIN
{
	if ($^O eq 'linux')
	{
		require OneTool::Monitoring::Agent::Linux;
    }
	elsif ($^O eq 'darwin')
    {
		require OneTool::Monitoring::Agent::Mac;
	}
    else 
	{
		require OneTool::Monitoring::Agent::Windows;
    }
}

my $DIR_DATA = "$FindBin::Bin/../data/monitoring_agent/";
my $FILE_CONF = "$FindBin::Bin/../conf/onetool_monitoring_agent.conf";

our $VERSION = 0.1;

my %check = (
    'OneTool.Monitoring.Agent.Version' => {
        fct  => \&Version,
        args => [],
		type => 'version'
    },
);

=head1 MOOSE OBJECT

=cut

extends 'OneTool::Daemon';

has 'checks' => (
	is => 'rw',
	isa => 'ArrayRef[OneTool::Monitoring::Check]',
	);

around BUILDARGS => sub 
{
	my $orig  = shift;
  	my $class = shift;

	Log::Log4perl::init_and_watch("$FindBin::Bin/../conf/onetool_monitoring_agent.log.conf", 10);
	my $logger = Log::Log4perl->get_logger('OneTool_monitoring_agent');
	
	if (@_ == 0)
	{
		# OneTool::Monitoring::Agent->new();
		my $conf = OneTool::Configuration::Get({ module => 'onetool_monitoring_agent' });
		my @checks = ();
		foreach my $c (@{$conf->{checks}})
		{
			my $check = OneTool::Monitoring::Check->new(
				name => $c->{name},
				interval => $c->{interval}
				);
			push @checks, $check;
		}
		$conf->{checks} = \@checks;
        $conf->{api} = \%agent_api;
		$conf->{logger} = $logger;
		
		return $class->$orig($conf);
	}
   	elsif ( @_ == 1 && defined $_[0]->{file} )
	{
		# OneTool::Monitoring::Agent->new($fileconf);
		my $conf = OneTool::Configuration::Get({ file => $_[0]->{file} });
        my @checks = ();
        foreach my $c (@{$conf->{checks}})
        {
            my $check = OneTool::Monitoring::Check->new(
                name => $c->{name},
                interval => $c->{interval}
                );
            push @checks, $check;
        }
        $conf->{checks} = \@checks;

     	return $class->$orig($conf);
    }
   	else 
	{
		return $class->$orig(@_);
   	}
};

=head1 SUBROUTINES/METHODS

=head2 Check($key)

=cut

sub Check
{
    my ($self, $key) = @_;

    my $value = (
        $key =~ /^OneTool\.Monitoring\.Agent\./
        ? &{$check{$key}{fct}}(@{$check{$key}{args}})
        : (
            $key =~ /^Software\./
            ? OneTool::Monitoring::Software::Check($key)
            : (
                $^O eq 'linux' ? OneTool::Monitoring::Agent::Linux::Check($key)
                : (
                    $^O eq 'darwin'
                    ? OneTool::Monitoring::Agent::Mac::Check($key, $check{$key}{type})
                    : OneTool::Monitoring::Agent::Windows::Check($key)
                  )
              )
          )
    );

    return ($value);
}

=head2 Checks_Available

Returns list of available Checks for this Agent

=cut

sub Checks_Available
{
    my @list = ();
	
	foreach my $k (sort keys %check)
	{
		push @list, { name => $k, type => $check{$k}{type} }; 
	}

	push @list, OneTool::Monitoring::Software::Checks_Available();

    if ($^O eq 'linux')
    {
        push @list, OneTool::Monitoring::Agent::Linux::Checks_Available();
    }
    elsif ($^O eq 'darwin')
    {
        push @list, OneTool::Monitoring::Agent::Mac::Checks_Available();
    }
    elsif ($^O eq 'MSWin32')
    {
        push @list, OneTool::Monitoring::Agent::Windows::Checks_Available();
    }

    return (sort { $a->{name} cmp $b->{name} }@list);
}

=head2 Checks_List()

Returns list of active Checks

=cut

sub Checks_List
{
	my $self = shift;

	return (@{$self->{checks}});
}

=head2 Operating_System()

Returns Agent Operating System

=cut

sub Operating_System
{
    if    ($^O eq 'linux')   { return ('Linux'); }
    elsif ($^O eq 'darwin')  { return ('Mac OS X'); }
    elsif ($^O eq 'MSWin32') { return ('Windows'); }

    return (undef);
}

=head2 Version()

Returns Agent version

=cut

sub Version
{
    return ({ status => 'ok', data => { Version => $VERSION } });
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
