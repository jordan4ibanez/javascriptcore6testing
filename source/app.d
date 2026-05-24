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
		// writeln("peace from ", cast(void*) this);
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

	/**
	* //! This was rewritten to:
  javascriptcore.class_.Class registerClass(string name, javascriptcore.class_.Class parentClass, 
  javascriptcore.types.ClassVTable vtable, GDestroyNotify dstryNot = null)
  {
    JSCClass* _cretval;
    const(char)* _name = name.toCString(No.Alloc);
    _cretval = jsc_context_register_class(cast(JSCContext*)this._cPtr, _name, parentClass ? cast(JSCClass*)parentClass._cPtr(No.Dup) : null, &vtable, dstryNot);
    auto _retval = gobject.object.ObjectWrap._getDObject!(javascriptcore.class_.Class)(cast(JSCClass*)_cretval, No.Take);
    return _retval;
  }

	*/

	// This has the chance of getting overwritten by C lol.
	extern (C) union HackJob(T) if (is(T == class)) {
	align(8):
		size_t jscValue;
		T dData;
	}

	extern (C) JSCValue* constructorCallBack(void* userData) {

		//? Being passed in: Tuple!(void*, JSCClass*)* environmentData

		// Now unpack the tuple pointer that was passed in.
		Tuple!(void*, JSCClass*)* environmentData = cast(Tuple!(void*, JSCClass*)*) userData;

		// Now make the values understandable.
		JSCContext* contextPointer = cast(JSCContext*)(*environmentData)[0];

		JSCClass* classPointer = cast(JSCClass*)(*environmentData)[1];

		// Now managed by C memory.
		HackJob!MyCoolClass* cMangling = cast(HackJob!MyCoolClass*) malloc(
			HackJob!MyCoolClass.sizeof);

		MyCoolClass outputData = new MyCoolClass();

		// Needs to be assigned in this order or it crashes.

		cMangling.dData = outputData;

		cMangling.jscValue = *(cast(size_t*) jsc_value_new_object(contextPointer, cast(
				void*) outputData, classPointer));

		return cast(JSCValue*) cMangling;
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
		context._cPtr, cast(JSCClass*) jsMyCoolClass._cPtr);

	//! Stop the GC from destroying this.
	GC.addRoot(environmentData);

	JSCValue* constructorValue = jsc_class_add_constructor(
		cast(JSCClass*) jsMyCoolClass._cPtr, "MyCoolClass".toStringz, cast(GCallback)&constructorCallBack, environmentData,
		null, GTypeEnum.Object, 0);

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

	jsc_class_add_method(cast(JSCClass*) jsMyCoolClass._cPtr, "count", cast(GCallback)&MyCoolClass.count, null, null,
		GTypeEnum.None, 0);

	jsc_value_object_set_property(cast(JSCValue*) context.getGlobalObject()
			._cPtr, "MyCoolClass".toStringz, constructorValue);

	int i = 0;

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
		i++;
	}

	context.destroy();

}
