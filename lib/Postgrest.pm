use 5.32.0;

use Mojo::UserAgent;

package Postgrest;

use LWP::UserAgent;
use Switch;
use JSON::PP qw|encode_json decode_json|;

use Class::Tiny qw(
	url
	uri
	has_from
	is_query
	has_order
	body
	command
);

sub exec {
    my ( $self, $token ) = @_;

    my $ua = LWP::UserAgent->new;
    $ua->default_header( 'Authorization' => "Bearer $token" ) if ($token);
    $ua->default_header( 'Content-Type'  => 'application/json' );
    my $res;

    switch ( $self->command ) {
        case 'rpc' {
            $res =
              $ua->post( $self->uri, Content => encode_json( $self->body ) );
        }
        case 'select' {
            $res = $ua->get( $self->uri );
        }
        case 'insert' {
            $res =
              $ua->post( $self->uri, Content => encode_json( $self->body ) );
        }
        case 'upsert' {
            $ua->default_header( 'Prefer' => 'resolution=merge-duplicates' );
            say 'URI:' . $self->uri;
            say 'BODY:' . encode_json($self->body);
            $res =
              $ua->post( $self->uri, Content => encode_json( $self->body ) );
        }
        case 'update' {
            $res =
              $ua->patch( $self->uri, Content => encode_json( $self->body ) );
        }
        case 'delete' {
            $res = $ua->delete( $self->uri );
        }
        else {
            die "Invalid method";
        }
    }

    if ( $res->is_success ) {
        return $res->decoded_content;
    }
    else {
        die $res->status_line;
    }

    return $self;
}

sub rpc {
    my ($self, $rpc, $body) = @_;

    $self->url =~ m|.*?(/rpc)?(/)?$|;

    if($1 eq '/rpc'){
        if($2 eq '/'){
            $self->uri($self->url . $rpc);
        }
        else {
            $self->uri($self->url . '/' . $rpc);
        }
    }
    else {
        $self->uri($self->url . '/rpc/' . $rpc);
    }

    $self->body($body);
    $self->has_from(1);
    $self->command('rpc');

    say 'BODY:' . encode_json($self->body);
    say 'URI:' . $self->uri;

    return $self;
}

sub from {
    my ( $self, $table ) = @_;

    if ( substr( $self->url, length( $self->url ) - 1, 1 ) ne '/' ) {
        $self->uri( $self->url . '/' . $table );
    }
    else {
        $self->uri( $self->url . $table );
    }
    $self->has_from(1);

    return $self;
}

sub select {
    my ( $self, $fields ) = @_;

    $self->is_query(1);
    $self->command('select');

    $self->uri( $self->uri . '?select=' . format_fields($fields) )
      if ($fields);

    return $self;
}

sub insert {
    my ( $self, $body ) = @_;

    $self->is_query(1);
    $self->command('insert');
    $self->body($body);

    return $self;
}

sub upsert {
    my ( $self, $body ) = @_;

    $self->is_query(1);
    $self->command('upsert');
    $self->body($body);

    return $self;
}

sub update {
    my ( $self, $body ) = @_;

    $self->is_query(1);
    $self->command('update');
    $self->body($body);

    return $self;
}

sub delete {
    my ($self) = @_;

    $self->is_query(1);
    $self->command('delete');

    return $self;
}

sub _compare {
    my ( $self, $op, $field, $value ) = @_;

    my $sep = first_op( $self->uri ) ? '&' : '?';
    $self->uri( $self->uri . "$sep$field=$op.$value" );

    return $self;
}

sub eq {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'eq', $field, $value );
}

sub gt {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'gt', $field, $value );
}

sub gte {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'gte', $field, $value );
}

sub lt {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'lt', $field, $value );
}

sub lte {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'lte', $field, $value );
}

sub neq {
    my ( $self, $field, $value ) = @_;
    return _compare( $self, 'neq', $field, $value );
}

sub in {
    my ( $self, $field, $values ) = @_;

    my $newValues = join( ',', @$values );
    $self->uri( $self->uri . "&$field=in.($newValues)" );

    return $self;
}

sub or {
    my ( $self, $or_string ) = @_;
    $self->uri( $self->uri . "&or=($or_string)" );
    return $self;
}

sub and {
    my ( $self, $or_string ) = @_;
    $self->uri( $self->uri . "&and=($or_string)" );
    return $self;
}

sub not {
    my ( $self, $item, $operand, $value ) = @_;
    $self->uri( $self->uri . "&$item=not.$operand.$value" );
    return $self;
}

sub contains {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=cs.$value" );
    return $self;
}

sub contained_by {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=cd.$value" );
    return $self;
}

sub overlap {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=ov.$value" );
    return $self;
}

sub sl {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=sl.$value" );
    return $self;
}

sub sr {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=sr.$value" );
    return $self;
}

sub nxl {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=nxl.$value" );
    return $self;
}

sub nxr {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=nxr.$value" );
    return $self;
}

sub adj {
    my ( $self, $column, $value ) = @_;
    $self->uri( $self->uri . "&$column=adj.$value" );
    return $self;
}

sub like {
    my ( $self, $field, $value ) = @_;
    return _like( $self, $field, $value, 0 );
}

sub ilike {
    my ( $self, $field, $value ) = @_;
    return _like( $self, $field, $value, 1 );
}

sub _like {
    my ( $self, $field, $value, $i ) = @_;

    my $query     = $self->uri;
    my $likeIlike = $i ? 'ilike' : 'like';

    $value = format_fields($value);
    $value =~ s/%/*/g;
    $self->uri("${query}&${field}=${likeIlike}.${value}");

    return $self;
}

sub match {
    my ( $self, $field, $value ) = @_;
    return _match( $self, $field, $value, 0 );
}

sub imatch {
    my ( $self, $field, $value ) = @_;
    return _match( $self, $field, $value, 1 );
}

sub _match {
    my ( $self, $field, $value, $i ) = @_;

    my $query       = $self->uri;
    my $matchImatch = $i ? 'imatch' : 'match';
    $self->uri("${query}&${field}=${matchImatch}.${value}");

    return $self;
}

#"order=title.desc,description.asc,name.desc"
sub order {
    my ( $self, $field, $ascending ) = @_;

    if ( !$self->has_order ) {
        $self->uri( $self->uri . '&order=' );
        $self->has_order(1);
    }
    else {
        $self->uri( $self->uri . ',' );
    }

    if (  !$ascending
        || $ascending->{ascending} == 0
        || $ascending->{ascending} eq 'false' )
    {
        $self->uri( $self->uri . "${field}.desc" );
    }
    else {
        $self->uri( $self->uri . "${field}.asc" );
    }

    return $self;
}

sub format_fields {
    my ($fields) = @_;
    my @fields = split( /\s+/, $fields );
    return join( '', @fields );
}

sub first_op {
    my ($query) = @_;
    return index( $query, '?' ) > -1;
}

1;
