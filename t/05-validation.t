use Test::More tests => 6;

use HTML::FormFu::ExtJS;
use strict;
use warnings;

my $form = new HTML::FormFu::ExtJS;
$form->load_config_file("t/01-text.yml");

$form->process({test => 1});

isnt($form->submitted_and_valid, 1);
is($form->_validation_response->{success}, 0, "not valid");
is($form->validation_response =~ /{.*test2.*}/, 1, "JSON format");

$form->process({test2 => 1});

is($form->submitted_and_valid, 1);
is($form->_validation_response->{success}, 1, "valid");
is($form->validation_response =~ /{.*success.*}/, 1, "JSON format");
