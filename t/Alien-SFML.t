# Before 'make install' is performed this script should be runnable with
# 'make test'. After 'make install' it should work as 'perl Alien-SFML.t'

#########################

# change 'tests => 1' to 'tests => last_test_to_print';

use strict;
use warnings;

use Test::More tests => 1;
BEGIN { use_ok('Alien::SFML') }

#########################

# Insert your test code below, the Test::More module is use()ed here so read
# its man page ( perldoc Test::More ) for help writing this test script.

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2013 by Jake Bott

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.

=cut

=head1 COPYRIGHT

Copyright (C) 2013 by Jake Bott

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.16.2 or,
at your option, any later version of Perl 5 you may have available.

=cut
