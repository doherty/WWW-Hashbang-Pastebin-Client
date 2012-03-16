use strict;
use warnings;
use Test::More 0.96;
use WWW::Hashbang::Pastebin::Client;
use URI;

plan ($ENV{'TEST_SITE'}
    ? (tests => 2)
    : (skip_all => q{Specify $ENV{'TEST_SITE'} with a webserver running WWW::Hashbang::Pastebin})
);
my $pastebin = $ENV{'TEST_SITE'};

my $url = URI->new($pastebin);
my $client = WWW::Hashbang::Pastebin::Client->new(url => $url->as_string);

my $paste_id = 'b';
my $paste_content = 'its alive';

subtest $paste_id => sub {
    plan tests => 2;
    is $client->get($paste_id), $paste_content;

    $url->path($paste_id);
    is $client->get($url->as_string), $paste_content;
};

subtest "$paste_id." => sub {
    plan tests => 2;
    is $client->get("$paste_id."), $paste_content;
    
    $url->path("$paste_id.");
    is $client->get($url->as_string), $paste_content;
};
