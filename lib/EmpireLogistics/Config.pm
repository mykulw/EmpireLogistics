package EmpireLogistics::Config;

use strict;
use warnings;
use Clone qw/clone/;
use Sys::Hostname       ();
use Sys::Hostname::Long ();
use List::AllUtils qw/first/;

our %PARAMETERS = ();
our %NICKNAMES  = ();

$PARAMETERS{default} = {
    srcroot  => "/var/local/EmpireLogistics/current/",
    hostname => 'localhost',
    tiles_url => '50.116.5.25/tiles',
    database => {
        db_name => 'empirelogistics',
        db_user => 'el',
        db_host => 'localhost',
        db_port => 5432,
        db_opts => {
            RaiseError    => 1,
            on_connect_do => ['set timezone = "America/Los_Angeles"'],
            pg_enable_utf8 => -1,
            quote_names => 1,
        },
    },
    app_plugins => [qw/
        ConfigLoader
        Authentication
        Authorization::Roles
        Authorization::ACL
        RedirectAndDetach
        I18N
        Session
        Session::Store::DBIC
        Session::State::Cookie
        Session::PerEmpireLogisticsUser
    /],
    catalyst => {
        name => 'EmpireLogistics::Web',
        disable_component_resolution_regex_fallback => 1,
        enable_catalyst_header => 1,
        encoding => 'utf-8',
        default_view => "TT",
        "View::JSON" => {
            allow_callback => 1,
        },
        "View::TT" => {
            TEMPLATE_EXTENSION => '.tt',
            CATALYST_VAR => 'c',
            TIMER        => 0,
            ENCODING     => 'utf-8',
            INCLUDE_PATH => [
                get_current_srcroot() . "/root/templates",
            ],
            WRAPPER            => 'smart_wrapper.tt',
            expose_methods => [qw/jsfiles stylesheets/],
        },
        "Plugin::Static::Simple" => {
            ignore_extensions => [qw/tt/],
        },
        "Plugin::Authentication" => {
            default_realm => "users",
            users => {
                credential => {
                    class => "Password",
                    password_field => "password",
                    password_type => "self_check",
                },
                store => {
                    class => "DBIx::Class",
                    user_model => "DB::User",
                    role_relation => "roles",
                    role_field => "name",
                },
            },
            no_password => {
                credential => {
                    class => 'Password',
                    password_type => 'none',
                },
                store => {
                    class => "DBIx::Class",
                    user_model => "DB::User",
                    role_relation => "roles",
                    role_field => "name",
                },
            },
        },
        "Plugin::Session" => {
            dbic_class     => "DB::Session",
            cookie_expires => 0, # Session only cookie
            expires        => 3600,
            flash_to_stash => 1,
        },
        # Catalyst::Plugin::Session::PerUser
        user_session => {
            migrate => 1,
        },
    },
};

$PARAMETERS{"localhost"} = {
    %{ clone $PARAMETERS{'default'} },
};

$PARAMETERS{development} = {
    %{ clone $PARAMETERS{default} },
    srcroot  => get_current_srcroot(),
    hostname => "akbuntu",
    tiles_url => 'localhost/tiles',
};
push @{$PARAMETERS{development}{app_plugins}}, ("-Debug", "Static::Simple");

$PARAMETERS{akbuntu} = {
    %{ clone $PARAMETERS{development} },
    srcroot  => "/home/amiri/EmpireLogistics",
    hostname => "akbuntu",
    tiles_url => 'localhost:9999',
};

$PARAMETERS{"vagrant-ubuntu-saucy-"} = {
    %{ clone $PARAMETERS{'development'} },
    hostname => "vagrant-ubuntu-saucy-64",
};

sub mk_package_accessors {
    my ( $self, @fields ) = @_;
    no strict 'refs';
    no warnings 'redefine';
    for my $field (@fields) {
        *{"${self}::$field"} = $self->make_package_accessor($field);
    }
}

sub make_package_accessor {
    my ( $self, $field ) = @_;
    my $class = ref $self || $self;
    my $varname = "$class\:\:$field";
    return sub {
        my $class = shift;
        no strict 'refs';
        return @_ ? ( ${$varname} = $_[0] ) : ${$varname};
    }
}

__PACKAGE__->mk_package_accessors( keys %{ $PARAMETERS{"default"} } );
__PACKAGE__->mk_package_accessors('initialized');
__PACKAGE__->mk_package_accessors('all_parameters');
__PACKAGE__->mk_package_accessors('installation');

sub import {
    my ($class, %options) = @_;
    $class->init(exists $options{installation} ? $options{installation} : ())
        unless $class->initialized;
}

sub init {
    my ( $class, $installation ) = @_;

   # if we aren't passed in the canonical installation name, go figure it out.
    $installation //= $class->get_running_installation();

    my $parameters = $class->get_parameters($installation);
    while ( my ( $key, $value ) = each %$parameters ) {
        __PACKAGE__->$key($value);
    }

    __PACKAGE__->all_parameters($parameters);

    $ENV{CATALYST_HOME} = $parameters->{srcroot};

    $class->initialized(1);
}

sub get_running_installation {
    my $class = shift;

    my $hostname = get_system_hostname();

    return "$hostname";
}

sub get_system_hostname {
    my $hostname = Sys::Hostname::Long::hostname_long();
    return $hostname;
}

sub get_current_srcroot {

    # this was causing undefined warnings when run through stdin
    my $inc = $INC{"EmpireLogistics/Config.pm"}
        // 'lib/EmpireLogistics/Config.pm';

    require File::Spec;

    if ( $inc !~ m|^/| ) {
        $inc = File::Spec->rel2abs($inc);
    }

    # oh dear. just use Path::Tiny to canonicalize.
    1 while $inc =~ s{
      /[^/]+/\.\./
    |
      /\./
    |
      //+
    |
      ^/?\.+/
    |
      /\.+$
  }{/}x;

    $inc =~ s|/lib/EmpireLogistics/Config\.pm$||;

    # Untaint
    die "Can't untaint srcroot $inc" unless $inc =~ m|^([-+@\w./]+)$|;
    $inc = $1;

    return $inc;
}

sub get_parameters {
    my $class = shift;
    my ($name) = @_;

    die __PACKAGE__ . ': no installation passed to get_parameters'
        unless $name;

    my $installation = canonical_installation_name($name);
    die "Can't find configuration for installation $installation"
        unless $PARAMETERS{$installation};

    my $parameters = clone( $PARAMETERS{$installation} );

    # Get the hostname and srcroot for this installation.
    # If we were passed a full installation name, just grab them directly
    # If we were given a nickname, get them from the canonical
    # installation, and append any instance-id suffix to the hostname.
    # if we still can't figure it out, go calculate the values directly
    # (TODO: this really should be the ONLY thing we do, rather than deriving
    # from the configs - but I can't be sure that I won't break something by
    # removing this code -- what if a host's config is taken from another's,
    # and we are relying on the incorrect hostname here?)
    my ( $hostname, $srcroot );
    if ( $name =~ /^(.+?):(.+)$/ ) {
        ( $hostname, $srcroot ) = ( $1, $2 );
    } else {
        my $nickname = $name;
        if ( $installation =~ /^(.+?):(.+)$/ ) {
            ( $hostname, $srcroot ) = ( $1, $2 );
        } else {

            # note that this isn't the mechanism used elsewhere in this file
            # for getting the hostname -- that way does not work on OSX, so we
            # use the core mechanism here.
            $hostname = Sys::Hostname::hostname;
            $srcroot  = get_current_srcroot();
        }
    }

    $parameters->{srcroot}  = $srcroot;
    $parameters->{hostname} = $hostname;

    # Make sure all parameters exist in default.
    foreach my $parameter ( keys %$parameters ) {
        die "unknown parameter $parameter (not defined in default hash)"
            if not exists $PARAMETERS{default}{$parameter};
    }

    # Make sure all parameters from default exist.
    foreach my $parameter ( keys %{ $PARAMETERS{default} } ) {
        die "$parameter not set"
            if not exists $parameters->{$parameter};
    }

    $parameters->{installation} = $installation;

    return $parameters;
}

sub canonical_installation_name {
    my $installation = shift;

    # convert 'foobar-i-AA0011BB', 'foobar-00', 'foobar-01.campusexplorer.com'
    # into 'foobar-'
    $installation =~ s/^(.+?)-(\d+|i-[0-9a-f]{8})\b(.*)/$1-$3/;

    die __PACKAGE__
        . ': no installation passed to canonical_installation_name'
        unless $installation;

    return $installation if $PARAMETERS{$installation};

    my $nickname = $installation;
    if ( not %NICKNAMES ) {
        foreach my $key ( keys %PARAMETERS ) {
            my $nickname = $PARAMETERS{$key}{nickname};
            next unless $nickname;
            if ( $NICKNAMES{$nickname} ) {

                # We need to unset %NICKNAMES if this happens in case
                # we trap the error and try to keep processing.  If
                # the script tries something clever to fix the error
                # we need to re-check nicknames, which we'll only do
                # if %NICKNAMES is unset when we return.
                %NICKNAMES = ();
                die "Two installations found with nickname of $nickname!";
            }
            $NICKNAMES{$nickname} = $key;
        }
    }

    return $NICKNAMES{$nickname} if $NICKNAMES{$nickname};

    die "Can't find installation '$nickname'";
}

sub dsn {
    my $class = shift;
    my $db_name = $class->database->{db_name};
    my $db_host = $class->database->{db_host};
    my $db_port = $class->database->{db_port};
    my $dsn = "dbi:Pg:dbname=$db_name;host=$db_host;port=$db_port";
    return $dsn;
}

sub connect_info {
    my $class = shift;
    my $dsn = $class->dsn();
    my $user = $class->database->{db_user};
    my $opts = $class->database->{db_opts};
    my $connect_info = {
        dsn => $dsn,
        user => $user,
        password => undef,
        %$opts,
    };
    return $connect_info;
}

1;
