package EmpireLogistics::Form::BaseDB;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'HTML::FormHandler::Model::DBIC';

has '+field_name_space' => ( default => 'EmpireLogistics::Form::Field');
has '+widget_name_space' => ( default => 'EmpireLogistic::Form::Widget');
has '+widget_wrapper' => ( default => 'Bootstrap3' );
has '+is_html5' => (default => 1);
has '+http_method' => (default => 'post');

has 'schema' => (
    is => 'rw',
    isa => 'DBIx::Class::Schema',
    required => 1,
);

sub build_form_element_attr { { 'accept-charset' => 'utf-8' } }
sub build_form_element_class { ['form-vertical'] }

around 'update_model', sub {
    my ($orig, $self, @args) = @_;

    # Transform delete_time into datetime, if needed
    if ($self->values->{delete_time} && !$self->item->delete_time) {
        $self->values->{delete_time} = DateTime->now; # set
    } elsif (!$self->values->{delete_time} && $self->item->delete_time) {
        $self->values->{delete_time} = undef; # unset
    } else {
        delete $self->values->{delete_time}; # don't touch
    }

    my $return = $self->$orig(@args);

    return $return;
};

__PACKAGE__->meta->make_immutable;

1;
