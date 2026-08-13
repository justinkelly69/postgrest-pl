#!/usr/bin/env perl
use 5.32.0;

use lib 'lib';
use Supabase::DB qw|DB from|;

my $sb = Supabase::DB->new( { url => 'http://aol.com/' } );

$sb->from('users')
  ->select('larry,curly,moe')
  ->eq('last_name', 'in(all.[1,2,3])')
  ->neq( 'name', 'hardy' )
  ->gt( 'name', 'larry' )
  ->lt( 'name', 'curly' )
  ->gte( 'name', 'moe' )
  ->lte( 'name', 'dougal' )
  ->like( 'descripton', '%fizz%' )
  ->ilike( 'street', '%buzz%' )
  ->match('name', '[a-z]*')
  ->imatch('job', '[A-Z]*')
  ->in('stooges', ['larry','curly','moe'])
  ->or('books.eq.2,and(a.eq.10,b.eq.20,title.eq.hello)')
  ->and('books.eq.2,or(a.eq.10,b.eq.20,title.eq.hello)')
  ->not('book','lte','22')
  ->contains('books', '"[1,2,3,4]"')
  ->contained_by('books', '"[1,2,3,4]"')
  ->order( 'name',    { ascending => 1 } )
  ->order( 'address', { ascending => 0 } )
  ->order('description');

say( 'QUERY:', $sb->query );
