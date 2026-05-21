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

	// alias extern(C) void function() GCallback;
	/*
	JSCContext* context          = cast(JSCContext*) context._cPtr
	const(char)* name            = null (assigned after)
	GCallback callback           = cast(GCallback)&callback
	void* userData               = cast(void*) stringTest
	GDestroyNotify destroyNotify = destroyNotify
	GType returnType             = GTypeFlags.None
	uint nParams                 = 1
	... (this is variadic)       = A list of GTypes, one for each parameter.
	*/

	import std.string;

	extern (C) const(char)* callback(float number, const(char)* userData) {
		import core.stdc.stdlib;

		// Passed in from javascript.
		writeln("I am a callback! also: ", number);

		// Passed in from D.
		writeln(userData.fromStringz);

		// GTK takes over for C deallocation (I think).
		const hl = "hello from the callback!";
		char* retVal = cast(char*) malloc(char.sizeof * hl.length + 1);
		retVal[0 .. hl.length + 1] = hl ~ '\0';

		// Passing back out to D using GTK wrapper.
		return retVal;
	}

	extern (C) void destroyNotify(void* data) {
		writeln("destroy!!");
	}

	JSCValue* test =
		jsc_value_new_function(
			cast(JSCContext*) context._cPtr,
			null, cast(GCallback)&callback, cast(void*) stringTest, &destroyNotify, GTypeEnum.String, 1, GTypeEnum
				.Float);

	jsc_context_set_value(cast(JSCContext*) context._cPtr, "test", test);

	eval("test(1);");

	writeln(stringTest[0 .. 11]);

	context.destroy();

}
