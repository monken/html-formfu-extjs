use Test::More tests => 5;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file("t/02-select.yml");

$form->process;

my $rendered = $form->_render_items;

is($rendered->[0]->{emptyText}, undef);
is($rendered->[1]->{emptyText}, "test");
is($rendered->[1]->{something}, "else");

ok( $form->render_items, "dumping");

like( $form->render, qr/["",""]/);