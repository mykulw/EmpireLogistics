package EmpireLogistics::Schema::Result::RawPort;



use Moose;
use MooseX::MarkAsMethods autoclean => 1;

extends 'EmpireLogistics::Schema::Result';

__PACKAGE__->table("raw_port");
__PACKAGE__->add_columns(
  "gid",
  {
    data_type         => "integer",
    is_auto_increment => 1,
    is_nullable       => 0,
    sequence          => "raw_port_gid_seq",
  },
  "index_no",
  { data_type => "double precision", is_nullable => 1 },
  "region_no",
  { data_type => "double precision", is_nullable => 1 },
  "port_name",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "country",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "latitude",
  { data_type => "double precision", is_nullable => 1 },
  "longitude",
  { data_type => "double precision", is_nullable => 1 },
  "lat_deg",
  { data_type => "double precision", is_nullable => 1 },
  "lat_min",
  { data_type => "double precision", is_nullable => 1 },
  "lat_hemi",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "long_deg",
  { data_type => "double precision", is_nullable => 1 },
  "long_min",
  { data_type => "double precision", is_nullable => 1 },
  "long_hemi",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "pub",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "chart",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "harborsize",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "harbortype",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "shelter",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "entry_tide",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "entryswell",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "entry_ice",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "entryother",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "overhd_lim",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "chan_depth",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "anch_depth",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cargodepth",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "oil_depth",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "tide_range",
  { data_type => "double precision", is_nullable => 1 },
  "max_vessel",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "holdground",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "turn_basin",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "portofentr",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "us_rep",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "etamessage",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "pilot_reqd",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "pilotavail",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "loc_assist",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "pilotadvsd",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "tugsalvage",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "tug_assist",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "pratique",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "sscc_cert",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "quar_other",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_phone",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_fax",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_radio",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_vhf",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_air",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "comm_rail",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cargowharf",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cargo_anch",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cargmdmoor",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "carbchmoor",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "caricemoor",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "med_facil",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "garbage",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "degauss",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "drtyballst",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cranefixed",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cranemobil",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "cranefloat",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "lift_100_",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "lift50_100",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "lift_25_49",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "lift_0_24",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "longshore",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "electrical",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "serv_steam",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "nav_equip",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "elecrepair",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "provisions",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "water",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "fuel_oil",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "diesel",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "decksupply",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "eng_supply",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "repaircode",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "drydock",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "railway",
  { data_type => "varchar", is_nullable => 1, size => 254 },
  "geom",
  { data_type => "geometry", is_nullable => 1, size => "12544,3519" },
);
__PACKAGE__->set_primary_key("gid");




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
