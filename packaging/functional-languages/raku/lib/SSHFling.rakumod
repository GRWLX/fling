unit module SSHFling;

sub configured-or(Str $name, Str $fallback --> Str) {
    %*ENV{$name}:exists && %*ENV{$name}.chars ?? %*ENV{$name} !! $fallback
}

sub package-version(--> Str) is export {
    "0.0.0"
}

sub package-root(--> IO::Path) is export {
    configured-or("SSHFLING_PACKAGE_ROOT", $?FILE.IO.parent.parent.absolute.Str).IO
}

sub runtime-path(--> Str) is export {
    configured-or("SSHFLING_RUNTIME", package-root.add("runtime/sshfling.py").Str)
}

sub template-directory(--> Str) is export {
    configured-or("SSHFLING_TEMPLATE_DIR", package-root.add("runtime/templates").Str)
}

sub restore-env(Str $name, Bool $had-value, $previous) {
    if $had-value {
        %*ENV{$name} = $previous.Str;
    } else {
        %*ENV{$name}:delete;
    }
}

sub run(@arguments --> Int) is export {
    for @arguments -> $argument {
        unless $argument ~~ Str {
            note "sshfling: arguments must be strings";
            return 2;
        }
    }

    my $runtime = runtime-path;
    return 127 unless $runtime.IO.f;

    my Bool $had-template = %*ENV<SSHFLING_TEMPLATE_DIR>:exists ?? True !! False;
    my $previous-template = $had-template ?? %*ENV<SSHFLING_TEMPLATE_DIR> !! "";
    my Bool $had-unbuffered = %*ENV<PYTHONUNBUFFERED>:exists ?? True !! False;
    my $previous-unbuffered = $had-unbuffered ?? %*ENV<PYTHONUNBUFFERED> !! "";
    LEAVE {
        restore-env("SSHFLING_TEMPLATE_DIR", $had-template, $previous-template);
        restore-env("PYTHONUNBUFFERED", $had-unbuffered, $previous-unbuffered);
    }

    %*ENV<SSHFLING_TEMPLATE_DIR> = template-directory;
    %*ENV<PYTHONUNBUFFERED> = "1";
    my $python = configured-or("SSHFLING_PYTHON", "python3");
    my $process = Proc::Async.new($python, $runtime, |@arguments);
    try {
        my $status = await $process.start;
        return $status.exitcode;
    }
    note "sshfling: " ~ $!.message;
    127
}
