package App::Deparse::Tk;
use strict;
use warnings;
use 5.008;

use Path::Tiny qw(path);

use Tk;

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;

    $self->{top} = MainWindow->new(
        -title => 'B::Deparse',
    );
    #$self->create_menu;
    $self->create_app;

    return $self;
}

sub create_app {
    my ($self) = @_;
    $self->{incode} = $self->{top}->Text(
        -state => 'normal',
        -font => ['fixed', 12],
    );
    $self->{incode}->pack(-fill => 'both', -expand => 1);


    $self->{outcode} = $self->{top}->Text(
        -state => 'normal',
        -font => ['fixed', 12],
    );
    $self->{outcode}->pack(-fill => 'both', -expand => 1);


    $self->{deparse} = $self->{top}->Button(
        -text    => 'Deparse',
        -command => sub { $self->deparse },
    );
    $self->{deparse}->pack()

}

sub deparse {
    my ($self) = @_;
    my $code = $self->{incode}->get("0.0", 'end');
    my $temp = Path::Tiny->tempfile;
    path($temp)->spew($code);
    # TODO: handle STDERR
    # TODO: handle exit code
    my $out = qx{perl -MO=Deparse $temp};
    # TODO: save to file, run deparse on it, get the output and paste it in the same window (or maybe another window?)
    $self->{outcode}->delete("0.0", 'end');
    $self->{outcode}->insert("0.0", $out);

}

sub run {
    my ($self) = @_;
    MainLoop;
}

1;