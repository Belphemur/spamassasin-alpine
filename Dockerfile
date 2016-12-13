FROM alpine:edge
MAINTAINER Antoine Aflalo <antoine@aaflalo.me>

#Configure CamelCadeDB
ENV PERL5_DEBUG_ROLE="client"
ENV PERL5_DEBUG_HOST=172.17.0.1
ENV PERL5_DEBUG_PORT=7765

RUN apk add  --no-cache spamassassin build-base perl-dev perl-yaml perl-json perl-log-log4perl perl-libwww perl-crypt-ssleay perl-digest-hmac perl-digest-sha1 perl-http-message perl-mime-lite perl-net-cidr-lite perl-io-gzip  bash vim wget

RUN apk add perl-json-xs --update-cache --no-cache --repository http://dl-3.alpinelinux.org/alpine/edge/testing/ --allow-untrusted

# Make CPAN download dependencies
RUN perl -MCPAN -e 'my $c = "CPAN::HandleConfig"; $c->load(doit => 1, autoconfig => 1); $c->edit(prerequisites_policy => "follow"); $c->edit(build_requires_install_policy => "yes"); $c->commit'

#Update CPAN if needed
RUN cpan install CPAN && cpan reload cpan

RUN cpan Time::Piece Devel::Camelcadedb

#Remove the -T to run with Camelcadedb
RUN chmod 0700 /usr/bin/spamassassin \
    && sed -i -e 's/perl -T/perl -d:Camelcadedb/g' /usr/bin/spamassassin \
    && chmod 0555 /usr/bin/spamassassin \
    && mkdir ~/test-files/ \
    && sa-update

COPY sample-spam.txt ~/test-files/spam.txt
COPY sample-nonspam.txt ~/test-files/ham.txt

ENTRYPOINT ["spamassassin"]

