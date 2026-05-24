import gobject.types;
import javascriptcore.c.functions;
import javascriptcore.c.types;
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

	Value eval(string jsCode) {
		Value output = context.evaluate(jsCode);

		// This is how you check for errors.
		ExceptionWrap except = context.getException();
		if (except !is null) {
			writeln(except.toString_);
		}
		return output;
	}

	// Fancy new way of registering a function.
	context.registerFunction("test", (string input) { writeln("test ", input); });

	Value output = eval("test(1);");

	if (output.isString()) {
		writeln(output.toString_);
	}

	context.destroy();

}
