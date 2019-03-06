#!/usr/bin/perl

# Get the latest images present in the container repository

#
# To list all:
# gcloud container images list --repository eu.gcr.io/$PROJECT_ID
#
# To retrieve tags:
# gcloud container images list-tags eu.gcr.io/$PROJECT_ID/<container image name>

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
    my @tags = `gcloud container images list-tags $imgUrl`;
    foreach my $t (@tags) {
        chomp($t);
        next if ($t =~ /DIGEST\s+TAGS\s+TIMESTAMP/);
        next if ($t !~ /(\w+)\s+(\w+)\s+([0-9T\-\:]+)/);
        my $unixTime = str2time($3);
        # print "Got tag: $t --> " . "$imgUrl - 1:$1  2:$2  3:$3  time:$unixTime\n";
        $versions{$imgUrl}{$unixTime} = $2; # url->time->tag
    }
}

# Sort the output
foreach my $imgUrl (sort keys %versions) {
    foreach my $unixTime (reverse sort keys %{$versions{$imgUrl}}) {
        print "  " . $BASEPATH . $imgUrl . "\t\t # Built: " . (scalar localtime($unixTime)) . "\n";
        print "    " . $BASETAG . "'" . $versions{$imgUrl}{$unixTime} . "'\n";
        last; # Only print the first one
        #print "$imgUrl -- $unixTime " . $versions{$imgUrl}{$unixTime} . "\n";
    }
}
