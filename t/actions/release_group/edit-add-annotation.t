use strict;
use Test::More;

use Catalyst::Test 'MusicBrainz::Server';
use MusicBrainz::Server::Test qw( xml_ok );
use Test::WWW::Mechanize::Catalyst;

my ($res, $c) = ctx_request('/');
my $mech = Test::WWW::Mechanize::Catalyst->new(catalyst_app => 'MusicBrainz::Server');

$mech->get_ok('/login');
$mech->submit_form( with_fields => { username => 'new_editor', password => 'password' } );

$mech->get_ok('/release-group/234c079d-374e-4436-9448-da92dedef3ce/edit_annotation');
$mech->submit_form(
    with_fields => {
        'edit-annotation.text' => 'Test annotation 5. This is my annotation',
        'edit-annotation.changelog' => 'Changelog here',
    });

my $edit = MusicBrainz::Server::Test->get_latest_edit($c);
isa_ok($edit, 'MusicBrainz::Server::Edit::ReleaseGroup::AddAnnotation');
is_deeply($edit->data, {
    entity_id => 1,
    text => 'Test annotation 5. This is my annotation',
    changelog => 'Changelog here',
    editor_id => 1
});

$mech->get_ok('/edit/' . $edit->id, 'Fetch edit page');
$mech->content_contains('Changelog here', '..has changelog entry');
$mech->content_contains('Arrival', '..has release group name');
$mech->content_like(qr{release-group/234c079d-374e-4436-9448-da92dedef3ce/?"}, '..has a link to the release group');
$mech->content_contains('release-group/234c079d-374e-4436-9448-da92dedef3ce/annotation/' . $edit->annotation_id,
                        '..has a link to the annotation');

done_testing;