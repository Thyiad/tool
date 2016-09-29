#根据字段及类型生成加字段的sql

use strict;
use 5.018;
use warnings;
use Win32::Clipboard;

my $clip = Win32::Clipboard->new();
my @operData;
my $in = $clip->Get();
print "--------------------- 粘贴板中的内容 -----------------------------\n";
print "${in}\n";
print "----------------------- 打印完毕！--------------------------------\n\n";
return;
my @outData;
my @data = split "\n", $in;
foreach my $line (@data){
	next if($line=~m/^\bGO\b/i or $line=~/^--/);
	$line=~s/^\s+//g;
	$line=~s/\s+$//g;
	next if(!$line);
	my ($COLNAME, $COLTYPE) = split '\t';
	push @outData, +{
		COLNAME=>$COLNAME,
		COLTYPE=>$COLTYPE,
	};
}
my $out ='USER erp;\n';
my $table='ERPProduct';
for(@outData){
	$out.="IF COL_LENGTH(\'${table}\', \'".$_->{COLNAME}."\') IS NULL\n";
	$out.="\tALTER TABLE $table ADD ".$_->{COLNAME}." ".$_->{COLTYPE}." \n";
}
$clip->Set($out);
print "-------------------- 转换后的内容 ----------------------------------\n";
print $out."\n";
print "--------------------- 打印完毕！------------------------------------";