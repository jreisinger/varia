#!/usr/bin/perl
# Copy bare GitHub repositories to local machine (including wikis).
use strict;
use warnings;
use LWP::Simple qw(get);
use JSON;
use Cwd;
use File::Spec;

# Where to clone repos (last command line argument)
my $dest_dir = pop @ARGV;
usage() unless -d $dest_dir;

# Github users to backup
my @usernames = @ARGV;
usage() unless @usernames > 0;

# Get all repos for the username
for my $username (@usernames) {

    print "\n> Working on user '$username'\n";
    my $dest_dir = File::Spec->catfile( $dest_dir, $username );
    mkdir $dest_dir or die "Can't create '$dest_dir': $!";

    for my $repo ( @{ get_repo_info($username) } ) {

        my $name     = $repo->{'name'};
        my $ssh_url  = $repo->{'ssh_url'};
        my $has_wiki = $repo->{'has_wiki'};

        print ">> Working on repo '$name'\n";

        # Repo
        clone_repo( $ssh_url, $dest_dir );

        # Wiki
        if ( $has_wiki eq 'true' ) {
            (my $wiki_url = $ssh_url) =~ s#\.git$#.wiki.git#;
            # Returns error if wiki is enabled but is empty
            clone_repo( $wiki_url, $dest_dir );
        }
    }

}

sub usage {
    die "$0 username1 [ username2 ... usernameN ] existing_dir\n";
}

sub get_repo_info {
    ## Return array ref containig HoH.
    my $username = shift;

    # API v3
    my $html         = get("https://api.github.com/users/$username/repos");
    my $decoded_json = decode_json $html;

    # One array ref field has info on one repo.
    return $decoded_json;
}

sub clone_repo {
    my $repo_url = shift;
    my $dest_dir = shift;

    chdir $dest_dir if getcwd ne $dest_dir;

    if ( system "git clone --quiet --mirror $repo_url" ) {

        # Return wasn't zero, meaning failure
        print "'$repo_url' NOT cloned!\n";
    } else {
        print "'$repo_url' cloned to $dest_dir.\n";
    }
}
