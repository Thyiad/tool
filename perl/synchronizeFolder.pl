#! perl
#���ܣ�
#	�Զ�����һ���ļ���������ļ�������һ���ļ���
#��������:
#	"SRC_FOLDER=Դ�ļ���1?DST_FOLDER=Ŀ���ļ���1|Ŀ���ļ���2"
#��:
#	perl SynchronizeFolder.pl "SRC_FOLDER=D:\test\bcpTest?DST_FOLDER=D:\test\bcpTest-bak|D:\test\bcpTest2-bak"		
#
use strict;
use warnings;
use File::Copy;
use 5.018;

push @INC,substr($0,0,rindex($0,"\\"));
require "Log.pm";;

#----------------------------------------------------------------------
#��������
my %srcDstHash;
#----------------------------------------------------------------------
#��������
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
#������֤
if(scalar(keys %srcDstHash)< 1) {
	Log::ERROR("Դ�ļ���δ�趨��");
	exit;
}
foreach(keys %srcDstHash){
	if(@{$srcDstHash{$_}} < 1){
		Log::ERROR("$_��Ŀ���ļ���δ�趨��");
		exit;
	}
}
#----------------------------------------------------------------------
#main
while(my ($srcDir, $dstDir_ref) = each %srcDstHash){
	# ȡԴ�ļ�������������ļ�
	my @srcFiles = &_getFileListFromDir($srcDir);
	foreach my $dstDir (@{$dstDir_ref}){
		# ȡĿ���ļ�������������ļ�
		my @dstFiles = &_getFileListFromDir($dstDir);
		#say join "\n", @dstFiles;
		foreach my $srcFile (@srcFiles){
			# ��⵱ǰ�ļ������Ƿ��и��ļ�
			#say $srcDir;
			#say $srcFile;
			my $curFileWipeDir = $srcFile =~ s/^\Q$srcDir\E//r;
			#say $curFileWipeDir;
			
			my $oppositeDstFile = $dstDir.$curFileWipeDir;
			#say $oppositeDstFile;
			if($oppositeDstFile ~~ @dstFiles){	
				# �оͽ����ж��ļ���Ϣ�Ƿ�һ������һ������Ҫ����
				my($dev_src,$ino_src,$mode_src,$nlink_src,$uid_src,$gid_src,$rdev_src,$size_src,
					   $atime_src,$mtime_src,$ctime_src,$blksize_src,$blocks_src)
						   = stat($srcFile);	# Դ�ļ���״̬
				my($dev_bak,$ino_bak,$mode_bak,$nlink_bak,$uid_bak,$gid_bak,$rdev_bak,$size_bak,
					   $atime_bak,$mtime_bak,$ctime_bak,$blksize_bak,$blocks_bak)
						   = stat($oppositeDstFile);	# Ŀ���ļ���״̬	
						   
				next if($size_src == $size_bak and $mtime_src == $mtime_bak);
				my $dir = substr $oppositeDstFile, 0 , rindex($oppositeDstFile, "\\");
				mkdir($dir) unless(-d $dir);	# ���������ڵ��ļ���		
				(copy($srcFile, $oppositeDstFile) and say "�����ˣ�$oppositeDstFile") or say "error: $!";
			}
			else{	
				my $dir = substr $oppositeDstFile, 0 , rindex($oppositeDstFile, "\\");
				mkdir($dir) unless(-d $dir);	# ���������ڵ��ļ���	
				(copy($srcFile, $oppositeDstFile) and say "�����ˣ�$oppositeDstFile") or say "error: $!";
			}
		}
	}
}

#-------ȡ�����е��ļ�------------
#-------ע�⣺�ļ��в�����\��/��β---
sub _getFileListFromDir($){
	my @findFileArray = ();
	
	my $rootDirName = shift @_;
	my @tmpDirs = ($rootDirName.'\\');
	
	unless(-d $rootDirName and -e $rootDirName){
		Log::WARN("Ŀ¼ $rootDirName �����ڣ�\n");
		return @findFileArray;
	}
	
	my ($dir, $file);
	while ($dir = pop(@tmpDirs)) {
        local *DH;
        if (!opendir(DH, $dir)) {
			Log::WARN("�޷����ļ��� $dir: $! $^E\n");
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

