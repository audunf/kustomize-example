#!/usr/bin/perl

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
    my @tags = `gcloud container images list-tags --limit=2 $imgUrl`;
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
    my @taglst;
    my $tags;
    my $lastTag;
    
    foreach my $unixTime (reverse sort keys %{$versions{$imgUrl}}) {
	    $tags = $versions{$imgUrl}{$unixTime};
	    @taglst = split(',', $tags);
	    $lastTag = pop(@taglst); # get the last tag in the list of tags
	
        print "  " . $BASEPATH . $imgUrl . "\t\t # Built: " . (scalar localtime($unixTime)) . "\n";
        print "    " . $BASETAG . "'" . $lastTag . "'\n";
        last; # Only print the first one of the containers found
        #print "$imgUrl -- $unixTime " . $versions{$imgUrl}{$unixTime} . "\n";
    }
}
