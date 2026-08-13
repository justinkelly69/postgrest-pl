use 5.32.0;

use Mojo::JWT;

package Token;

sub new_token {
    my ($role, $secret, $seconds) = @_;

    my $future_time = int(time() + $seconds);

    #say "FUTURE_TIME $future_time";
    #say "SECRET $secret";
    #say "ROLE $role";

    my $jwt = Mojo::JWT->new(
        claims => {
            role => $role,
            exp  => $future_time
        },
        secret => $secret
    )->encode;

    #say "JWT $jwt";

    return $jwt;
}

sub get_secret {
    my($file) = @_;

    open (my $fh, '<', $file) or die "Can't open $file $!\n";
    while (readline $fh){
        $_ =~ /^\s*([a-z-]+)\s*=\s*"([A-Za-z0-9_-]+)"/;
        return $2 if($1 eq 'jwt-secret');
    }
    close($fh);
}


1;
