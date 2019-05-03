#!/usr/bin/perl

# Pulls containers and tags, prints latest in a format suitable for
# test/kustomize.yaml or prod/kustomize.yaml

use strict;
use Date::Parse;

my $PROJECT_ID=$ENV{'PROJECT_ID'};

my $BASEPATH="- name: ";
my $BASETAG="newTag: ";

my %versions;
my @images = `gcloud container images list --repository eu.gcr.io/$PROJECT_ID`;

foreach my $imgUrl (@images) {
    chomp($imgUrl);
    next if ($imgUrl =~ /^NAME/);
    my @tags = `gcloud container images list-tags --sort-by="~timestamp" --limit=2 $imgUrl`;
    foreach my $t (@tags) {
        chomp($t);
        next if ($t =~ /DIGEST\s+TAGS\s+TIMESTAMP/);
        next if ($t !~ /(\w+)\s+(\S+)\s+([0-9T\-\:]+)/);
        my $unixTime = str2time($3);
        # print "Got tag: $t --> " . "$imgUrl - 1:$1  2:$2  3:$3  time:$unixTime\n";
        $versions{$imgUrl}{$unixTime} = $2; # url->time->tag(s)
    }
}

# Sort the output
foreach my $imgUrl (sort keys %versions) {
    foreach my $unixTime (reverse sort keys %{$versions{$imgUrl}}) {
        next if ($imgUrl =~ /git-sync|some-container-we-dont-want-to-include-in-the-output/);

        print $BASEPATH . $imgUrl . "\t\t # Built: " . (scalar localtime($unixTime)) . "\n";

        my $tags = $versions{$imgUrl}{$unixTime};
        my @taglst = split(',', $tags);
        foreach my $tag (@taglst) {
            print "  " . $BASETAG . "'" . $tag . "'";
            print "\t# Container has MULTIPLE tags - remove all except ONE!" if (scalar @taglst > 1);
            print "\n";
        }
        last; # Only print the first of the containers found
        #print "$imgUrl -- $unixTime " . $versions{$imgUrl}{$unixTime} . "\n";
    }
}
