use strict;
use warnings;
use 5.018;
use utf8;
use Data::Dumper;
binmode STDOUT, ':encoding(gb2312)';
binmode STDERR, ':encoding(gb2312)';

my @resultData;

# USERINFO.txt
# ID-�û�ID,NAME-�û���
open my $fh_u, '<:encoding(gb2312)', 'd:\USERINFO.txt' or die 'Can not open file:\n $!';
my @userData;
while(<$fh_u>){
	chomp;
	# ȥ��˫����
	s/"//ig;
	my ($ID, $tmp1, $tmp2, $NAME) = split ',';
	# ȡ������
	 say "$ID $NAME";
	push @userData, +{
		ID=>$ID,
		NAME=>$NAME,
	};
}

# CHECKINOUT.txt
# ID-�û�ID, DATE-����