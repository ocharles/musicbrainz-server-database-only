package MusicBrainz::Server::DatabaseConnectionFactory;

use strict;
use warnings;

use MusicBrainz::Server::Database;

my $connector_class = 'MusicBrainz::Server::Connector';
our %databases;
our %connections;

sub register_databases
{
    my ($class, %databases) = @_;
    while (my ($key, $args) = each %databases) {
        next unless $args;
        $class->register_database($key, MusicBrainz::Server::Database->new($args));
    }
}

sub register_database
{
    my ($class, $key, $database) = @_;
    return unless $database;
    return if $databases{$key};
    $databases{$key} = $database;
}

sub get_connection
{
    my ($class, $key, %opts) = @_;
    Class::MOP::load_class($connector_class);

    if ($opts{fresh}) {
        my $database = $databases{ $key };
        return $connector_class->new( database => $database );
    }
    else {
        $connections{ $key } ||= do {


            my $database = $databases{ $key };
            $connector_class->new( database => $database );
        };

        return $connections{ $key };
    }
}

sub connector_class
{
    my $self = shift;
    if (@_) {
        $connector_class = shift;
    }

    return $connector_class;
}

sub get
{
    my ($class, $name) = @_;
    return $databases{$name};
}

1;
