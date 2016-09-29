use strict;
use warnings;
use 5.018;
use utf8;
use Data::Dumper;
binmode STDOUT, ':encoding(gb2312)';
binmode STDERR, ':encoding(gb2312)';

my @resultData;

# USERINFO.txt
# ID-用户ID,NAME-用户名
open my $fh_u, '<:encoding(gb2312)', 'd:\USERINFO.txt' or die 'Can not open file:\n $!';
my @userData;
while(<$fh_u>){
	chomp;
	# 去除双引号
	s/"//ig;
	my ($ID, $tmp1, $tmp2, $NAME) = split ',';
	# 取得数据
	 say "$ID $NAME";
	push @userData, +{
		ID=>$ID,
		NAME=>$NAME,
	};
}

# CHECKINOUT.txt
# ID-用户ID, DATE-日期