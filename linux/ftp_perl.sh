#!/usr/bin/perl
use strict;

use POSIX qw(strftime);

# main line
`rm -rf /tmp/backup/*.gz` if -e "/tmp/backup/*.gz";

print STDERR "backup[". strftime("%c",localtime()). "]\tstart\n";
my $backup_path="/tmp/backup/";
my $www_filename="www_backup-". strftime("%Y%m%d",localtime());
my $cvs_filename="cvs_backup-". strftime("%Y%m%d",localtime());
my $wwwdatafile = $backup_path."www_backup-". strftime("%Y%m%d",localtime());
my $cvsdatafile = $backup_path."cvs_backup-". strftime("%Y%m%d",localtime());
#print $datafile."\n";
`tar czvf $wwwdatafile.tar.gz /var/www`;
`tar czvf $cvsdatafile.tar.gz /home/cvsroot`;
#`gzip $datafile.tar`;

open FTP, "| /usr/bin/ftp -i -n";
print FTP <<EOL
open 210.41.110.250
user jackie cadcam
binary
lcd $backup_path
put $www_filename.tar.gz
!unlink $www_filename.tar.gz
put $cvs_filename.tar.gz
!unlink $cvs_filename.tar.gz
quit
EOL
;

#sleep(2000);#wait for ftp close,otherwise ftp will report error
#`rm -rf $wwwdatafile.tar.gz` if -e "$wwwdatafile.tar.gz";
#`rm -rf $cvsdatafile.tar.gz` if -e "$cvsdatafile.tar.gz";
#`rm $datafile.tar.gz` if -e "$datafile.tar.gz";

print STDERR "backup[". strftime("%c", localtime()). "]\tDone\n";
exit 0;

