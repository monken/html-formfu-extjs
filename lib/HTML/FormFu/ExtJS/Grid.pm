package HTML::FormFu::ExtJS::Grid;

use base "HTML::FormFu::ExtJS";

use JavaScript::Dumper;
use Hash::Merge::Simple qw(merge);
use Scalar::Util 'blessed';

use utf8;

use strict;
use warnings;

use HTML::FormFu::Util qw/require_class/;

use Class::C3;

use Carp;

sub new {
	carp "HTML::FormFu::ExtJS::Grid is deprecated, please use HTML::FormFu::ExtJS instead";
	return next::method(@_);
}


1;
