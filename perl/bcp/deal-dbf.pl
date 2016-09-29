use strict;
use warnings;
use 5.018;
use utf8;
use Data::Dumper;
binmode STDOUT, ':encoding(gb2312)';
binmode STDERR, ':encoding(gb2312)';

# operator.dbf
# SPATH-文件路径,SFILE-文件名, DPATH-目标路径, DFILE-目标文件, CLTJ-DBF筛选条件, CLLX-类型
# CLLX-复制、URAR、UZIP、合并、MOVE、NRFZ、RO、DSSE
open my $fh_o, '<:encoding(utf8)', 'C:\Users\Administrator\Desktop\operator.TXT' or die 'Can not open file:\n $!';
my @operData;
while(<$fh_o>){
	chomp;
	# 处理通配
	s/YYYYMMDD/\${day:yyyymmdd}/ig;
	s/(?<!YY)YYMMDD/\${day:yymmdd}/ig;
	s/(?<!YY)MMDD/\${day:mmdd}/ig;
	s/(?<!M)MDD/\${day:add}/ig;
	s/DDMMYY/\${day:ddmmyy}/ig;
	my ($SPATH, $SFILE, $DPATH, $DFILE, $CLTJ, $CLLX) = split '\t';
	# 取得数据
	push @operData, +{
		srcDir=>$SPATH,
		srcFile=>$SFILE,
		dstDir=>$DPATH,
		dstFile=>$DFILE,
		dbfFilter=>$CLTJ,
		dealType=>$CLLX,
	};
}
my @copyData = grep {$_->{dealType} eq '复制'} @operData;
my @otherData = grep{not $_->{dealType} eq '复制'} @operData;

# 找出能处理的复制任务->源文件名和目标文件名一致并且没有dbf过滤
my @canOperFiles;
my @copySrcDstNotEq;
my @dbfFilter;
foreach(@copyData){
	if(not $_->{dbfFilter} eq ''){
		push @dbfFilter, $_;
	}
	elsif(not fc($_->{srcFile}) eq fc($_->{dstFile})){
		push @copySrcDstNotEq, $_;
	}
	else{
		push @canOperFiles, $_;
	}
}

open my $out, '>:encoding(gb2312)', 'C:\Users\Administrator\Desktop\out.txt';
open my $outNoOper, '>:encoding(gb2312)', 'C:\Users\Administrator\Desktop\noOper.txt';

@otherData = sort {$a->{dealType} cmp $b->{dealType}} @otherData;
@copySrcDstNotEq = sort {$a->{dealType} cmp $b->{dealType}} @copySrcDstNotEq;
@dbfFilter = sort {$a->{dealType} cmp $b->{dealType}} @dbfFilter;

# 输出不能被处理的文件
say $outNoOper '---------复制后文件名有变更的任务---------------------';
for(@copySrcDstNotEq){
	say $outNoOper 'srcFile='.$_->{srcDir}.$_->{srcFile};
	say $outNoOper 'dstFile='.$_->{dstDir}.$_->{dstFile};
	say $outNoOper 'dbfFilter='.$_->{dbfFilter};
	say $outNoOper 'dealType='.$_->{dealType};
	say $outNoOper '-----------------------------------------------';
}
say $outNoOper "\n\n\n\n\n\n";
say $outNoOper '---------需要配置成DBF文件过滤的任务---------------------';
for(@dbfFilter){
	say $outNoOper 'srcFile='.$_->{srcDir}.$_->{srcFile};
	say $outNoOper 'dstFile='.$_->{dstDir}.$_->{dstFile};
	say $outNoOper 'dbfFilter='.$_->{dbfFilter};
	say $outNoOper 'dealType='.$_->{dealType};
	say $outNoOper '-----------------------------------------------';
}
say $outNoOper "\n\n\n\n\n\n";
say $outNoOper '---------其他类型的任务---------------------';
for(@otherData){
	say $outNoOper 'srcFile='.$_->{srcDir}.$_->{srcFile};
	say $outNoOper 'dstFile='.$_->{dstDir}.$_->{dstFile};
	say $outNoOper 'dbfFilter='.$_->{dbfFilter};
	say $outNoOper 'dealType='.$_->{dealType};
	say $outNoOper '-----------------------------------------------';
}

# 开始处理能被处理的文件
# 找出目标文件夹一样的文件
my %dirFileHash;
for(@canOperFiles){
	push @{$dirFileHash{fc $_->{dstDir}}}, $_;
}

foreach(keys %dirFileHash){
	say $out '--------------------------------------------';
	say $out 'TASK_NAME=fromDBF_'.$_;
	say $out 'FILE_GROUP=fromDBF_'.$_;
	say $out 'HOST_IPADDR='.'UNKNOWN';
	say $out 'COPYTO_IPADDR='.'UNKNOWN';
	say $out 'COPYTO_DIR='.$_;
	foreach(@{$dirFileHash{$_}}){
		say $out $_->{srcDir}.$_->{srcFile};
	}
	say $out 'FILE_REGEX=';
	say $out '--------------------------------------------';
}

# 找出目标路径一致的条目
# control.dbf
# SPATH-文件路径, SFILE-文件名, FRQ-文件日期, FSIZE-文件大小, FNU-文件个数, CLSJ-处理时间, CLRQ-处理日期, CLSIZE-处理大小, FSJ-时间-？, SJSJ-时间-？

