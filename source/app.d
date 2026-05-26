import core.memory;
import javascriptcore.context;
import javascriptcore.exception;
import javascriptcore.global;
import javascriptcore.types;
import javascriptcore.value;
import javascriptcore.virtual_machine;
import std.conv;
import std.file;
import std.stdio;
import std.string;
import std.sumtype;
import std.typecons;

class MyCoolClass {

	int counter = 0;

	int[] fakeData;

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
		// writeln("hello, I am ", MyCoolClass.stringof);

		this.fakeData = new int[](1_000_000);

	}

	~this() {
		// writeln("peace from ", cast(void*) this);
	}

	void count() {
		// writeln("Count! ", this.counter);
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
	///   jsCode = JS code to evaluate.
	///   autoPrint = If it should print things returned from javascript.
	/// Returns: Sumtype of Value or if something blew up with ExceptionWrap.
	SumType!(Value, ExceptionWrap) eval(string jsCode, bool autoPrint = true) {

		Value evaluationOutput = context.evaluate(jsCode);

		auto output = SumType!(Value, ExceptionWrap)();

		// This is how you check for errors.

		// If it's an error, that's what we shall return.
		ExceptionWrap except = context.getException();
		if (except !is null) {
			output = except;
			writeln(except.toString_);
			return output;
		}

		// Autoprint niceties.
		if (autoPrint && evaluationOutput.isString()) {
			writeln(evaluationOutput.toString_);
		}

		output = evaluationOutput;

		return output;
	}

	/// Load a JS file.
	/// Params:
	///   filePath = Where your JS file is.
	/// Returns: Success.
	bool loadJsFile(string filePath) {

		string data;

		try {
			data = readText(filePath);
		} catch (FileException e) {
			writeln(e);
			return false;
		}

		Value output = eval(data);

		return true;
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

	loadJsFile("./cool.js");

	context.destroy();

}
