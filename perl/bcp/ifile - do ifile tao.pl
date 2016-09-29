#
# ��IFile�������ļ��е�������ϵͳ�ĵ����ʽ(TXT��ʽ).
#
use strict;
use warnings;

#-----------------------------------------------------------------
#���ݽṹ����
#FileGroupName:hash
#	FileGroupNameItem:hash
#		SRC_DIR:scalar
#		DST_DIR:scalar
#		FILE_LIST:array
#-----------------------------------------------------------------
#��������
#��Ҫ�滻��ͨ���
our %wildcardList = ('&TA'=>'${TA}','&SALE'=>'${SALE}', '&yyyymmdd'=>'${day:yyyymmdd}','&BANK'=>'${BANK}','&mmdd'=>'${mmdd}');
#-----------------------------------------------------------------
#�����ļ���Ϣ��ȡ
our %fileGroup = ();

my $bNextFileGroup = 0;
my $currentFileGroupName = '';
while(<>)
{
	next if /^;/;
	chomp;
	if(/\[(.*)\]/)
	{
		$currentFileGroupName = $1;
		$fileGroup{$currentFileGroupName} = ();
		$bNextFileGroup = 1;
		next;
	}
	else
	{
		$bNextFileGroup = 0;
	}
	next if  $currentFileGroupName eq '';
	if(!$bNextFileGroup)
	{
		#print $currentFileGroupName,"::",$_,"\n";
		if(/^ԴĿ¼\s*?=\s*?(.*)/)
		{
			my $dir = $1;
			$dir =~ s/\s+$//;
			$fileGroup{$currentFileGroupName}{'SRC_DIR'} = $dir;
			next;
		}
		if(/^Ŀ��Ŀ¼\s*?=\s*?(.*)/)
		{
			my $dir = $1;
			$dir =~ s/\s+$//;
			$fileGroup{$currentFileGroupName}{'DST_DIR'} = $dir;
			next;
		}
		if(/^�ļ���\d+\s*?=\s*?(.*)/)
		{
			$fileGroup{$currentFileGroupName}{'FILE_LIST'} = [] unless defined $fileGroup{$currentFileGroupName}{'FILE_LIST'};
			my $file = $1;
			$file =~ s/\s+$//;
			push @{$fileGroup{$currentFileGroupName}{'FILE_LIST'}} ,$file;
			next;
		}
	}
}
#-------------------------------------
#ͨ���滻
for(sort keys %fileGroup)
{
	my $currentFileGroupName = $_;
	$fileGroup{$currentFileGroupName}{'SRC_DIR'} = _deal_wildcard($fileGroup{$currentFileGroupName}{'SRC_DIR'});
	$fileGroup{$currentFileGroupName}{'DST_DIR'} = _deal_wildcard($fileGroup{$currentFileGroupName}{'DST_DIR'});
	
	unless(defined $fileGroup{$currentFileGroupName}{'FILE_LIST'})
	{
		#print "undefined $currentFileGroupName\n";
		next;
	}

	for(my $i=0;$i<scalar(@{$fileGroup{$currentFileGroupName}{'FILE_LIST'}});$i++)
	{
		${$fileGroup{$currentFileGroupName}{'FILE_LIST'}}[$i] = _deal_wildcard(${$fileGroup{$currentFileGroupName}{'FILE_LIST'}}[$i]);
	}
}

#-------------------------------------
#������
for(keys %fileGroup)
{
	print '-'x 50,"\n";
	$currentFileGroupName = $_;
	print "TASK_NAME=$currentFileGroupName\n";
	print "FILE_GROUP=$currentFileGroupName\n";
	print "HOST_IPADDR=127.0.0.1\n";
	print "COPYTO_IPADDR=127.0.0.1\n";
	print "COPYTO_DIR=".$fileGroup{$currentFileGroupName}{'DST_DIR'}."\n";
	my $ta=0;
	my $sale=0;
	for(@{$fileGroup{$currentFileGroupName}{'FILE_LIST'}})
	{
		print $fileGroup{$currentFileGroupName}{'SRC_DIR'},"\\$_\n";
		if(!$ta && m/\${TA}/){
			$ta=1;
		}
		if(!$sale && m/\${SALE}/){
			$sale=1;
		}
	}
	if($ta){
		print "FILE_REGEX=TA\n";
	}
	elsif($sale){
		print "FILE_REGEX=SALE\n";
	}
	else{
		print "FILE_REGEX=\n";
	}
}

sub _deal_wildcard
{
	my $file = shift;
	return '' unless defined $file;
	while(my($key,$value) = each %wildcardList)
	{
		$file =~ s/$key/$value/g ;
	}
	return $file;
}