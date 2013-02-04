#!/usr/bin/perl
# Copy bare GitHub repositories to local machine (including wikis).
use strict;
use warnings;
use LWP::Simple qw(get);
use JSON;
use Cwd;
use File::Spec;
use File::Path qw(remove_tree);
use Getopt::Long;

# Option to clone a normal repository, not a bare one
my $nomirror = '';    # create mirror (bare repository) by default
my $wiki     = '';    # don't clone wikis by default
usage() unless GetOptions( 'nomirror' => \$nomirror, 'wiki' => \$wiki );

# Where to clone repos (last command line argument)
my $dest_dir = pop @ARGV;
usage() unless defined $dest_dir and -d $dest_dir;

# Github users to backup
my @usernames = @ARGV;
usage() unless @usernames > 0;

# Get all repos for the username
for my $username (@usernames) {

    print "\n> Working on user '$username'\n";

    # Prepare destination dir
    my $dest_dir = File::Spec->catfile( $dest_dir, $username );
    if ( -d $dest_dir ) {
        remove_tree($dest_dir) && print "Removed '$dest_dir'\n";
    }
    mkdir $dest_dir or die "Can't create '$dest_dir': $!";

    for my $repo ( @{ get_repo_info($username) } ) {

        my $name     = $repo->{'name'};
        my $ssh_url  = $repo->{'ssh_url'};
        my $has_wiki = $repo->{'has_wiki'};

        print ">> Working on repo '$name'\n";

        # Repo
        clone_repo( $ssh_url, $dest_dir );

        # Wiki
        if ( $has_wiki eq 'true' and $wiki ) {
            ( my $wiki_url = $ssh_url ) =~ s#\.git$#.wiki.git#;

            # Returns error if wiki is enabled but is empty
            clone_repo( $wiki_url, $dest_dir );
        }
    }

}

sub usage {
    die
"Usage: $0 [ --nomirror --wiki ] username1 [ username2 ... usernameN ] existing_dir\n";
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

    my $git_cmd = "git clone --quiet --mirror $repo_url";
    $git_cmd = "git clone --quiet $repo_url" if $nomirror;

    if ( system $git_cmd ) {

        # Return wasn't zero, meaning failure
        print "'$repo_url' NOT cloned!\n";
    } else {
        print "'$repo_url' cloned to $dest_dir.\n";
    }
}
