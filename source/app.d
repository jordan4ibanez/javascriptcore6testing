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
		// writeln("hello, I am ", MyCoolClass.stringof);
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

	// Registering a class.
	ClassVTable* vTable = null;

	extern (C) void destroyNotify(void* userData) {

		if (userData !is null) {

			//! This is an extreme hack to get the original memory address.
			JSCValue* rawData = jsc_value_object_get_property(cast(JSCValue*) userData, "ptr"
					.toStringz);
			string addressString = jsc_value_to_string(rawData).fromStringz.idup;
			void* address = cast(void*) parse!ulong(addressString, 16);
			MyCoolClass neat = cast(MyCoolClass) address;
			neat.destroy();
			GC.removeRoot(address);
			GC.free(address);

		}
	}

	// JSCClass* function(
	//  JSCContext* context,         = cast(JSCContext*) context._cPtr
	//  const(char)* name,           = "MyCoolClass"
	//  JSCClass* parentClass,       = null
	//  JSCClassVTable* vtable,      = vTable
	//  GDestroyNotify destroyNotify = destroyNotify
	//) c_jsc_context_register_class;

	JSCClass* jsMyCoolClass = jsc_context_register_class(
		cast(JSCContext*) context._cPtr, "MyCoolClass".toStringz, null, vTable, cast(GDestroyNotify)&destroyNotify);

	extern (C) JSCValue* constructorCallBack(void* userData) {

		//? Being passed in: Tuple!(void*, JSCClass*)* environmentData

		MyCoolClass dGCData = new MyCoolClass();

		// Prevent the GC from crashing this.
		//! This is now "manual" memory management !
		GC.addRoot(cast(void*) dGCData);

		// Now unpack the tuple pointer that was passed in.
		Tuple!(void*, JSCClass*)* environmentData = cast(Tuple!(void*, JSCClass*)*) userData;

		// Now make the values understandable.
		JSCContext* contextPointer = cast(JSCContext*)(*environmentData)[0];

		JSCClass* classPointer = cast(JSCClass*)(*environmentData)[1];

		// Create the javascript object.
		JSCValue* object = jsc_value_new_object(contextPointer, cast(void*) dGCData, classPointer);

		string address = format("%X", cast(size_t) cast(void*) dGCData);
		jsc_value_object_set_property(object, "ptr", jsc_value_new_string(contextPointer, address
				.toStringz));

		// Now return a C anchored D class.
		return object;
	}

	//JSCValue* function(
	//  JSCClass* jscClass,           = cast(JSCClass*) jsMyCoolClass._cPtr
	//  const(char)* name,            = ""
	//  GCallback callback,           = callBack
	//  void* userData,               = &environmentData
	//  GDestroyNotify destroyNotify, = null
	//  GType returnType,             = GTypeEnum.Object
	//  uint nParams,                 = 0
	//  ..., <- This is your constructor parameter list.
	//  void* HIDDEN <- this is where userdata gets passed in.
	//)c_jsc_class_add_constructor;
	// jsc_class_add_constructor();

	// It must pass in the context and the class data.

	Tuple!(void*, JSCClass*)* environmentData = new Tuple!(void*, JSCClass*)(
		context._cPtr, jsMyCoolClass);
	//! Stop the GC from destroying this.
	GC.addRoot(environmentData);

	JSCValue* constructorValue = jsc_class_add_constructor(
		cast(JSCClass*) jsMyCoolClass, "MyCoolClass".toStringz, cast(GCallback)&constructorCallBack, environmentData, null,
		GTypeEnum.Object, 0);

	//void function(
	//  JSCClass* jscClass,
	//  const(char)* name,
	//  GCallback callback,
	//  void* userData,
	//  GDestroyNotify destroyNotify,
	//  GType returnType,
	//  uint nParams, 
	// ...,
	// HIDDEN <- userdata
	//) c_jsc_class_add_method; ///

	jsc_class_add_method(jsMyCoolClass, "count", cast(GCallback)&MyCoolClass.count, null, null, GTypeEnum.None, 0);

	JSCValue* globalObject = jsc_context_get_global_object(cast(JSCContext*) context._cPtr);

	jsc_value_object_set_property(globalObject, "MyCoolClass".toStringz, constructorValue);

	int i = 0;

	eval("let x = new MyCoolClass();");

	while (true) {
		eval(`
		(() => {
			// x.count();
			let blah = new MyCoolClass();
		})();
	`);
		GC.collect();
		GC.minimize();
		i++;
	}

	context.destroy();

}
