#!/usr/bin/perl
use strict;

use POSIX qw(strftime);

# main line

print STDERR "backup[". strftime("%c",localtime()). "]\tstart\n";
my $backup_path = "/home/source/";
my $backup_filename = "backup_src". strftime("%Y%m%d",localtime());
my $backup_file = $backup_path."backup_src". strftime("%Y%m%d",localtime());
`tar czvf $backup_filename.tar.gz /home/src/`;

open FTP, "| /usr/bin/ftp -i -n";
print FTP <<EOL
open 192.168.1.99
user source 123456
binary
lcd $backup_path
put $backup_filename.tar.gz
!unlink $backup_filename.tar.gz
quit
EOL
;
print STDERR "backup[". strftime("%c", localtime()). "]\tDone\n";
exit 0;

