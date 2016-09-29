use 5.018;
use File::Basename qw(dirname);
use Data::Dumper;
use Encode;
use Time::Piece;

while(1){

	my $dt = localtime;
	
	my $mday = $dt->mday;
	my $hour = $dt->hour;
	if( $mday< 20){
		say "now mday is $mday, sleeping...";
		sleep 60*30;
	}
	elsif($mday == 20){
		if($hour < 3){
			say "now mday is 20 and hour is $hour, sleeping...";
			sleep 60*30;
		}
		else{
			# do work
			 my @str = `perl "C:\\Users\\Administrator\\Desktop\\create file.pl"`; 
			say @str;
			my $fh;
			open($fh, '>', 'D:\st.txt') or die "open st.txt fail: $!";
			say $fh encode("utf-8",decode("utf-8",join '',@str));
			last;
		}
	}
	else{
		last;
	}
}
