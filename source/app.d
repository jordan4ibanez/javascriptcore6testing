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
	const(char)* name            = null (assigned after)
	GCallback callback           = cast(GCallback)&callback
	void* userData               = stringTest
	GDestroyNotify destroyNotify = null
	GType returnType             = GTypeFlags.None
	uint nParams                 = 1
	... (this is variadic)       = A list of GTypes, one for each parameter.
	*/

	// Not sure where this goes?
	const(char)* stringTest;

	extern (C) void callback(float one) {
		writeln("I am a callback! also: ", one);
	}

	JSCValue* test =
		jsc_value_new_function(
			cast(JSCContext*) context._cPtr,
			null, cast(GCallback)&callback, stringTest, null, GTypeEnum.String, 1, GTypeEnum
				.Float);

	jsc_context_set_value(cast(JSCContext*) context._cPtr, "test", test);

	eval("test(1);");

}
