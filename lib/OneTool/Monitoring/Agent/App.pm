package OneTool::Monitoring::Agent::App;

=head1 NAME

OneTool::Monitoring::Agent::App - Module handling everything for onetool_monitoring_agent.pl

=head1 DESCRIPTION

Module handling everything for onetool_monitoring_agent.pl

=head1 SYNOPSIS

onetool_monitoring_agent.pl [options]

=head1 OPTIONS

=over 8

=item B<-a,--available>  

Prints Available Checks

=item B<-c,--config>     

Prints Monitoring Agent configuration

=item B<-D,--debug>

Sets Debug mode

=item B<-g,--get> <key>  

Returns the value of the check 'key'

=item B<-h,--help>

Prints this Help

=item B<--hwinfo>        

Returns Hardware Information

=item B<--start>  

Starts Monitoring Agent daemon

=item B<--swinfo>       

Returns Software Information

=item B<--sysinfo>       

Returns System Information

=item B<-v,--version>

Prints version

=back

=cut

use strict;
use warnings;

use FindBin;
use Getopt::Long qw(:config no_ignore_case);
use Pod::Find qw(pod_where);
use Pod::Usage;

use lib "$FindBin::Bin/../lib/";

use OneTool::App;
use OneTool::Monitoring::Agent;

__PACKAGE__->run(@ARGV) unless caller;

my $PROGRAM = 'onetool_monitoring_agent.pl';
my $OS      = OneTool::Monitoring::Agent::Operating_System();
my $TITLE   = "OneTool Monitoring Agent (for $OS)";

my $agent = undef;

=head1 SUBROUTINES/METHODS

=head2 Checks_Available()

Returns list of available checks for this agent

=cut

sub Checks_Available
{
    my @list         = $agent->Checks_Available();
    my $nb_available = scalar @list;

    printf "%s\n\nAvailable Checks (%d):\n", $TITLE, $nb_available;
    my $category = '';
    foreach my $e (@list)
    {
        $e->{name} =~ /^(\S+?)\..+$/;
        if ($1 ne $category)
        {
            printf "\n";
            $category = $1;
        }
        printf "  - %s (%s)\n", $e->{name}, $e->{type};
    }
    print "\n";

    return ($nb_available);
}

=head2 Daemon_Start()

Launches OneTool Monitoring Agent as Daemon

=cut

sub Daemon_Start
{
    my $agent = OneTool::Monitoring::Agent->new();

    if (fork())
    {    #father -> API Listener
        $agent->Listener();
    }
    else
    {   #child -> monitoring loop
        $agent->Log('info', 'Monitoring Agent Loop Started !');
        while (1)
        {
            foreach my $check (@{$agent->{checks}})
            {
                my $time = time();
                $check->{last_check} = 0    if (!defined $check->{last_check});
                if (($time - $check->{last_check}) >= $check->{interval})
                {
                    $agent->Log('debug', "Check '$check->{name}'");
                    my $result = $agent->Check($check->{name});
                    $check->Data_Write($result) if (defined $result);
                    $check->{last_check} = $time;
                }
            }
            sleep(1);
        }
    }

    return (undef);
}

=head2 Get($check)

Returns the value of the check 'key'

=cut

sub Get
{
    my $check = shift;

    my $result = $agent->Check($check);
    if ($result->{status} eq 'ok')
    {
        foreach my $key (keys %{$result->{data}})
        {
            printf "%s:%s => %s\n", $check, $key, 
                OneTool::Monitoring::Check_Type::Prettify('byte', $result->{data}->{$key});
        }
    }
    else
    {
        printf "ERROR: %s\n", $result->{data};
    }

    return ($result->{data});
}

=head2 Hardware_Information()

Returns Hardware Information (all checks starting with 'Hardware.') 

=cut

sub Hardware_Information
{
    my @checks =
        grep { $_->{name} =~ /^Hardware\./ } $agent->Checks_Available();

    print "Hardware Information:\n";
    Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 Print_Check_Results

=cut

sub Print_Check_Results
{
    my @checks = @_;

    foreach my $check (@checks)
    {
        my $result = $agent->Check($check->{name});
        if ($result->{status} eq 'ok')
        {
            foreach my $key (keys %{$result->{data}})
            {
                printf " %s:%s => %s\n", $check->{name}, $key, $result->{data}->{$key};
            }
        }
        else
        {
            printf "ERROR: %s\n", $result->{data};
        }
    }
    
    return (scalar @checks);
}

=head2 Print_Config()

Prints Agent Configuration

=cut

sub Print_Config
{
    printf "OneTool Monitoring Agent Configuration:\n";
    printf "Checks:\n";
    my @checks = $agent->Checks_List();
    foreach my $c (@checks)
    {
        print "\t$c->{name} ==> $c->{interval} seconds\n";
    }

    return (scalar(@{$agent->{checks}}));
}

=head2 System_Information()

Returns System Information (checks starting with 'System.')

=cut

sub System_Information
{
    my @checks =
        grep { $_->{name} =~ /^System\./ } $agent->Checks_Available();

    print "System Information:\n";
    Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 Software_Information()

Returns Software Information (checks starting with 'Software.')

=cut

sub Software_Information
{
    my @checks =
        grep { $_->{name} =~ /^Software\./ } $agent->Checks_Available();

    print "Software Information:\n";
    Print_Check_Results(@checks);

    return (scalar @checks);
}

=head2 run(@ARGV)

=cut

sub run
{
    my $self = shift;
    my %opt  = ();

    local @ARGV = @_;
    my @options = @OneTool::App::DEFAULT_OPTIONS;
    push @options, 
        'available|a', 
        'config|c', 
        'get|g=s', 
        'hwinfo', 
        'start', 
        'stop',
        'swinfo',
        'sysinfo';
    my $status = GetOptions(\%opt, @options);

    pod2usage(
        -exitval => 'NOEXIT', 
        -input => pod_where({-inc => 1}, __PACKAGE__)) 
        if ((!$status) || ($opt{help}));
        
    if ($opt{version})
    {
        printf "%s v%s\n", $PROGRAM, $OneTool::Monitoring::Agent::VERSION;
    }

    $agent = OneTool::Monitoring::Agent->new();
    
    Checks_Available()      if ($opt{available});
    Get($opt{get})          if ($opt{get});
    Hardware_Information()  if ($opt{hwinfo});
    Print_Config()          if ($opt{config});
    Software_Information()  if ($opt{swinfo});
    System_Information()    if ($opt{sysinfo});
    
    Daemon_Start() if ($opt{start});

    return ($status);
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut