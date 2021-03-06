package HTML::FormFu::ExtJS::Util;

use strict;
use warnings;

use HTML::FormFu::Util qw/require_class/;
use Exporter qw/ import /;
use Carp qw/ croak /;

our @EXPORT_OK = qw(
    _camel_case
    _css_case
    ext_class_of
);

sub _camel_case {
    return lcfirst(join('', map { ucfirst($_) } split(/\./, $_[0])));
}

sub _css_case {
    my $data_index = shift;
    $data_index =~ s/\./-/g;

    return $data_index;
}

sub ext_class_of {
    my $element = shift;
    my $classname;

    croak "cannot determine ext class for element '" . (ref $element) . "'"
        unless ($element->can( 'type' ));

    if ($element->type =~ /^(.*)::Element::(.*?)$/) {
        $classname = $1 . '::ExtJS::Element::' . $2;
    }
    else {
        $classname = "HTML::FormFu::ExtJS::Element::" . $element->type;
    }
    require_class( $classname );

    return $classname;
}

