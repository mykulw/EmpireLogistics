package EmpireLogistics::Form::Admin::BulkImport;

use HTML::FormHandler::Moose;
use namespace::autoclean;
extends 'EmpireLogistics::Form::BaseDB';

has '+name'    => ( default => 'bulk-import' );
has '+enctype' => ( default => 'multipart/form-data' );

has_field 'object_type' => (
    type         => 'Select',
    label        => 'Object Type',
    required     => 1,
    empty_select => '-- Choose One --',
);

has_field 'sample_data' => (
    type => 'Display',
    label => 'Sample Data',
);

sub html_sample_data {
    my $self = shift;
    return qq|<a class="sample-data">Download Sample CSV data for the object type selected</a>|;
}

has_field 'csv' => (
    type     => 'Upload',
    max_size => 2048000,
    required => 1,
    label => "CSV File"
);

has_field 'submit' => (
    type          => 'Submit',
    widget        => 'ButtonTag',
    value         => 'Upload CSV',
    element_class => [ 'btn', 'btn-primary' ],
);

sub options_object_type {
    my $self = shift;
    return [
        { label => "Port",           value => "Port", },
        { label => "Rail Interline", value => "RailInterline", },
        { label => "Rail Line",      value => "RailLine", },
        { label => "Rail Node",      value => "RailNode", },
        { label => "Warehouse",      value => "Warehouse", },
    ];
}

sub validate_csv {

}

__PACKAGE__->meta->make_immutable;

1;
