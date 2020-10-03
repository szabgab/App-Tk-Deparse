package App::Deparse::Tk;
use strict;
use warnings;
use 5.008;

use Path::Tiny qw(path);

use Tk;

our $VERSION = '0.01';

# TODO make fonts more readable
# TODO make it clear what is the input window and what is the output window
# TODO Clear the output when we change the input (or maybe rerun the deparse process?)
# TODO make the output window read-only

my $sample = q{
# Paste your code in the top window and click the Deparse button to see what B::Deparse thinks about it
for (my $j=0, $j<3, ++$j) {
    print $j;
}
};

my @flags = ('d', 'p', 'q', 'l');

sub new {
    my ($class) = @_;
    my $self = bless {}, $class;

    $self->{top} = MainWindow->new(
        -title => 'B::Deparse',
    );
    #$self->create_menu;
    $self->create_app;
    $self->{incode}->insert("0.0", $sample);
    $self->deparse;

    return $self;
}

sub create_app {
    my ($self) = @_;
    $self->{incode} = $self->{top}->Text(
        -state => 'normal',
        -font  => ['Curier', 12],
        -bg    => 'white',
    );
    $self->{incode}->pack(-fill => 'both', -expand => 1);

    for my $flag (@flags) {
        $self->{"${flag}_flag"} = 0;

        $self->{"${flag}_flag_checkbox"} = $self->{top}->Checkbutton(
        -text     => "-$flag",
        -variable => \$self->{"${flag}_flag"},
        -font     => ['fixed', 10],
        -command  => sub { $self->deparse },
        );
        $self->{"${flag}_flag_checkbox"}->pack(-side => 'top');
    }

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
        
    my $cmd = 'perl -MO=Deparse';
    if ($self->{d_flag}) {
        $cmd .= ',-d'
    }
    if ($self->{p_flag}) {
        $cmd .= ',-p'
    }
    if ($self->{q_flag}) {
        $cmd .= ',-q'
    }

    my $out = qx{$cmd $temp};
    # TODO: save to file, run deparse on it, get the output and paste it in the same window (or maybe another window?)
    $self->{outcode}->delete("0.0", 'end');
    $self->{outcode}->insert("0.0", $out);

}

sub run {
    my ($self) = @_;
    MainLoop;
}

1;