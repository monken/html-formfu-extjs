use inc::Module::Install 0.75;

name 'HTML-FormFu-ExtJS';
perl_version '5.008001';
all_from 'lib/HTML/FormFu/ExtJS.pm';

# this is the lowest version of Exporter I can identify that exports import()
# it's bundled with perl 5.83
# version 5.567 that ships with perl 5.82 is no good
requires 'Exporter' => '5.57';

requires 'HTML::FormFu' => "3";
requires 'Scalar::Util' => 0;
requires 'Carp' => 0;
requires 'JavaScript::Dumper' => '0.004';
requires 'Tie::Hash::Indexed' => 0;
requires 'Data::Dumper' => 0;
tests 't/*.t';

no_index directory => 'examples';

&WriteAll;
