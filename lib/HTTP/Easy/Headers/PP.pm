package HTTP::Easy::Headers::PP;

use strict;
use warnings;

sub new { my $pk = shift; bless shift,$pk }

# Adopted from MLEHMANN's AnyEvent::HTTP and ELMEX's AnyEvent::HTTPD
sub decode {
	my $pk = shift;
	local $_ = shift;
	my %args = @_;
	my %h;
	y/\015//d;
	
	$h{lc $1} .= ",$2"
		while /\G
			([^:\000-\037]+)[\011\040]*:           # Key:
			[\011\040]*                            # LWS*
			( (?: [^\012]+ | \012 [\011\040] )* )  # ( 1-line value | \n\t )
			(?: \012 | \Z )
		/sgcxo;
	
	warn "Garbled headers, left buffer: <$1>\n" if /\G(.+)$/;
	
	for (values %h) {
		substr $_, 0, 1, '';
		# remove folding:
		s/\012([\011\040]+)/ /sgo;
		s{[\011\040]+$}{}so;
	}
	if (exists $h{location} and $h{location} !~ /^(?: $ | [^:\/?\#]+ : )/xo and $args{base}) {
		$h{location} = ''.URI->new_abs($h{location},$args{base});
	}
	bless \%h, $pk;
}

sub HTTP {
	my $self = shift;
	if (@_) {
		$self->{Status} = shift;
		$self->{Reason} = shift if @_;
		$self->{HTTPVersion} = shift if @_;
		$self;
	} else {
		return "$self->{Status} $self->{Reason} HTTP/$self->{HTTPVersion}";
	}
}

our @hdr = map { lc $_ }
our @hdrn  = (
	qw(Upgrade),
	qw(Accept Accept-Charset Accept-Encoding Accept-Language Accept-Ranges),
  qw(Allow Authorization Cache-Control Connection Content-Disposition),
  qw(Content-Encoding Content-Length Content-Range Content-Type Cookie DNT),
  qw(Date ETag Expect Expires Host If-Modified-Since Last-Modified Link),
  qw(Location Origin Proxy-Authenticate Proxy-Authorization Range),
  qw(WebSocket-Origin WebSocket-Location Sec-WebSocket-Origin Sec-Websocket-Location ),
  qw(Sec-WebSocket-Accept Sec-WebSocket-Extensions Sec-WebSocket-Key),
  qw(Sec-WebSocket-Protocol Sec-WebSocket-Version Server Set-Cookie Status),
  qw(TE Trailer Transfer-Encoding Upgrade User-Agent Vary WWW-Authenticate),
  qw(X-Requested-With),
);
=for rem
qw(
	Upgrade Connection Content-Type
	WebSocket-Origin WebSocket-Location Sec-WebSocket-Origin Sec-Websocket-Location Sec-WebSocket-Key Sec-WebSocket-Accept Sec-WebSocket-Protocol
	Origin
	Accept-Encoding
	Host
	Accept-Language
	Accept-Charset
	User-Agent
	Content-Type
	Accept
	Referer
	X-Requested-With
	Connection
	Content-Length
);

=cut

our %hdr; @hdr{@hdr} = @hdrn;
our %hdri; @hdri{ @hdr } = 0..$#hdr;

sub encode {
	my $pk = shift;
	no warnings;
	my $h = @_ || !ref $pk ? shift : $pk;
	my $reply = '';
	my @good;my @bad;
	for (keys %$h) {
		if (length $h->{$_}) {
			if (exists $hdr{lc $_}) { $good[ $hdri{lc $_} ] = $hdr{ lc $_ }.": ".$h->{$_}."\015\012"; }
			else { push @bad, "\u\L$_\E: ".$h->{$_}."\015\012"; }
		}
	}
	defined() and $reply .= $_ for @good,@bad;
	return $reply;
	#join ( "", map defined $h->{$_} ? "\u\L$_\E: $h->{$_}\015\012" : '', keys %$h )
}

1;
