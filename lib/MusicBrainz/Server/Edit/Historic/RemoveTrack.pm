package MusicBrainz::Server::Edit::Historic::RemoveTrack;
use Moose;
use MooseX::Types::Structured qw( Dict );
use MooseX::Types::Moose qw( ArrayRef Int Str );
use MusicBrainz::Server::Constants qw( $EDIT_HISTORIC_REMOVE_TRACK );

extends 'MusicBrainz::Server::Edit::Historic';

sub edit_name     { 'Remove track'}
sub edit_type     { $EDIT_HISTORIC_REMOVE_TRACK }
sub historic_type { 11 }
sub edit_template { 'historic/remove_track' }

has '+data' => (
    isa => Dict[
        recording_id => Int,
        release_ids  => ArrayRef[Int],
        name         => Str
    ]
);

sub _release_ids
{
    my $self = shift;
    return @{ $self->data->{release_ids} };
}

sub related_entities
{
    my $self = shift;
    return {
        release   => $self->data->{release_ids},
        recording => [ $self->data->{recording_id} ],
    }
}

sub foreign_keys
{
    my $self = shift;
    return {
        Release   => [ map { $_ => ['ArtistCredit'] } $self->_release_ids ],
        Recording => [ $self->data->{recording_id} ]
    }
}

sub build_display_data
{
    my ($self, $loaded) = @_;
    return {
        name => $self->data->{name},
        recording => $loaded->{Recording}->{ $self->data->{recording_id} },
        releases => [
            map { $loaded->{Release}->{$_} } $self->_release_ids
        ]
    }
}

sub upgrade
{
    my $self = shift;

    $self->data({
        name         => $self->previous_value->{name},
        release_ids  => $self->album_release_ids(
            $self->previous_value->{album_id}),
        recording_id => $self->resolve_recording_id($self->row_id),
    });

    return $self;
}

sub deserialize_previous_value
{
    my ($self, $value) = @_;

    my ($name, $album_id, $is_nat, $position, $length) = split /\n/, $value;

    return {
        name     => $name,
        album_id => $album_id,
    }
}

no Moose;
__PACKAGE__->meta->make_immutable;
1;