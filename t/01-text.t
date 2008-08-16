use Test::More tests => 3;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file("t/01-text.yml");
is_deeply( $form->_render_items,
	[ { hideLabel => \1, value => undef, "fieldLabel" => undef, "name" => "test", id => "test_id", "xtype" => "textfield" },
	{ hideLabel => \0, value => undef,"fieldLabel" => "Test", "name" => "test2", id => undef, "xtype" => "textfield" } ] );
is(scalar @{$form->_render_items}, 2);

ok($form->render_items);
