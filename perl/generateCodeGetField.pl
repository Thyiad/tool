#�����ֶμ��������ɼ��ֶε�sql

use strict;
use 5.018;
use warnings;
use Win32::Clipboard;

my $clip = Win32::Clipboard->new();
my @operData;
my $in = $clip->Get();
print "--------------------- ճ�����е����� -----------------------------\n";
print "${in}\n";
print "----------------------- ��ӡ��ϣ�--------------------------------\n\n";

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
print "-------------------- ת��������� ----------------------------------\n";
print $out."\n";
print "--------------------- ��ӡ��ϣ�------------------------------------";