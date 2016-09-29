#
# 把txt格式的导入文件转换为xml格式
#
use warnings;

#------------------------------------------------------------------------
#------------------------------------------------------------------------
push @ARGV,qq(C:\\Users\\Administrator\\Desktop\\tmp\\deal IFile\\st2.txt);

our @taskList=();

my ($tTaskName,$tFileGrp,$tHostIP,$tCopyToIP,$tCopyDir,$tFileRegex,@tFileList);

my $bNew = 0;
while(<>)
{
	next if /-------/;
	
	chomp;
	
	if(/TASK_NAME=(.*)/)
	{
		$bNew = 1;
		$tTaskName=$1;
		$tTaskName = substr($tTaskName, 0, 100) if(length $tTaskName > 100);
		next;
	}
	if(/FILE_GROUP=(.*)/)
	{
		$tFileGrp = $1;
		next;
	}
	if(/HOST_IPADDR=(.*)/)
	{
		$tHostIP=$1;
		next;
	}
	if(/COPYTO_IPADDR=(.*)/)
	{
		$tCopyToIP=$1;
		next;
	}
	if(/COPYTO_DIR=(.*)/)
	{
		$tCopyDir=$1;
		next;
	}
	if(/FILE_REGEX=(.*)/)
	{
		$tFileRegex=$1;
		
		if(@tFileList)
		{
			my $task={};
			$task->{TASK_NAME} = defined($tTaskName)?$tTaskName:'';
			$task->{FILE_GROUP} = defined($tFileGrp)?$tFileGrp:'';
			$task->{HOST_IPADDR} = defined($tHostIP)?$tHostIP:'';
			$task->{COPYTO_IPADDR} = defined($tCopyToIP)?$tCopyToIP:'';
			$task->{COPYTO_DIR} = defined($tCopyDir)?$tCopyDir:'';
			$task->{FILE_REGEX} = defined($tFileRegex)?$tFileRegex:'';
			$task->{FILE_LIST} = [@tFileList];
			push @taskList ,$task;
		}
		
		undef $tTaskName;
		undef $tFileGrp;
		undef $tHostIP;
		undef $tCopyToIP;
		undef $tCopyDir;
		undef $tFileRegex;
		undef @tFileList;
		
		next;
	}
	
	unless(/=/)
	{
		push @tFileList,$_;
	}
}


#-------------------------------------------------------------------------
my $tmp = <<'TMP';
<?xml version="1.0" encoding="gb2312" ?>
<BCP_IMPORT>
	<FILE_LIST>
		
TMP

print $tmp;
#-------------------------------------------------------------------------
foreach(@taskList)
{
	my $task = $_;
	print qq(<FILE_GROUP name="$task->{TASK_NAME}">\n);
	print qq(<HOST_IP name="$task->{HOST_IPADDR}" ip="$task->{HOST_IPADDR}">\n);
	
	foreach(@{$task->{FILE_LIST}})
	{
		my $fName = $_;
		$fName = substr($fName, 0, 100) if(length $fName > 100);
		print qq(<FILE name="$fName" path="$_" ></FILE>\n);
	}
	
	print qq(</HOST_IP>\n);
	print qq(	</FILE_GROUP>\n);
}
print qq(</FILE_LIST>\n);
#-------------------------------------------------------------------------
print qq(<TASK_LIST>);

foreach(@taskList)
{
	my $task = $_;
	next unless("$task->{COPYTO_DIR}");
	print qq(<COPY_TASK name="$task->{TASK_NAME}" copyto_ipaddr="$task->{COPYTO_IPADDR}" copyto_dir="$task->{COPYTO_DIR}" file_group="$task->{FILE_REGEX}" max_exec_count="0">\n);
	print qq(<FILE_ITEM>\n);
	
	foreach(@{$task->{FILE_LIST}})
	{
		my $fName = $_;
		$fName = substr($fName, 0, 100) if(length $fName > 100);
		print qq(<FILE_NAME name="$fName"/>\n);
	}
	
	print qq(</FILE_ITEM>\n);
	print qq(</COPY_TASK>\n);
}
print qq(</TASK_LIST>);
#-------------------------------------------------------------------------
print qq(</BCP_IMPORT>);
#----------------------------------------------------

