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

	void eval(string jsCode) {
		context.evaluate(jsCode);

		// This is how you check for errors.
		ExceptionWrap except = context.getException();
		if (except !is null) {
			writeln(except.toString_);
		}
	}

	// alias extern(C) void function() GCallback;
	/*
	JSCContext* context          = cast(JSCContext*) context._cPtr
	const(char)* name            = "test"
	GCallback callback           = callback
	void* userData               = null
	GDestroyNotify destroyNotify = null
	GType returnType             = GTypeFlags.None
	uint nParams                 = 0
	... (this is variadic)       = (nothing)
	*/

	extern (C) void callback() {
		writeln("I am a callback!");
	}

	JSCValue* test =
		jsc_value_new_function(cast(JSCContext*) context._cPtr, "test", &callback, null, null, GTypeFlags.None, 0);

	eval("test();");

}
