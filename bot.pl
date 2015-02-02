#!/usr/bin/perl

### Config
my $address = '';
my $port = 6667;
my $nick = '';
my $ident = '';
my $realname = '';
my $ns_password = ''; # NickServ password
my $channel = ''; 

my $wiki_address = '';
my $wiki_port = 0;

### Code
use AnyEvent;
use AnyEvent::IRC::Client;
use AnyEvent::Handle::UDP;
use Data::Dumper;

use strict;
use warnings;
use v5.10;

my $wait = AnyEvent->condvar;

my $udp_server = AnyEvent::Handle::UDP->new(
  bind => [$wiki_address, $wiki_port],
  on_recv => \&udp_handler
);

my $irc = AnyEvent::IRC::Client->new;
$irc->reg_cb(registered => sub {
  say "Connected.";
  $irc->send_msg(NS => "ID $ns_password");
  $irc->send_msg(JOIN => $channel);
});
$irc->reg_cb(disconnect => sub {
  say "Disconnected: \"$_[1]\".";
  connect_to_irc();
});

connect_to_irc();

$wait->recv;

sub connect_to_irc {
  $irc->connect($address, $port, {
    nick => $nick,
    realname => $realname,
  });
}

sub udp_handler {
  my $msg = shift;
  my $ignore;
  chomp $msg;
  
  # Related to LinuxWiki.pl
  #$msg =~ s/Specjalna:/S:/g;
  #$msg =~ s/index\.php\?oldid=(\d*)&rcid=(\d*)/d\/$1\/$2/g;
  #$msg =~ s/index\.php\?diff=(\d*)&oldid=\d*&rcid=(\d*)/d\/$1\/$2/g;
  #$ignore = 1 if ($msg =~ /S:Log\/patrol/);
  $irc->send_msg(PRIVMSG => '#linuxwiki.pl', $msg);  #unless ($ignore);
}
