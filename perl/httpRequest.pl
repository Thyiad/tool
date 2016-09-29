use 5.018;
use utf8;
use Data::Dumper;
binmode STDOUT, ':encoding(gb2312)';
use LWP::UserAgent;

# use FindBin qw($Bin);
# use lib $Bin;
use Encode qw(encode decode);

my $browser = LWP::UserAgent->new(
    agent =>
"Mozilla/5.0 (Windows NT 6.1; WOW64) AppleWebKit/537.36 (KHTML, like Gecko) Chrome/39.0.2171.95 Safari/537.36",
    from            => undef,
    conn_cache      => undef,
    cookie_jar      => undef,
    default_headers => HTTP::Headers->new(
        Content_Type      => 'text/html;version=3.2',
        MIME_Version      => '1.0',
        Accept            => [qw(text/html text/plain image/*)],
        'Accept-Language' => "zh-CN,zh;q=0.8",
    ),
    timeout => 180
);

# get request:
# my $url = 'http://www.baidu.com';
#my $url = 'http://ask.dcloud.net.cn/question/3793';
my $url = 'http://192.168.1.65/testtest.php?action=login';
# my $url = 'http://bbs.chinaunix.net/images/default/logo.gif';

my $response = $browser->post($url);
die "Can't get $url -- ", $response->status_line
  unless $response->is_success;

# say Dumper(\$response);
my $content = $response->content;
$content = decode( 'utf8', $content );
say $content;
