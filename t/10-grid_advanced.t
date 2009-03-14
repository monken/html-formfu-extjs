use Test::More;

use HTML::FormFu::ExtJS::Grid;
use strict;
use warnings;

use lib qw(t/lib);

BEGIN {
	eval "use DBIx::Class; use DBD::SQLite; use HTML::FormFu::Model::DBIC;";
    plan $@
        ? ( skip_all => 'needs DBIx::Class, HTML::FormFu::Model::DBIC and DBD::SQLite for testing' )
      : ( tests => 3 );
}

use DBICTest;

my $schema = DBICTest->init_schema();


my $result = {
    'metaData' => {
        'fields' => [
            { 'name' => 'name', 'type' => 'string', mapping => 'name' },
            { 'name' => 'sexValue',  'type' => 'string', mapping => 'sex.value' },
            { 'name' => 'sex',  'type' => 'string', mapping => 'sex.label' },
            { 'name' => 'cds',  'type' => 'string', mapping => 'cds' }
        ],
        'totalProperty' => 'results',
        'root'          => 'rows'
    },
    'rows' => [
        { 'cds' => 3, 'name' => 'Caterwauler McCrae', sex => {label => 'male', value => 0 }},
        { 'cds' => 1, 'name' => 'Random Boy Band',    sex => {label => 'female', value => 1 } },
        { 'cds' => 1, 'name' => 'We Are Goth',        sex => {label => 'male', value => 0 } }
    ],
    'results' => 3
};

my $rs =
  $schema->resultset("Artist")->search( undef, { order_by => 'name asc' } );

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file('t/10-grid_advanced_1.yml');
my $data = $form->grid_data( [ $rs->all ] );
is_deeply( $data, $result );


$form = new HTML::FormFu::ExtJS;
$form->load_config_file('t/10-grid_advanced_2.yml');
$data = $form->grid_data( [ $rs->all ] );
is_deeply( $data, $result );

$form = new HTML::FormFu::ExtJS;
$form->load_config_file('t/10-grid_advanced_3.yml');
$data = $form->grid_data( [ $rs->all ] );
is_deeply( $data, $result );
