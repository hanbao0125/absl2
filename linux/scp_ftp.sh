#! /usr/bin/perl
use strict;

use POSIX qw(strftime);

# main line

print STDERR "backup[". strftime("%c",localtime()). "]\tstart\n";
my $backup_path="/home/jackie/backup";

my $filename ="jetcomm_dev_backup".strftime("%Y%m%d",localtime());
my $datafile = $backup_path.$filename;

print STDERR $datafile."\n";

`tar czf $datafile.tar.gz /home/jackie/sample  2> /dev/null`;

`/usr/bin/scp $datafile.tar.gz root\@210.41.110.249:/root`;

print STDERR "backup[". strftime("%c", localtime()). "]\tDone\n";
exit 0;
