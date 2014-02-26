package OneTool::Monitoring::Check_Type;

=head1 NAME

OneTool::Monitoring::Check_Type - OneTool Monitoring Type Check module

=cut

use strict;
use warnings;

my %pretty = (
	byte => [
		{ limit => 1024**4, string => 'TBytes' },
		{ limit => 1024**3, string => 'GBytes' },
		{ limit => 1024**2, string => 'MBytes' },
		{ limit => 1024, 	string => 'KBytes' },
		]
	);
		
=head1 FUNCTIONS

=head2 Prettify

Returns 'prettified' value

=cut

sub Prettify
{
	my ($type, $value) = @_;
		
	if ($pretty{$type})
	{
		foreach my $p (@{$pretty{$type}})
		{
			if ($value >= $p->{limit})
			{
				return (sprintf "%.2f %s", $value / $p->{limit}, $p->{string});
			}
		}
	}
	
	return ($value);
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
