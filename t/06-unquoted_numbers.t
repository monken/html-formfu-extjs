use Test::More tests => 1;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file("t/01-text.yml");
is( $form->render_items =~ /"labelWidth":10/, 1 );
