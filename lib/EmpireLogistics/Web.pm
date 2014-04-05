package EmpireLogistics::Web;

use Moose;
use CatalystX::RoleApplicator;
use EmpireLogistics::Config;
use namespace::autoclean;

use Catalyst::Runtime 5.90;

use Catalyst;

extends 'Catalyst';

our $VERSION = '0.01';

__PACKAGE__->config( %{$EmpireLogistics::Config::catalyst}, );
__PACKAGE__->apply_request_class_roles(
    qw/Catalyst::TraitFor::Request::XMLHttpRequest/);

__PACKAGE__->setup( @{$EmpireLogistics::Config::app_plugins} );

around authenticate => sub {
    my ($orig, $c) = (shift, shift);
    my ($args) = @_;

    my $remember    = delete $args->{remember};

    my $user = $c->$orig(@_);

    # Store a login cookie for the user
    # if they've clicked "Remember me"
    if ($user && $remember) {
        $c->response->cookies->{login} = {
            value   => $user->encrypted_login_cookie,
            expires => '+36M',
        }
    }

    return $user;
};

__PACKAGE__->meta->make_immutable;

1;
