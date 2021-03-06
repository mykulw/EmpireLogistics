package EmpireLogistics::Schema::Result::EditHistoryField;



use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'EmpireLogistics::Schema::Result';

__PACKAGE__->table("edit_history_field");
__PACKAGE__->add_columns(
  "edit_history",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "field",
  { data_type => "text", is_nullable => 0 },
  "original_value",
  { data_type => "text", is_nullable => 1 },
  "new_value",
  { data_type => "text", is_nullable => 1 },
);
__PACKAGE__->set_primary_key("edit_history", "field");
__PACKAGE__->belongs_to(
  "edit_history",
  "EmpireLogistics::Schema::Result::EditHistory",
  { id => "edit_history" },
  { is_deferrable => 0, on_delete => "NO ACTION", on_update => "NO ACTION" },
);




__PACKAGE__->belongs_to(
    "object_type" =>
    "EmpireLogistics::Schema::Result::ObjectType",
    sub {
        my $args = shift;
        return (
            {
                "$args->{foreign_alias}.name " => { -ident => "$args->{self_resultsource}.name" },
            },
            $args->{self_rowobj} && {
                "$args->{foreign_alias}.name" => $args->{self_resultsource}->name,
            },
        );
    },
);

__PACKAGE__->has_many(
    edits => "EmpireLogistics::Schema::Result::EditHistory",
    sub {
        my $args = shift;
        return (
            {
                "$args->{foreign_alias}.object" => { -ident => "$args->{self_alias}.id" },
                "$args->{foreign_alias}.object_type" => $args->{self_rowobj}->object_type->id,
            },
            $args->{self_rowobj} && {
                "$args->{foreign_alias}.object" => $args->{self_rowobj}->id,
                "$args->{foreign_alias}.object_type" => $args->{self_rowobj}->object_type->id,
            },
        );
    },
    { order_by => { -desc => "create_time" } },
);

__PACKAGE__->meta->make_immutable;
1;
