import gobject.types;
import javascriptcore.c.functions;
import javascriptcore.c.types;
import javascriptcore.class_;
import javascriptcore.context;
import javascriptcore.exception;
import javascriptcore.global;
import javascriptcore.types;
import javascriptcore.value;
import javascriptcore.virtual_machine;
import std.stdio;

class MyCoolClass {

	int counter = 0;

	void count() {
		writeln("Count! ", this.counter);
		counter++;
	}
}

void main() {
	// Auto creates a VM.
	Context context = new Context();

	// And then get the VM.
	VirtualMachine vm = context.getVirtualMachine();

	/// Evaluate javascript code. (run it)
	/// Params:
	///   jsCode = The code to evaluate.
	///   autoPrint = If the evaluation returns a string, should it write to the console?
	/// Returns: The evaluated value.
	Value eval(string jsCode, bool autoPrint = true) {
		Value output = context.evaluate(jsCode);

		// This is how you check for errors.
		ExceptionWrap except = context.getException();
		if (except !is null) {
			writeln(except.toString_);
		}

		if (autoPrint && output.isString()) {
			writeln(output.toString_);
		}

		return output;
	}

	// Fancy new way of registering a function.

	int count;

	context.registerFunction("test", (string input) {
		count++;
		writeln(input, " | ", count);
	});

	// Registering a class.
	ClassVTable vTable;
	auto testing = context.registerClass(MyCoolClass.stringof, null, vTable, null);

	//JSCValue* function(
	//  JSCClass* jscClass,
	//  const(char)* name,
	//  GCallback callback, 
	//  void* userData, 
	//  GDestroyNotify destroyNotify,
	//  GType returnType, 
	//  uint nParams, 
	//  ..., <- This is your constructor parameter list.
	//  void* HIDDEN <- this is where userdata gets passed in.
	//)c_jsc_class_add_constructor;
	// jsc_class_add_constructor();

	eval("test(1);");

	context.destroy();

}
