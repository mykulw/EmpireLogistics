package EmpireLogistics::Schema::Result::RailLineWorkStoppage;



use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'EmpireLogistics::Schema::Result';

__PACKAGE__->table("rail_line_work_stoppage");
__PACKAGE__->add_columns(
  "id",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "rail_line_work_stoppage_id_seq",
  },
  "create_time",
  {
    data_type     => "timestamp with time zone",
    default_value => \'now()',
    is_nullable   => 0,
  },
  "update_time",
  {
    data_type     => "timestamp with time zone",
    default_value => \'now()',
    is_nullable   => 0,
  },
  "delete_time",
  { data_type => "timestamp with time zone", is_nullable => 1 },
  "rail_line",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
  "work_stoppage",
  { data_type => "integer", is_foreign_key => 1, is_nullable => 0 },
);
__PACKAGE__->set_primary_key("id");
__PACKAGE__->add_unique_constraint(
  "rail_line_work_stoppage_rail_line_work_stoppage_key",
  ["rail_line", "work_stoppage"],
);
__PACKAGE__->belongs_to(
  "rail_line",
  "EmpireLogistics::Schema::Result::RailLine",
  { id => "rail_line" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
);
__PACKAGE__->belongs_to(
  "work_stoppage",
  "EmpireLogistics::Schema::Result::WorkStoppage",
  { id => "work_stoppage" },
  { is_deferrable => 0, on_delete => "CASCADE", on_update => "NO ACTION" },
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
