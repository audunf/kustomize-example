#!/usr/bin/perl

use strict;

# Change <your unique repos> to something which matches your container repository to limit the output

my %versions;
my @images = `docker images | grep '<your unique repos>'`;

# assumes they're printed in order from newest to oldest

my $BASEPATH="- name: ";
my $BASETAG="newTag: ";

my $name;
my $tag;

foreach my $l (@images) {
    $l =~ /([^ ]+)\s+([^ ]+)\s+([^ ]+)\s+/;
    $name = $1;
    $tag = $2;
    if (!exists($versions{$name})) {
        $versions{$name} = $tag;
    } else {
        # print "Duplicate: $name - $tag\n"
    }
}

# Sort the output
foreach $name (sort keys %versions) {
    print "  " . $BASEPATH . $name . "\n";
    print "    " . $BASETAG . "'" . $versions{$name} . "'\n";
}
