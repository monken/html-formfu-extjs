use Test::More;

use HTML::FormFu::ExtJS::Grid;
use strict;
use warnings;

use lib qw(t/lib);

use DBICTest;
use Data::Dumper;

my $schema = DBICTest->init_schema();

BEGIN {
	eval "use DBIx::Class";
    eval "use DBD::SQLite";
    plan $@
        ? ( skip_all => 'needs DBIx::Class and DBD::SQLite for testing' )
        : ( tests => 3 );
}

$Data::Dumper::Indent = 0;

my $result = {'metaData' => {'fields' => [{'name' => 'name','type' => 'string'},{'name' => 'sex','type' => 'string'},{'name' => 'cds','type' => 'string'}],'totalProperty' => 'results','root' => 'rows'},'rows' => [{'cds' => 3,'name' => 'Caterwauler McCrae','sex' => 'male'},{'cds' => 1,'name' => 'Random Boy Band','sex' => 'female'},{'cds' => 1,'name' => 'We Are Goth','sex' => 'male'}],'results' => 3};

my $rs = $schema->resultset("Artist")->search(undef, {order_by => 'name asc'});

my $form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file('t/10-grid_advanced_1.yml');
my $data = $form->grid_data($rs);
is_deeply($data, $result);

$form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file('t/10-grid_advanced_2.yml');
my $data = $form->grid_data($rs);
is_deeply($data, $result);

$form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file('t/10-grid_advanced_3.yml');
my $data = $form->grid_data($rs);
is_deeply($data, $result);