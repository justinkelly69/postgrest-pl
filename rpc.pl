#!/usr/bin/env perl

use 5.32.0;
use JSON::PP   qw|encode_json decode_json|;
use Data::Dump qw(dump);

use lib 'lib';
use Postgrest qw(exec from eq);
use Token     qw(new_token get_secret);

my $conf    = './tutorial.conf';
my $secret  = Token::get_secret($conf);
my $seconds = 30000;
my $role    = 'todo_user';

my $token = Token::new_token( $role, $secret, $seconds );
my $url   = 'http://localhost:3000';
say '-------------------------------------------------';
say "TOKEN: $token";
say '-------------------------------------------------';

my $rpc1 =
  Postgrest->new( { url => $url } )->rpc( 'add_them', { a => 3, b => 4 } )->exec($token);
say 'RPC1:' . dump $rpc1;

my $rpc2 =
  Postgrest->new( { url => $url } )->rpc( 'greet_user', {username => "Santa Claus"} )->exec($token);
say 'RPC2:' . dump $rpc2;
