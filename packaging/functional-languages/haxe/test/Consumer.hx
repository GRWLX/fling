import sshfling.SSHFling;

class Consumer {
  static function main():Void {
    Sys.exit(SSHFling.run(Sys.args()));
  }
}
