package staticdata;

import haxe.macro.Context;
import haxe.macro.Expr;

class MacroUtil
{
	public static var enumMeta(get, never):Metadata;
	static inline function get_enumMeta():Metadata
	{
		return [{pos:Context.currentPos(), name:":enum"}];
	}
	static var _ids:Map<String, Map<String, Bool>> = new Map();

	public static function label(pos:Position, label:String)
	{
		var inf = Context.getPosInfos(pos);
		return Context.makePosition({
			min: inf.min, max: inf.max,
			file: inf.file + ":" + label,
		});
	}

	public static function titleCase(str:String)
	{
		var titleCase:String = "";
		var upperCase:Bool = true;

		for (i in 0 ... str.length)
		{
			switch(str.charAt(i))
			{
				case " ", "_", "-":
					upperCase = true;
				default:
					titleCase += upperCase ? str.charAt(i).toUpperCase() : str.charAt(i);
					upperCase = false;
			}
		}

		return titleCase;
	}

	public static function snakeCase(str:String)
	{
		var snakeCase:String = "";

		for (i in 0 ... str.length)
		{
			if (i > 0 && str.charAt(i) == str.charAt(i).toUpperCase())
			{
				snakeCase += "_";
			}
			snakeCase += str.charAt(i).toLowerCase();
		}

		return snakeCase;
	}

	public static function camelCase(str:String)
	{
		var title = titleCase(str);
		return title.charAt(0).toLowerCase() + str.substr(1);
	}

	public static function ident(e:Expr):Null<String>
	{
		return switch (e.expr)
		{
			case EConst(CString(s)), EConst(CIdent(s)): s;
			case EField(e, field):
				return ident(e) + "." + field;
			default: null;
		}
	}

	public static function toExpr(v:Dynamic, ?p:Position):Expr
	{
		if (Std.is(v, Value))
		{
			throw "Can't coerce a Value to an Expr this way. You probably meant to use ValueTools.valToExpr.";
		}
		var cls = std.Type.getClass(v);
		if (cls == null) return Context.makeExpr(v, p);
		switch (std.Type.getClassName(cls))
		{
			case "Array":
				var a:Array<Dynamic> = cast v;
				return at(EArrayDecl([
					for (value in a) toExpr(value, p)
				]), p);
			case "String":
				return at(EConst(CString(v)), p);
			case "haxe.ds.StringMap", "haxe.ds.IntMap":
				var m:Map<Dynamic, Dynamic> = cast v;
				return Lambda.count(v) > 0 ? at(EArrayDecl([
					for (value in m.keys())
					macro $v{value} => ${toExpr(m[value], p)}
				]), p) : at((macro new Map()).expr, p);
			default: return Context.makeExpr(v, p);
		}
	}

	public static function at(expr:ExprDef, ?p:Position)
	{
		if (p == null) p = Context.currentPos();
		return {expr: expr, pos: p};
	}
}
