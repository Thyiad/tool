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

my @data = split "\n", $in;
my $out="";
foreach my $line (@data){
	next if($line=~m/^\bGO\b/i or $line=~/^--/);
	$line=~s/^[\s\,\[]+//g;
	$line=~s/[\s\,\]]+$//g;
	next if(!$line);
	$out.="${line} = DB.GetFieldValue(dr, \"${line}\", \"\"),\n";
}
$clip->Set($out);
print "-------------------- 转换后的内容 ----------------------------------\n";
print $out."\n";
print "--------------------- 打印完毕！------------------------------------";