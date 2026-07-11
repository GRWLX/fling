package sshfling;

#if macro
import haxe.macro.Context;
import haxe.macro.Expr;
#end

class PackageRootMacro {
  public static macro function sourcePackageRoot():ExprOf<String> {
    final file = Context.getPosInfos(Context.currentPos()).file;
    final absolute = sys.FileSystem.fullPath(file);
    final root = haxe.io.Path.directory(haxe.io.Path.directory(haxe.io.Path.directory(absolute)));
    return macro $v{root};
  }
}
