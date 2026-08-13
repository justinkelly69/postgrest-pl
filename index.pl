#!/usr/bin/env perl

use 5.32.0;
use JSON::PP   qw|encode_json decode_json|;
use Data::Dump qw(dump);

use lib 'lib';
use Postgrest qw(exec, from eq) ;
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

Postgrest->new({url => $url})->from('todos')
    ->insert([
        {task => 'Larry'},
        {task => 'Curly'},
        {task => 'Moe'},
        {task => 'Laurel'},
        {task => 'Hardy'},
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
    ->insert({task => 'Gone With The Wind'})
    ->exec($token);

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say "SINGLE INSERT:\n$result";
say '-------------------------------------------------';

Postgrest->new( { url => $url } )->from('todos')
    ->update({task => 'Benny'})
    ->eq('task', "Laurel")
    ->exec($token);

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say "UPDATE Laurel TO Benny:\n$result";
say '-------------------------------------------------';

Postgrest->new( { url => $url } )
    ->from('todos')
    ->delete()
    ->eq('task', "Hardy")
    ->exec($token);

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->exec($token);

say "DELETE Hardy:\n$result";
say '-------------------------------------------------';

$result = Postgrest->new({url => $url})
    ->from('todos')
    ->select(' id, due, task , done ')
    ->eq('task', 'Curly')
    ->exec($token);

say "SELECT Curly:\n$result";
say '-------------------------------------------------';
