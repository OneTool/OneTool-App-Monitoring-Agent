=head1 NAME

OneTool::Monitoring::Software - OneTool Monitoring Software module

=cut

package OneTool::Monitoring::Software;

use strict;
use warnings;

my $DIR_SOFTWARE = "$FindBin::Bin/../lib/OneTool/Monitoring/Software/";
my $MOD_SOFTWARE = 'OneTool::Monitoring::Software::';

=head1 FUNCTIONS

=head2 Check($key)

=cut

sub Check
{
    my $key = shift;

    my $module = $key;
    $module =~ s/^Software\.(.+?)\..+$/$1/;

    no strict 'refs';
    require "${DIR_SOFTWARE}${module}.pm"
        ;    ## no critic qw(Policy::Modules::RequireBarewordIncludes)
    my $fct_import = $MOD_SOFTWARE . $module . '::Checks_Export';
    my %check      = &{$fct_import}();
    use strict;

    return (&{$check{$key}{fct}}(@{$check{$key}{args}}));
}

=head2 Checks_Available

=cut

sub Checks_Available
{
    my @list = ();

    foreach my $f (Module_Files())
    {
        no strict 'refs';
        require "$DIR_SOFTWARE$f"
            ;    ## no critic qw(Policy::Modules::RequireBarewordIncludes)
        my $module = $f;
        $module =~ s/\.pm$//;
        my $fct = $MOD_SOFTWARE . $module . '::Checks_Available';
        push @list, &{$fct}();
        use strict;
    }

    return (@list);
}

=head2 Module_Files

=cut

sub Module_Files
{
    my @module_files = ();
    
    if (defined opendir(my $dir, $DIR_SOFTWARE))
    {
        @module_files = grep { /\.pm$/ } readdir $dir;
        closedir $dir;
    }
    
    return (@module_files);
}

1;

=head1 AUTHOR

Sebastien Thebert <contact@onetool.pm>

=cut
