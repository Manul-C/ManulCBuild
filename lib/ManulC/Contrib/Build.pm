#

use v5.24;

package ManulC::Contrib::Build;
use base qw<Module::Build>;
use File::Spec;
use Data::Dumper;
use Hash::Merge;

our $VERSION = 'v0.001.001';

sub new {
    my $class   = shift;
    my %profile = @_;

    # It must not be ~/tmp/www
    my $instBase = File::Spec->catdir( $ENV{HOME}, qw<Sites ManulC> );

    my %defaults = (
        install_base => $instBase,
    );

    my $merger = Hash::Merge->new;
    $merger->set_behavior( 'RIGHT_PRECEDENT' );

    my $mergedProfile = $merger->merge( \%defaults, \%profile );

    my $this = $class->SUPER::new( %$mergedProfile );

    my $base_dir = File::Spec->canonpath( $this->base_dir );

    foreach my $buildElem ( qw<static store> ) {
        my $elemDir = File::Spec->catdir( $base_dir, $buildElem );
        if ( -d $elemDir ) {
            $this->install_base_relpaths( $buildElem => $buildElem );
            $this->add_build_element( $buildElem );
        }
    }

    return $this;
}

sub _copy_dir {
    my $this    = shift;
    my $rootDir = shift;

    foreach my $sfile ( @{ $this->rscan_dir( $rootDir, sub { -f $_ } ) } ) {
        say STDERR "Copying ", $sfile;
        $this->copy_if_modified(
            from   => $sfile,
            to_dir => $this->blib,
        );
    }

}

sub process_static_files {
    my $this = shift;
    $this->_copy_dir( 'static' );
}

sub process_store_files {
    my $this = shift;
    $this->_copy_dir( 'store' );
}

1;

## Copyright 2018 by Vadim Belman
##
## Licensed under the Apache License, Version 2.0 (the "License");
## you may not use this file except in compliance with the License.
## You may obtain a copy of the License at
##
##  http://www.apache.org/licenses/LICENSE-2.0
##
## Unless required by applicable law or agreed to in writing, software
## distributed under the License is distributed on an "AS IS" BASIS,
## WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
## See the License for the specific language governing permissions and
## limitations under the License.
