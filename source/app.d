import javascriptcore.c.functions;
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

	context.evaluate("console.log('hi')");

	// This is how you check for errors.
	ExceptionWrap except = context.getException();
	if (except !is null) {
		writeln(except.toString_);
	}

	/*
	JSCContext* context          = context._cPtr
	const(char)* name            = "test"
	GCallback callback           = null
	void* userData               = null
	GDestroyNotify destroyNotify = null
	GType returnType             = GTypeFlags.None
	uint nParams                 = 0
	... (this is variadic)       = (nothing)
	*/

	jsc_value_new_function(context._cPtr, "test", null, null, GTypeFlags.None, 0);

}
