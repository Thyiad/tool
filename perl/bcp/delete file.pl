# use Cwd qw(abs_path getcwd cwd);
use 5.018;
use List::Util qw(max);
use File::Basename qw(dirname);
use Data::Dumper;
use warnings FATAL => 'utf8';

# 通配常量
use constant TA=>'${TA}';
use constant SALE=>'${SALE}';
use constant DAY_YYYYMMDD=>'${day:yyyymmdd}';
use constant YESTERDAT_YYYYMMDD=>'${day-1:yymmdd}';
use constant DAY_YYMMDD=>'${day:yymmdd}';
use constant BANK=>'${BANK}';
use constant DAY_MMDD=>'${day:mmdd}';
# 系统代码
my @sale;
my $ta='55';
my $bank = '003';
# 日期通配符
my $yyyymmdd = '20141125';
my $yymmdd = substr($yyyymmdd, 2);
my $mmdd = substr($yyyymmdd, 4);
my $yesterday_yyyymmdd = $yyyymmdd - 1;
# 起始目录
my $baseFolder = 'D:\test\BCPSkyDriverFile';

@ARGV = q(C:\Users\Administrator\Desktop\tmp\deal IFile\IFile.ini);
my $line= 0;
while(<>){

	$line++;
	chomp;
	next unless($line > 15 and $line<75);
	next if(/^;/);
	if(/^(.+)\=/){
		push @sale, $1;
	}
}

#print Dumper(\@ta);
#exit 0;

# 路径的通配
my @parsedFile;
@ARGV = q(C:\Users\Administrator\Desktop\tmp\deal IFile\tmpresult.txt);
# @ARGV = q(C:\Users\Administrator\Desktop\rarFiles.txt);
while(<>){
	chomp;
	# (say $_ and next) unless(/^[A-z]:/);
	next unless(/^[A-z]:/);
	
	push @parsedFile, $_ unless($_~~@parsedFile);
}
  # print Dumper(\@parsedFile);
  # exit 0;
# 处理普通的通配
foreach(@parsedFile){
	s/\$\{day:yyyymmdd\}/$yyyymmdd/g;
	s/\$\{day:yymmdd\}/$yymmdd/g;
	s/\$\{day-1:yyyymmdd\}/$yesterday_yyyymmdd/g;
	s/\$\{day:mmdd\}/$mmdd/g;
	s/\$\{TA\}/$ta/g;
	s/\$\{BANK\}/$bank/g;
}

# 处理销售商代码通配
@parsedFile = map{
	my $curFile = $_;
	if(/\$\{SALE\}/){
		map{
			$curFile =~ s/\$\{SALE\}/$_/gr;
		} @sale;
	}
	else{
		$curFile;
	}
} @parsedFile;

# 拼接本地真实路径
my @endedFiles = map{
	my $folder;
	if(/^z:/i){
		# s/^[A-z]:/$baseFolder\\Z/r;
		$_;
	}
	elsif(/^y:/i){
		# s/^[A-z]:/$baseFolder\\Y/r;
		$_;
	}
	elsif(/^w:/i){
		# s/^[A-z]:/$baseFolder\\W/r;
		# $_;
	}
	else{
		say "既不是Z盘也不是Y盘也不是W盘：$_";
		"not support file";
	}
	
} @parsedFile;

@endedFiles = grep{not $_ eq "not support file"} @endedFiles;

  # print Dumper(\@endedFiles);
  # exit 0;
  
# 删除文件
my $totalCount = scalar @endedFiles;
my $delCount = unlink @endedFiles;
say "del $delCount files. total $totalCount files.";
  




