package hxdata.data;

@:build(hxdata.macros.DataEnum.build(["tests/data/test_model1.xml"], "test_parent.test_model"))
@:enum
abstract TestModel1(String) from String to String
{
	@:a public var field1:Int = 0;
	@:a public var field2:String = "defaultval";
	@:a public var field3:Array<Int>;
	@:a public var field4:Map<String, Bool>;
	@:a("^id") public var field5:String;
}
