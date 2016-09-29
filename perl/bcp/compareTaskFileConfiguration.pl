###
# 核对新旧系统中文件配置是否有误
#	输出：
#		文件在原系统中任务下面存在而在新系统中同任务下面不存在
#		文件在新系统中主机被设置为 127.0.0.1 的文件
#							(127.0.0.1是原导出脚本设置文件的默认主机，新系统中仍然是 127.0.0.1 的话就可能有误)
###
use strict;
use warnings;
use 5.018;
use Data::Dumper;
use List::Util qw(first);

my %oriHash = ();
my %nowHash = ();
# 经 do ifile 处理过后的文件
@ARGV = (q(C:\Users\Administrator\Desktop\tmp\deal IFile\tmpresult.txt));
my $taskName = undef;
while(<>){
	chomp;
	if(/^---/){
		$taskName = undef;
	}
	elsif(/^TASK_NAME=(.*)$/){
		$taskName = $1;
	}
	elsif(/^[A-z]:\\/){
		if(not defined($taskName)){
			say "error taskName not defined!";
		}
		push @{$oriHash{$taskName}}, $_;
	}
}
#say Dumper(\%oriHash);

my @fullData;
# 数据库中查询出来的结果文件
# 以\t 为分隔符(任务名，文件路径，主机IP)
@ARGV = ('C:\Users\Administrator\Desktop\tmp\deal IFile\result.txt');
while(<>){
	chomp;
	my($task, $file, $host) = split '\t';
	if(!defined($task) or !defined($file)){
		say "error task or file not defined!";
	}
	push @{$nowHash{$task}}, $file;
	push @fullData, [$task, $file, $host];
}

#say Dumper(\%nowHash);

#核对旧的数据是否在新的数据中不存在
my %failHash;
my @hostErrorHash;
foreach my $task (keys %oriHash){
	my @oriFile = @{$oriHash{$task}};
	my @nowFile = @{$nowHash{$task}};
	
	foreach my $file (@oriFile){
		if(!($file~~ @nowFile)){	# 不存在
			push @{$failHash{$task}}, $file;
		}
		else{	# 存在
			foreach (@fullData){
				my($t, $f, $h) = @{$_}; 
				if($t eq $task and 
					$f eq $f and 
					$h eq '127.0.0.1'){
						push @hostErrorHash, $_;
					}
			}
		}
	}
}

say Dumper(\%failHash);
say Dumper(\@hostErrorHash);





