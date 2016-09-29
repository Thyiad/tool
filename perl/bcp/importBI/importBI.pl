use 5.018;
use utf8;
use Data::Dumper;
binmode STDOUT, ':encoding(gb2312)';
use FindBin qw($Bin);
use lib $Bin;
use Spreadsheet::ParseExcel;
use Encode qw(encode decode);
use Spreadsheet::ParseExcel::Utility qw(ExcelFmt ExcelLocaltime LocaltimeExcel);
my $oExcel = new Spreadsheet::ParseExcel;



my $src_file = "$Bin/template.xls";
my $out_sql="$Bin/outSql.sql";

my $parser   = Spreadsheet::ParseExcel->new();
my $workbook = $parser->parse($src_file);
 
if ( !defined $workbook ) {
    die $parser->error(), ".\n";
}
 
my @biContentList = ();
my ($BICustomID,$BIContent,$BIType,$BITimeType,$WorkDayValid,$BIStartTime,$BINormal,$BIException,$Comment);
for my $worksheet ( $workbook->worksheets() ) {
 
    my ( $row_min, $row_max ) = $worksheet->row_range();
    my ( $col_min, $col_max ) = $worksheet->col_range();
	
    for my $row ( $row_min .. $row_max ) {
		next unless $row>0;
		
		my $content = {};
        for my $col ( $col_min .. $col_max ) {
            my $cell = $worksheet->get_cell( $row, $col );
            next unless $cell;
			
			my $cellValue = $cell->value();
			if($cell->type() eq "Date"){
				if(length($cellValue) > 9){
					$cellValue = ExcelFmt('yyyy-m-d h:mm', $cell->unformatted());
				}
			}
			
			if($col == 0){
				$BIStartTime = $cellValue;
			}
			elsif($col == 1){
				$BIType = $cellValue;
			}
			elsif($col == 2){
				$BIContent = $cellValue;
			}
			elsif($col == 3){
				$BINormal = $cellValue;
			}
			elsif($col == 4){
				$BIException = $cellValue;
			}
			elsif($col == 5){
				$Comment = $cellValue;
			}
        }
		$content->{BICustomID} = defined($BICustomID)?$BICustomID:'';
		$content->{BIContent} = defined($BIContent)?$BIContent:'';
		$content->{BIType} = defined($BIType)?$BIType:'';
		$content->{BITimeType} = defined($BITimeType)?$BITimeType:'EveryDay';
		$content->{WorkDayValid} = defined($WorkDayValid)?$WorkDayValid:'True';
		$content->{BIStartTime} = defined($BIStartTime)?$BIStartTime:'';
		if(length($content->{BIStartTime}) > 9){
			$content->{BITimeType} = 'Once';
		}
		else{
			$content->{BIStartTime} = "2015-03-17 ".$content->{BIStartTime};
		}
		$content->{BINormal} = defined($BINormal)?$BINormal:'';
		$content->{BIException} = defined($BIException)?$BIException:'';
		$content->{Comment} = defined($Comment)?$Comment:'';
		push @biContentList ,$content;
		undef $BICustomID;
		undef $BIContent;
		undef $BIType;
		undef $BITimeType;
		undef $WorkDayValid;
		undef $BIStartTime;
		undef $BINormal;
		undef $BIException;
		undef $Comment;
    }
}
# 写入sql
open(my $out, ">:encoding(UTF-8)", $out_sql) or die "Could not open file: $!";
say $out "declare \@biTypeID int;";

for(@biContentList){
	say $out "set \@biTypeID=(select top 1 ID from bcp.dbo.B_BIType where BIType = \'$_->{BIType}\');";
	say $out "if \@biTypeID is null";
	say $out "begin";
	say $out "	INSERT INTO [bcp].[dbo].[B_BIType] ([BIType] ,[ParentID]) VALUES (\'$_->{BIType}\' ,-1);";
	say $out "	set \@biTypeID=(select \@\@IDENTITY)";
	say $out "end";
	say $out "INSERT INTO [BCP].[dbo].[B_BIContent] ([BITypeID] ,[BICustomID] ,[BIContent] ,[BITimeType] ,[WorkDayValid] ,[BIStartTime] ,[BINormal] ,[BIException] ,[Comment]) VALUES (\@biTypeID ,\'$_->{BICustomID}\' ,\'$_->{BIContent}\' ,\'$_->{BITimeType}\' ,\'$_->{WorkDayValid}\' ,\'$_->{BIStartTime}\' ,\'$_->{BINormal}\' ,\'$_->{BIException}\' ,\'$_->{Comment}\');";
}
say $out "delete  FROM [BCP].[dbo].[B_BIContent] where ID not in(select MIN(ID) from [BCP].[dbo].[B_BIContent] Group by BITypeID, BIStartTime, BIContent);";
