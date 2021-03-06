# Generated automatically with HTML::FormHandler::Generator::DBIC

# Using following commandline:

# form_generator.pl --rs_name=GeographyColumn --schema_name=EmpireLogistics::Schema --db_dsn=dbi:Pg:dbname=empireLogistics

{

    package EmpireLogistics::Form::Admin::GeographyColumn;

    use HTML::FormHandler::Moose;

    extends 'HTML::FormHandler::Model::DBIC';

    use namespace::autoclean;





    has '+item_class' => ( default => 'GeographyColumn' );



    has_field 'type' => ( type => 'TextArea', );

    has_field 'srid' => ( type => 'Integer', );

    has_field 'coord_dimension' => ( type => 'Integer', );

    has_field 'f_geography_column' => ( type => 'TextArea', );

    has_field 'f_table_name' => ( type => 'TextArea', );

    has_field 'f_table_schema' => ( type => 'TextArea', );

    has_field 'f_table_catalog' => ( type => 'TextArea', );

    has_field 'submit' => ( widget => 'Submit', );



    __PACKAGE__->meta->make_immutable;

    no HTML::FormHandler::Moose;

}




