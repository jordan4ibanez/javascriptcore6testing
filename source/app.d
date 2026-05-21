import javascriptcore.c.functions;
import javascriptcore.context;
import javascriptcore.exception;
import javascriptcore.global;
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

}
