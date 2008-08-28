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
    eval "use HTML::FormFu::Model::DBIC";
    plan $@
        ? ( skip_all => 'needs DBIx::Class, HTML::FormFu::Model::DBIC and DBD::SQLite for testing' )
        : ( tests => 1 );
}

$Data::Dumper::Indent = 0;

my $result = {'metaData' => {'fields' => [{'name' => 'name','type' => 'string'},{'name' => 'producerid','type' => 'string'},{'name' => 'cds','type' => 'string'}],'totalProperty' => 'results','root' => 'rows'},'rows' => [{'cds' => 1,'name' => 'Matt S Trout','producerid' => '1'},{'cds' => 2,'name' => 'Bob The Builder','producerid' => '2'},{'cds' => 1,'name' => 'Fred The Phenotype','producerid' => '3'}],'results' => 3};
my $rs = $schema->resultset("Producer");

my $form = new HTML::FormFu::ExtJS::Grid;
$form->load_config_file('t/11-grid_groups.yml');
my $cbg = $form->get_element({type => "Checkboxgroup"});
my @cds = $schema->resultset("CD")->all;
$cbg->options([map { [$_->cdid, $_->title] } @cds]);
is_deeply($form->grid_data($rs), $result);

$form->model("DBIC")->default_values($rs->find(2));

print $form->render;