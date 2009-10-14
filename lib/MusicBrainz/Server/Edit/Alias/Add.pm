package MusicBrainz::Server::Edit::Alias::Add;
use Moose;

use MooseX::Types::Moose qw( Int Str );
use MooseX::Types::Structured qw( Dict );

extends 'MusicBrainz::Server::Edit';

sub _alias_model { die 'Not implemented' }

has '+data' => (
    isa => Dict[
        alias => Str,
        entity_id => Int
    ]
);

has 'alias' => (
    is => 'rw'
);

has 'alias_id' => (
    isa => 'Int',
    is => 'rw',
);

sub insert
{
    my $self = shift;
    my %data = %{ $self->data };
    my $model = $self->_alias_model;
    # We have to remap this, as alias wants to see 'artist_id' for example, not 'entity_id'
    $data{ $model->type . '_id' } = delete $data{entity_id};
    $self->alias_id( $model->insert(\%data)->id );
}

sub reject
{
    my $self = shift;
    $self->_alias_model->delete($self->alias_id);
}

sub initialize
{
    my ($self, %opts) = @_;
    $opts{entity_id} = delete $opts{ $self->_alias_model->type . '_id' };
    $self->data(\%opts);
}

# alias_id is handled separately, as it should not be copied if the edit is cloned
override 'to_hash' => sub
{
    my $self = shift;
    my $hash = super(@_);
    $hash->{alias_id} = $self->alias_id;
    return $hash;
};

before 'restore' => sub
{
    my ($self, $hash) = @_;
    $self->alias_id(delete $hash->{alias_id});
};

__PACKAGE__->meta->make_immutable;
no Moose;

1;
