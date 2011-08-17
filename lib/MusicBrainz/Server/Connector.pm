package MusicBrainz::Server::Connector;
use Moose;

use DBI;
use Sql;

sub _schema { shift->database->schema }

has 'dbh' => (
    is         => 'ro',
    lazy_build => 1,
);

has 'database' => (
    isa => 'MusicBrainz::Server::Database',
    is  => 'rw',
);

has 'sql' => (
    is => 'ro',
    lazy_build => 1
);

sub _build_dbh
{
    my ($self) = @_;

    my $dsn = 'dbi:Pg:dbname=' . $self->database->database;
    $dsn .= ';host=' . $self->database->host if $self->database->host;
    $dsn .= ';port=' . $self->database->port if $self->database->port;

    my $db = $self->database;
    my $conn = DBI->connect($dsn, $db->username, $db->password, {
        pg_enable_utf8    => 1,
        pg_server_prepare => 0, # XXX Still necessary?
        RaiseError        => 1,
        PrintError        => 0,
    });
}

sub _build_sql {
    my $self = shift;

    my $sql = Sql->new($self->dbh);

    $sql->auto_commit(1);
    $sql->do("SET TIME ZONE 'UTC'");
    $sql->auto_commit(1);
    $sql->do("SET CLIENT_ENCODING = 'UNICODE'");

    if (my $schema = $self->_schema) {
        $sql->auto_commit(1);
        $sql->do("SET search_path TO '$schema'");
    }

    return $sql;
}

no Moose;
__PACKAGE__->meta->make_immutable;

1;
