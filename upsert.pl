#!/usr/bin/env perl

use 5.32.0;
use JSON::PP   qw|encode_json decode_json|;
use Data::Dump qw(dump);

use lib 'lib';
use Postgrest qw(exec from eq) ;
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

Postgrest->new( { url => $url } )
    ->from('todos')
    ->delete()
    ->exec($token);

my $result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say 'INITIAL STATE:' . $result;
say '-------------------------------------------------';

Postgrest->new({url => $url})
    ->from('todos')
    ->insert([
        {id => 1, task => 'Wake Up'},
        {id => 2, task => 'Rise and Shine'},
    ])
    ->exec($token);

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say "BULK INSERT:\n$result";
say '-------------------------------------------------';

Postgrest->new({url => $url})
    ->from('todos')
    ->upsert([
        {id => 2, task => 'Go Back to Bed'},
        {id => 3, task => 'Sweet Dreams'},
    ])
    ->exec($token);

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say "BULK UPSERT:\n$result";
say '-------------------------------------------------';
