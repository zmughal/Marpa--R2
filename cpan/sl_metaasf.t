#!perl
# Copyright 2013 Jeffrey Kegler
# This file is part of Marpa::R2.  Marpa::R2 is free software: you can
# redistribute it and/or modify it under the terms of the GNU Lesser
# General Public License as published by the Free Software Foundation,
# either version 3 of the License, or (at your option) any later version.
#
# Marpa::R2 is distributed in the hope that it will be useful,
# but WITHOUT ANY WARRANTY; without even the implied warranty of
# MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the GNU
# Lesser General Public License for more details.
#
# You should have received a copy of the GNU Lesser
# General Public License along with Marpa::R2.  If not, see
# http://www.gnu.org/licenses/.

# Test of Abstract Syntax Forest

use 5.010;
use strict;
use warnings;
no warnings qw(recursion);

use Test::More tests => 2;
use English qw( -no_match_vars );
use lib 'inc';
use Marpa::R2::Test;
use Marpa::R2;
use Data::Dumper;

open my $metag_fh, q{<}, 'lib/Marpa/R2/meta/metag.bnf' or die;
my $metag_source  = do { local $/ = undef; <$metag_fh>; };
close $metag_fh;
my $asf_grammar = Marpa::R2::Scanless::G->new( { 
bless_package => 'My_ASF',
source => \$metag_source });

sub my_parser {
    my ( $grammar, $string ) = @_;
    my $recce = Marpa::R2::Scanless::R->new( { grammar => $grammar } );
    my ( $parse_value, $parse_status );

    if ( not defined eval { $recce->read( \$string ); 1 } ) {
        my $abbreviated_error = $EVAL_ERROR;
        chomp $abbreviated_error;
        $abbreviated_error =~ s/\n.*//xms;
        $abbreviated_error =~ s/^Error \s+ in \s+ string_read: \s+ //xms;
        return 'No parse', $abbreviated_error;
    } ## end if ( not defined eval { $recce->read( \$string ); 1 ...})
    my $value_ref = $recce->asf( { choice => 'choix', force => 'My_ASF' } );
    if ( not defined $value_ref ) {
        return 'No parse', 'Input read to end but no parse';
    }
    return [ return ${$value_ref}, 'Parse OK' ];
} ## end sub my_parser

my @tests_data = (
    [   $asf_grammar,
    $metag_source,
    '',
        'Parse OK',
        'ASF MetaG test'
    ],
);

TEST:
for my $test_data (@tests_data) {
    my ( $grammar, $test_string, $expected_value, $expected_result,
        $test_name )
        = @{$test_data};
    my ( $actual_value, $actual_result ) =
        my_parser( $grammar, $test_string );
    Test::More::is(
        Data::Dumper::Dumper( \$actual_value ),
        Data::Dumper::Dumper( \$expected_value ),
        qq{Value of $test_name}
    );
    Test::More::is( $actual_result, $expected_result,
        qq{Result of $test_name} );
} ## end TEST: for my $test_data (@tests_data)

# vim: expandtab shiftwidth=4:
