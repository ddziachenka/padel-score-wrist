#!/usr/bin/env perl
# Cooperative, per-user leases. A single flock makes multi-resource acquisition
# and stale-owner recovery atomic. Never expire a live owner by elapsed time.
use strict;
use warnings;
use Fcntl qw(:DEFAULT :flock O_NOFOLLOW);
use JSON::PP;
use File::Temp qw(tempfile);
umask 0077;
my ($action, @args) = @ARGV;
sub refuse { print STDERR "lease: $_[1]\n"; exit $_[0]; }
my $root = '/private/tmp/iosai-leases-' . $<;
mkdir $root, 0700 unless -e $root;
my @st = lstat $root;
@st && -d _ && !-l _ && $st[4] == $< && ($st[2] & 0777) == 0700
    or refuse(73, "unsafe lease directory: $root");
sysopen(my $mutex, "$root/mutex", O_RDWR | O_CREAT | O_NOFOLLOW, 0600)
    or refuse(73, "cannot open mutex: $!");
flock($mutex, LOCK_EX) or refuse(73, "cannot lock: $!");
my $db = {};
if (-e "$root/leases.json" || -l "$root/leases.json") {
    sysopen(my $in, "$root/leases.json", O_RDONLY | O_NOFOLLOW)
        or refuse(73, "cannot read leases: $!");
    local $/;
    $db = eval { decode_json(<$in>) };
    ref($db) eq 'HASH' or refuse(65, 'invalid lease registry; preserve it for diagnosis');
}
sub identity {
    my ($pid) = @_;
    defined($pid) && $pid =~ /^[1-9][0-9]*$/ or return '';
    local $ENV{LC_ALL} = 'C';
    local $ENV{TZ} = 'UTC';
    open(my $ps, '-|', 'ps', '-p', $pid, '-o', 'lstart=') or refuse(69, 'ps unavailable');
    local $/;
    my $start = <$ps> // '';
    close $ps;
    $start =~ s/^\s+|\s+$//g;
    return $start;
}
# If ps failed but the PID is alive, fail closed rather than steal its lease.
for my $key (keys %$db) {
    my $lease = $db->{$key};
    my $start = identity($lease->{pid});
    if (!$start && kill(0, $lease->{pid})) { refuse(69, 'cannot inspect live lease owner'); }
    delete $db->{$key} if !$start || $start ne $lease->{start};
}
my $result;
if (($action // '') eq 'acquire') {
    my ($pid, $owner, @resources) = @args;
    @resources && defined($owner) or refuse(64, 'acquire requires PID, owner and resources');
    my $start = identity($pid);
    $start or refuse(64, 'lease owner must be a live process');
    for my $key (@resources) {
        if ($db->{$key}) {
            print STDERR encode_json({busy => $key, lease => $db->{$key}}), "\n";
            exit 75;
        }
    }
    open(my $random, '<', '/dev/urandom') or refuse(69, 'random source unavailable');
    read($random, my $bytes, 24) == 24 or refuse(69, 'random source incomplete');
    my $token = unpack('H*', $bytes);
    $result = {token => $token, pid => 0+$pid, start => $start, owner => $owner, resources => \@resources};
    $db->{$_} = $result for @resources;
} elsif (($action // '') eq 'release') {
    @args == 1 && $args[0] =~ /^[a-f0-9]{48}$/ or refuse(64, 'release requires the acquisition token');
    delete $db->{$_} for grep { $db->{$_}{token} eq $args[0] } keys %$db;
    $result = {released => JSON::PP::true};
} elsif (($action // '') eq 'status') {
    $result = $db;
} else { refuse(64, 'expected acquire, release or status'); }
my ($out, $tmp) = tempfile('leases-XXXXXXXX', DIR => $root, UNLINK => 1);
print $out encode_json($db) or refuse(73, 'cannot write leases');
close $out or refuse(73, 'cannot flush leases');
rename $tmp, "$root/leases.json" or refuse(73, 'cannot replace leases');
print encode_json($result), "\n";
