use LWP::Simple;
use FindBin qw($Bin);

my $url     = 'http://bbs.chinaunix.net/images/default/logo.gif';
my $content = get($url);
die "Couldn't get it!" unless defined $content;
print $content;
my $logo = "$Bin/logo.gif";
open FH, ">$logo" or die "Can't open $logo for saving!";
binmode FH;
print FH $content;
close FH;
