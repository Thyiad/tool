#! perl
#功能：
#	自动备份一个文件夹里面的文件到另外一个文件夹
#参数设置:
#	"SRC_FOLDER=源文件夹1?DST_FOLDER=目标文件夹1|目标文件夹2"
#例:
#	perl SynchronizeFolder.pl "SRC_FOLDER=D:\test\bcpTest?DST_FOLDER=D:\test\bcpTest-bak|D:\test\bcpTest2-bak"		
#
use strict;
use warnings;
use File::Copy;
use 5.018;

push @INC,substr($0,0,rindex($0,"\\"));
require "Log.pm";;

#----------------------------------------------------------------------
#参数声明
my %srcDstHash;
#----------------------------------------------------------------------
#参数解析
my $pattern = '^SRC_FOLDER=(.*)\?DST_FOLDER=(.*)$';
for(@ARGV)
{
	if(m/$pattern/i){
		my $srcDir = $1 =~ s/^\s+|\s+$//r;
		my $dstDirStr = $2 =~ s/^\s+|\s+$//r;
		my @dstDir = split '\|', $dstDirStr;
		$srcDstHash{$srcDir} = \@dstDir;
	}
}
#----------------------------------------------------------------------
#参数验证
if(scalar(keys %srcDstHash)< 1) {
	Log::ERROR("源文件夹未设定！");
	exit;
}
foreach(keys %srcDstHash){
	if(@{$srcDstHash{$_}} < 1){
		Log::ERROR("$_的目标文件夹未设定！");
		exit;
	}
}
#----------------------------------------------------------------------
#main
while(my ($srcDir, $dstDir_ref) = each %srcDstHash){
	# 取源文件夹里面的所有文件
	my @srcFiles = &_getFileListFromDir($srcDir);
	foreach my $dstDir (@{$dstDir_ref}){
		# 取目标文件夹里面的所有文件
		my @dstFiles = &_getFileListFromDir($dstDir);
		#say join "\n", @dstFiles;
		foreach my $srcFile (@srcFiles){
			# 检测当前文件夹中是否有该文件
			#say $srcDir;
			#say $srcFile;
			my $curFileWipeDir = $srcFile =~ s/^\Q$srcDir\E//r;
			#say $curFileWipeDir;
			
			my $oppositeDstFile = $dstDir.$curFileWipeDir;
			#say $oppositeDstFile;
			if($oppositeDstFile ~~ @dstFiles){	
				# 有就接着判断文件信息是否一样，不一样就需要备份
				my($dev_src,$ino_src,$mode_src,$nlink_src,$uid_src,$gid_src,$rdev_src,$size_src,
					   $atime_src,$mtime_src,$ctime_src,$blksize_src,$blocks_src)
						   = stat($srcFile);	# 源文件的状态
				my($dev_bak,$ino_bak,$mode_bak,$nlink_bak,$uid_bak,$gid_bak,$rdev_bak,$size_bak,
					   $atime_bak,$mtime_bak,$ctime_bak,$blksize_bak,$blocks_bak)
						   = stat($oppositeDstFile);	# 目标文件的状态	
						   
				next if($size_src == $size_bak and $mtime_src == $mtime_bak);
				my $dir = substr $oppositeDstFile, 0 , rindex($oppositeDstFile, "\\");
				mkdir($dir) unless(-d $dir);	# 创建不存在的文件夹		
				(copy($srcFile, $oppositeDstFile) and say "复制了：$oppositeDstFile") or say "error: $!";
			}
			else{	
				my $dir = substr $oppositeDstFile, 0 , rindex($oppositeDstFile, "\\");
				mkdir($dir) unless(-d $dir);	# 创建不存在的文件夹	
				(copy($srcFile, $oppositeDstFile) and say "复制了：$oppositeDstFile") or say "error: $!";
			}
		}
	}
}

#-------取出所有的文件------------
#-------注意：文件夹不能有\或/结尾---
sub _getFileListFromDir($){
	my @findFileArray = ();
	
	my $rootDirName = shift @_;
	my @tmpDirs = ($rootDirName.'\\');
	
	unless(-d $rootDirName and -e $rootDirName){
		Log::WARN("目录 $rootDirName 不存在！\n");
		return @findFileArray;
	}
	
	my ($dir, $file);
	while ($dir = pop(@tmpDirs)) {
        local *DH;
        if (!opendir(DH, $dir)) {
			Log::WARN("无法打开文件夹 $dir: $! $^E\n");
            next;
        }
        foreach (readdir(DH)) {
            if ($_ eq '.' || $_ eq '..') {
                next;
            }
            $file = $dir.$_;         
            if (!-l $file && -d _) {
                $file .= '/';
                push(@tmpDirs, $file);
            }
			else{
				push @findFileArray, $file;
			}
        }
        closedir(DH);
    }
	
	return @findFileArray;
}

