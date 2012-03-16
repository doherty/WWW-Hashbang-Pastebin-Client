use warnings;
use strict;
use Test::More;
use WWW::Hashbang::Pastebin::Client;
use Plack::Loader;

plan ($ENV{'TEST_SITE'}
    ? (tests => 3)
    : (skip_all => q{Specify $ENV{'TEST_SITE'} with a webserver running WWW::Hashbang::Pastebin})
);
my $pastebin = $ENV{'TEST_SITE'};

my $client = WWW::Hashbang::Pastebin::Client->new(url => $pastebin);
my $text   = rand();
my $url    = $client->paste(paste => $text);
note "Created: $url";

$pastebin = quotemeta $pastebin;
like $url, qr{^$pastebin(.+)}, 'URL approximately correct';

if ($url =~ m{^$pastebin(.+)}) {
    my $retrieved_text = $client->get($1);
    is $retrieved_text, $text, 'retrieved text = submitted text';
}
else {
    fail "Couldn't parse URL: $url";
}

my $retrieved_text = $client->get($url);
is $retrieved_text, $text, 'text retrieved via full URL = submitted text';
