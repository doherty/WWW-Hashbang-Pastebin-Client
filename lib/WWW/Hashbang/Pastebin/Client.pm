package WWW::Hashbang::Pastebin::Client;
use strict;
use warnings;
# ABSTRACT: a client library for WWW::Hashbang::Pastebin websites
# VERSION

use HTTP::Tiny;
use Carp;

=head1 SYNOPSIS

    use WWW::Hashbang::Pastebin::Client;
    my $client = WWW::Hashbang::Pastebin::Client->new(url => 'http://p.hashbang.ca');

    # retrieve paste content by paste ID
    print $client->get('b'), "\n";

    # create a paste from a string
    my $pasted_string_url = $client->paste(paste => rand());

    # create a paste from a file
    my $pasted_file_url = $client->paste(file => '/var/log/syslog');

    print "$pasted_string_url\n$pasted_file_url\n";


=head1 DESCRIPTION

B<WWW::Hashbang::Pastebin::Client> is, as you  might expect, a client library
for interfacing with L<WWW::Hashbang::Pastebin> websites. It also ships with
an example command-line client L<p>.

=head1 METHODS

=head2 new

Creates a new client object. You must provide the URL of the
L<WWW::Hashbang::Pastebin> site you want to talk to:

    my $client = WWW::Hashbang::Pastebin::Client->new(url => 'http://p.hashbang.ca');

=cut

sub new {
    my $class = shift;
    my %args = @_;
    croak 'No pastebin URL provided' unless $args{url};
    croak 'Pastebin must be an absolute URL' unless $args{url} =~ m{^http};

    my $self = { url => $args{url} };
    $self->{ua} = HTTP::Tiny->new(
        agent => __PACKAGE__ . '/'
            . (__PACKAGE__->VERSION ? __PACKAGE__->VERSION : 'dev')
            . ' (+https://metacpan.org/module/' . __PACKAGE__ . ')'
    );

    return bless $self, $class;
}

=head2 paste

Create a new paste on the specified website. Specify either C<file> to read in
the named file, or C<paste> to provide the text directly:

    # create a paste from a string
    my $pasted_string_url = $client->paste(paste => rand());

    # create a paste from a file
    my $pasted_file_url = $client->paste(file => '/var/log/syslog');

    print "$pasted_string_url\n$pasted_file_url\n";

=cut

sub paste {
    my $self = shift;
    my %args = @_;

    if ($args{file}) {
        $args{paste} = do {
            local $/;
            open my $in, '<', $args{file}
                or die "Can't open $args{file} for reading: $!";
            <$in>
        };
    }
    croak 'No paste content given' unless $args{paste};

    my $post_response = $self->{ua}->post_form(
        $self->{url}, { p => $args{paste} }
    );

    return $post_response->{headers}->{'X-Pastebin-URL'} || $post_response->{content}
        if $post_response->{success};

    die $post_response->{status}, ' ' , $post_response->{reason}, ' ', $post_response->{content};
}

=head2 put

This is a synonym for L</paste>.

=cut

sub put {
    my $self = shift;
    $self->paste(@_);
}

=head2 get

Get paste content from the pastebin. Pass just the ID of the paste:

    # retrieve paste content by paste ID
    print $client->get('b'), "\n";

=cut

sub get {
    my $self = shift;
    my $id   = shift;
    croak 'No paste ID given' unless $id;
    
    $id =~ s{^\Q$self->{url}\E}{} if ($id =~ m/\Q$self->{url}\E/);
    $id =~ s{^/}{};
    $id =~ s{\+$}{};
    chomp $id;

    my $URI = "$self->{url}/$id";
    my $get_response = $self->{ua}->get($URI);

    return $get_response->{content} if $get_response->{success};

    die $get_response->{status}, ' ' , $get_response->{reason}, ' ', $get_response->{content};
}

=head2 retrieve

This is a synonym for L</get>

=cut

sub retrieve {
    my $self = shift;
    $self->get(@_);
}

1;
