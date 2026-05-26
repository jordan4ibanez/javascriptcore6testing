import core.memory;
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

	static void registerJSVM(Context context) {
		auto jsvmClass = context.registerClass!MyCoolClass;
		context.setValue("MyCoolClass", jsvmClass.addConstructor!newFull);
		jsvmClass.addMethod!count;
		jsvmClass.addProperty!(counterGetter, counterSetter)("counter");
	}

	int counterGetter() {
		return counter;
	}

	void counterSetter(int n) {
		counter = n;
	}

	static MyCoolClass newFull() {
		return new MyCoolClass;
	}

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

	// Register MyCoolClass.
	MyCoolClass.registerJSVM(context);

	eval("let x = new MyCoolClass();");

	while (true) {
		eval(`
		(() => {
			x.count();
			let blah = new MyCoolClass();

			writeln(x.counter);
		})();
	 `);
		GC.collect();
		GC.minimize();

	}

	context.destroy();

}
