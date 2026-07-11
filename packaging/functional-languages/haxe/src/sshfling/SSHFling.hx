package sshfling;

import haxe.io.Path;
import sys.FileSystem;

class SSHFling {
  public static inline final packageVersion:String = "0.0.0";

  static function configuredOr(name:String, fallback:String):String {
    final value = Sys.getEnv(name);
    return value != null && value.length > 0 ? value : fallback;
  }

  public static function packageRoot():String {
    return configuredOr("SSHFLING_PACKAGE_ROOT", PackageRootMacro.sourcePackageRoot());
  }

  public static function runtimePath():String {
    return configuredOr("SSHFLING_RUNTIME", Path.join([packageRoot(), "runtime", "sshfling.py"]));
  }

  public static function templateDirectory():String {
    return configuredOr("SSHFLING_TEMPLATE_DIR", Path.join([packageRoot(), "runtime", "templates"]));
  }

  static function runRuntime(arguments:Array<String>):Int {
    final command = configuredOr("SSHFLING_PYTHON", "python3");
    final commandArguments = [runtimePath()].concat(arguments);
    return Sys.command(command, commandArguments);
  }

  public static function run(arguments:Array<String>):Int {
    if (arguments == null) {
      arguments = [];
    }
    for (argument in arguments) {
      if (argument == null) {
        Sys.stderr().writeString("sshfling: arguments must be strings\n");
        return 2;
      }
    }

    final runtime = runtimePath();
    if (!FileSystem.exists(runtime) || FileSystem.isDirectory(runtime)) {
      return 127;
    }

    Sys.putEnv("SSHFLING_TEMPLATE_DIR", templateDirectory());
    Sys.putEnv("PYTHONUNBUFFERED", "1");
    try {
      return runRuntime(arguments);
    } catch (error:Dynamic) {
      Sys.stderr().writeString("sshfling: " + Std.string(error) + "\n");
      return 127;
    }
  }
}
