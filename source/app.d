import core.memory;
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
import std.conv;
import std.stdio;
import std.string;
import std.typecons;

class MyCoolClass {

	int counter = 0;

	this() {
		writeln("hello, I am ", MyCoolClass.stringof);
	}

	~this() {
		writeln("peace from ", cast(void*) this);
	}

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

	// Give a way to print.
	context.registerFunction("writeln", (string input...) { writeln(input); });

	eval("let x = new MyCoolClass();");

	while (true) {
		eval(`
		(() => {
			x.count();
			let blah = new MyCoolClass();

			writeln(x.counter);

			// if (x.counter > 1000) {

			// }
		})();
	 `);
		GC.collect();
		GC.minimize();

	}

	context.destroy();

}
