package OneTool::Monitoring::Check;

=head1 NAME

OneTool::Monitoring::Check - OneTool Monitoring Check module

=cut

use strict;
use warnings;

use File::Path;
use FindBin;
use Moose;
use POSIX qw(mktime strftime);

my $DIR_DATA = "$FindBin::Bin/../data/onetool_monitoring_agent/";

has 'name' => (
	is => 'rw',
	isa => 'Str',
	required => 1,
	);

has 'interval' => (
	is => 'rw',
	isa => 'Int',
	required => 1,
    );
	
=head1 SUBROUTINES/METHODS

=head2 Category()

Returns Check Category (Hardware, Network, Software, System)

=cut

sub Category
{
	my $self = shift;
	
	my $category = $self->{name}; 
	$category =~ s/^(\S+?)\..+$/$1/;

	return ($category);
}

=head2 Data_Write($data)

Writes Check Data on file

=cut

sub Data_Write
{
	my ($self, $data) = @_;

	my ($sec, $min, $hour, $mday, $month, $year) = localtime(time);
    my $str_date = POSIX::strftime('%Y/%m/', 0, 0, 0, $mday, $month, $year);
	my $str_day = POSIX::strftime('%d', 0, 0, 0, $mday, $month, $year);
    my $dir = ${DIR_DATA} . $self->{name} . "/$str_date";

    mkpath($dir) if (!-e $dir);
    if (defined open my $FILE, '>>', "${dir}${str_day}.txt")
    {
		if ($data->{status} eq 'ok')
		{
        	foreach my $key (keys %{$data->{data}})
        	{
            	print {$FILE} sprintf("%02d%02d%02d>%s=%s\n",
                	$hour, $min, $sec, $key, $data->{data}->{$key});
        	}
		}
		else
		{
			print {$FILE} sprintf("%02d%02d%02d![ERROR] %s\n",
                    $hour, $min, $sec, $data->{data});
		}
        close $FILE;
    }

    return (undef);
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
