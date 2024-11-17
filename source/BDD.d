// Copyright (c) 2017-2024 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Behavior Driven Development testing framework for the D programming language
// https://github.com/workhorsy/BDD

/++
Behavior Driven Development testing framework for the D programming language

Home page:
$(LINK https://github.com/workhorsy/BDD)

Version: 4.0.0

License:
Boost Software License - Version 1.0

Examples:
----
import BDD;

int add(int a, int b) {
	return a + b;
}

unittest {
	describe("math#add",
		before(delegate() {

		}),
		after(delegate() {

		}),
		it("Should add positive numbers", delegate() {
			add(5, 7).shouldEqual(12);
		}),
		it("Should add negative numbers", delegate() {
			add(5, -7).shouldEqual(-2);
		})
	);
}

----
+/


module BDD;


// Runs all the modules unit tests
shared static this() {
	import core.runtime : Runtime;
	import std.algorithm : filter;
	import std.array : array;
	import std.stdio : stdout;

	Runtime.moduleUnitTester = () {
		// Get all the modules
		ModuleInfo*[] modules;
		foreach (m; ModuleInfo) {
			modules ~= m;
		}

		// Only get the modules that have unit tests
		modules = modules.filter!(m => m && m.unitTest).array();

		// Run all the tests
		foreach (mod; modules) {
//			stdout.writefln("test module: %s", mod.name); stdout.flush();
			mod.unitTest()();
		}

		foreach (describe_message, errors; _fail_messages) {
			stdout.writefln("%s", describe_message); stdout.flush();
			foreach (error; errors) {
				stdout.writefln("%s", error); stdout.flush();
			}
		}

		// Print the results
		stdout.writeln("Unit Test Results:"); stdout.flush();
		stdout.writefln("%d total, %d successful, %d failed", _success_count + _fail_count, _success_count, _fail_count); stdout.flush();

		// Return result
		bool did_succeed = _fail_count <= 0;
		return did_succeed;
	};
}


/++
Used to assert that one value is equal to another value.

Params:
 a = The value to test.
 b = The value it should be equal to.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If values are not equal, will throw an AssertError with expected and actual
 values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <3> expected to equal <5>."
int z = 3;
z.shouldEqual(5);
----
+/
void shouldEqual(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a != b) {
		if (! message) {
			message = "<%s> expected to equal <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldEqual",
		it("Should succeed when equal", delegate() {
			"abc".shouldEqual("abc");
		}),
		it("Should fail when NOT equal", delegate() {
			shouldThrow("<abc> expected to equal <xyz>.", delegate() {
				"abc".shouldEqual("xyz");
			});
		})
	);
}

/++
Used to assert that one value is NOT equal to another value.

Params:
 a = The value to test.
 b = The value it should NOT be equal to.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If values are NOT equal, will throw an AssertError with unexpected and
 actual values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <3> expected to NOT equal <3>."
int z = 3;
z.shouldNotEqual(3);
----
+/
void shouldNotEqual(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a == b) {
		if (! message) {
			message = "<%s> expected to NOT equal <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldNotEqual",
		it("Should succeed when NOT equal", delegate() {
			"abc".shouldNotEqual("xyz");
		}),
		it("Should fail when equal", delegate() {
			shouldThrow("<abc> expected to NOT equal <abc>.", delegate() {
				"abc".shouldNotEqual("abc");
			});
		})
	);
}

/++
Used to assert that one value is equal to null.

Params:
 a = The value that should equal null.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If value is NOT null, will throw an AssertError.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): expected to be <null>."
string z = "blah";
z.shouldBeNull();
----
+/
void shouldBeNull(T)(T a, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a !is null) {
		if (! message) {
			message = "expected to be <null>.";
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeNull",
		it("Should succeed when it is null", delegate() {
			string value = null;
			value.shouldBeNull();
		}),
		it("Should fail when it is NOT null", delegate() {
			shouldThrow("expected to be <null>.", delegate() {
				string value = "abc";
				value.shouldBeNull();
			});
		})
	);
}

/++
Used to assert that one value is NOT equal to null.

Params:
 a = The value that should NOT equal null.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If value is null, will throw an AssertError.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): expected to NOT be <null>."
string z = null;
z.shouldNotBeNull();
----
+/
void shouldNotBeNull(T)(T a, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import core.exception : AssertError;

	if (a is null) {
		if (! message) {
			message = "expected to NOT be <null>.";
		}
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldNotBeNull",
		it("Should succeed when it is NOT null", delegate() {
			"abc".shouldNotBeNull();
		}),
		it("Should fail when it is null", delegate() {
			shouldThrow("expected to NOT be <null>.", delegate() {
				string value = null;
				value.shouldNotBeNull();
			});
		})
	);
}

/++
Used to assert that one value is in an array of specified values.

Params:
 value = The value to test.
 valid_values = An array of valid values.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is not in the array, will throw an AssertError with the value
 and array values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <Bobrick> is not in <[Tim, Al]>."
"Bobrick".shouldBeIn(["Tim", "Al"]);
----
+/
void shouldBeIn(T, U)(T value, U[] valid_values, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import std.array : join;
	import std.algorithm : map;
	import core.exception : AssertError;
	import std.conv : to;

	bool is_valid = false;

	foreach (valid; valid_values) {
		if (value == valid) {
			is_valid = true;
		}
	}

	if (! is_valid) {
		string message = "<%s> is not in <[%s]>.".format(value, valid_values.map!(n => n.to!string).join(", "));
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeIn",
		it("Should succeed when the string is in the array", delegate() {
			"abc".shouldBeIn(["abc", "xyz"]);
			2.shouldBeIn([1, 2, 3]);
		}),
		it("Should fail when the string is NOT in the array", delegate() {
			shouldThrow("<qed> is not in <[abc, xyz]>.", delegate() {
				"qed".shouldBeIn(["abc", "xyz"]);
			});
		})
	);
}

/++
Used to assert that one value is NOT in an array of specified values.

Params:
 value = The value to test.
 valid_values = An array of valid values.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is in the array, will throw an AssertError with the value
 and array values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <Mark> is in <[Tim, Mark]>."
"Mark".shouldNotBeIn(["Tim", "Mark"]);
----
+/
void shouldNotBeIn(T, U)(T value, U[] valid_values, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import std.array : join;
	import std.algorithm : map;
	import core.exception : AssertError;
	import std.conv : to;

	bool is_valid = true;

	foreach (valid; valid_values) {
		if (value == valid) {
			is_valid = false;
		}
	}

	if (! is_valid) {
		string message = "<%s> is in <[%s]>.".format(value, valid_values.map!(n => n.to!string).join(", "));
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldNotBeIn",
		it("Should succeed when the string is NOT in the array", delegate() {
			"xxx".shouldNotBeIn(["abc", "xyz"]);
			7.shouldNotBeIn([1, 2, 3]);
		}),
		it("Should fail when the string is in the array", delegate() {
			shouldThrow("<abc> is in <[abc, xyz]>.", delegate() {
				"abc".shouldNotBeIn(["abc", "xyz"]);
			});
		})
	);
}

/++
Used to assert that one value is greater than another value.

Params:
 a = The value to test.
 b = The value it should be greater than.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is NOT greater, will throw an AssertError with expected and actual
 values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <5> expected to be greater than <10>."
5.shouldBeGreater(10);
----
+/
void shouldBeGreater(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a <= b) {
		if (! message) {
			message = "<%s> expected to be greater than <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeGreater",
		it("Should succeed when one is greater", delegate() {
			10.shouldBeGreater(5);
		}),
		it("Should fail when one is NOT greater", delegate() {
			shouldThrow("<5> expected to be greater than <10>.", delegate() {
				5.shouldBeGreater(10);
			});
		})
	);
}

/++
Used to assert that one value is less than another value.

Params:
 a = The value to test.
 b = The value it should be less than.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is NOT less, will throw an AssertError with expected and actual
 values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <10> expected to be less than <5>."
10.shouldBeLess(5);
----
+/
void shouldBeLess(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a >= b) {
		if (! message) {
			message = "<%s> expected to be less than <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeLess",
		it("Should succeed when one is less", delegate() {
			5.shouldBeLess(10);
		}),
		it("Should fail when one is NOT less", delegate() {
			shouldThrow("<10> expected to be less than <5>.", delegate() {
				10.shouldBeLess(5);
			});
		})
	);
}

/++
Used to assert that one value is greater or equal than another value.

Params:
 a = The value to test.
 b = The value it should be greater or equal than.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is NOT greater or equal, will throw an AssertError with expected and actual
 values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <5> expected to be greater or equal to <10>."
5.shouldBeGreaterOrEqual(10);
----
+/
void shouldBeGreaterOrEqual(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a < b) {
		if (! message) {
			message = "<%s> expected to be greater or equal to <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeGreaterOrEqual",
		it("Should succeed when one is greater", delegate() {
			10.shouldBeGreaterOrEqual(5);
		}),
		it("Should succeed when one is equal", delegate() {
			10.shouldBeGreaterOrEqual(10);
		}),
		it("Should fail when one is less", delegate() {
			shouldThrow("<5> expected to be greater or equal to <10>.", delegate() {
				5.shouldBeGreaterOrEqual(10);
			});
		})
	);
}

/++
Used to assert that one value is less or equal than another value.

Params:
 a = The value to test.
 b = The value it should be less or equal than.
 message = The custom message to display instead of default.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If the value is NOT less or equal, will throw an AssertError with expected and actual
 values.

Examples:
----
// Will throw an exception like "AssertError@example.d(6): <10> expected to be less or equal to <5>."
10.shouldBeLessOrEqual(5);
----
+/
void shouldBeLessOrEqual(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import std.string : format;
	import core.exception : AssertError;

	if (a > b) {
		if (! message) {
			message = "<%s> expected to be less or equal to <%s>.".format(a, b);
		}
		message = escapeASCII(message);
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeLessOrEqual",
		it("Should succeed when one is less", delegate() {
			5.shouldBeLessOrEqual(10);
		}),
		it("Should succeed when one is equal", delegate() {
			10.shouldBeLessOrEqual(10);
		}),
		it("Should fail when one is less", delegate() {
			shouldThrow("<10> expected to be less or equal to <5>.", delegate() {
				10.shouldBeLessOrEqual(5);
			});
		})
	);
}

/++
Used for asserting that a delegate will throw an exception.

Params:
 cb = The delegate that is expected to throw the exception.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If delegate does NOT throw, will throw an AssertError.

Examples:
----
// Makes sure it throws, but does not check the message
shouldThrow(delegate() {
	throw new Exception("boom!");
});

// Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected one.
shouldThrow(delegate() {

});
----
+/
void shouldThrow(void delegate() cb, string file=__FILE__, size_t line=__LINE__) {
	shouldThrow(null, cb, file, line);
}

/++
Used for asserting that a delegate will throw an exception.

Params:
 cb = The delegate that is expected to throw the exception.
 message = The message that is expected to be in the exception. Will not
be tested, if it is null.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Throws:
 If delegate does NOT throw, will throw an AssertError.

Examples:
----
// Makes sure it throws with the message "boom!"
shouldThrow("boom!", delegate() {
	throw new Exception("boom!");
});

// Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected: boom!"
shouldThrow("boom!", delegate() {

});
----
+/
void shouldThrow(string message, void delegate() cb, string file=__FILE__, size_t line=__LINE__) {
	import core.exception : AssertError;
	import std.string : format;

	bool has_thrown = false;
	try {
		cb();
	} catch (Throwable ex) {
		has_thrown = true;
		if (message && message != ex.msg) {
			throw new AssertError("Exception was thrown. Expected <%s> but got <%s>".format(message, ex.msg), file, line);
		}
	}

	if (! has_thrown) {
		if (message) {
			throw new AssertError("Exception was not thrown. Expected <%s>".format(message), file, line);
		} else {
			throw new AssertError("Exception was not thrown. Expected one.", file, line);
		}
	}
}

unittest {
	describe("BDD#shouldThrow",
		it("Should succeed when an exception is thrown", delegate() {
			bool has_thrown = false;

			shouldThrow(delegate() {
				has_thrown = true;
				throw new Exception("boom!");
			});

			has_thrown.shouldEqual(true);
		}),
		it("Should succeed when a named exception is thrown", delegate() {
			bool has_thrown = false;

			shouldThrow("smack!", delegate() {
				has_thrown = true;
				throw new Exception("smack!");
			});

			has_thrown.shouldEqual(true);
		}),
		it("Should fail when a wrongly named exception is thrown", delegate() {
			Throwable ex = null;
			try {
				shouldThrow("Yeeeeeeeeeeesssss!", () {
					throw new Exception("Nooooooo!");
				});
			} catch (Throwable exception) {
				ex = exception;
			}

			ex.shouldNotBeNull();
			ex.msg.shouldEqual("Exception was thrown. Expected <Yeeeeeeeeeeesssss!> but got <Nooooooo!>");
		}),
		it("Should fail when an exception is not thrown", delegate() {
			Throwable ex = null;
			try {
				shouldThrow(delegate() {
					// Does not throw
				});
			} catch (Throwable exception) {
				ex = exception;
			}

			ex.shouldNotBeNull();
			ex.msg.shouldEqual("Exception was not thrown. Expected one.");
		}),
		it("Should fail when a named exception is not thrown", delegate() {
			Throwable ex = null;
			try {
				shouldThrow("kapow!", delegate() {
					// Does not throw
				});
			} catch (Throwable exception) {
				ex = exception;
			}

			ex.shouldNotBeNull();
			ex.msg.shouldEqual("Exception was not thrown. Expected <kapow!>");
		})
	);
}

/++
Used to describe the thing being tested. Contains many 'it' functions to
test the thing.

Params:
 describe_message = The thing that is being described.
 its = All the 'it' functions that will test the thing.

Examples:
----
	describe("example_library#thing_to_test",
		it("Should NOT fail", delegate() {
			// test code here
		})
	);
----
+/
void describe(string describe_message, ItFunc[] its ...) {
	describe(describe_message, BeforeFunc.init, AfterFunc.init, its);
}

/++
Used to describe the thing being tested. Contains many 'it' functions to
test the thing. Also takes a function to run before each test.

Params:
 describe_message = The thing that is being described.
 before = The function that will run before each 'it' function. If the before
function fails, the 'it' function will not be run.
 its = All the 'it' functions that will test the thing.

Examples:
----
	describe("example_library#thing_to_test",
		before(delegate() {
			// setup code here
		}),
		it("Should NOT fail", delegate() {
			// test code here
		})
	);
----
+/
void describe(string describe_message, BeforeFunc before, ItFunc[] its ...) {
	describe(describe_message, before, AfterFunc.init, its);
}

/++
Used to describe the thing being tested. Contains many 'it' functions to
test the thing. Also takes a function to run after each test.

Params:
 describe_message = The thing that is being described.
 after = The function that will run after each 'it' function. Will alwasy run,
even if the 'before' or 'it' function failed.
 its = All the 'it' functions that will test the thing.

Examples:
----
	describe("example_library#thing_to_test",
		after(delegate() {
			// tear down code here
		}),
		it("Should NOT fail", delegate() {
			// test code here
		})
	);
----
+/
void describe(string describe_message, AfterFunc after, ItFunc[] its ...) {
	describe(describe_message, BeforeFunc.init, after, its);
}

/++
Used to describe the thing being tested. Contains many 'it' functions to
test the thing. Also takes a function to run before, and a function to
run after each test.

Params:
 describe_message = The thing that is being described.
 before = The function that will run before each 'it' function. If the before
function fails, the 'it' function will not be run.
 after = The function that will run after each 'it' function. Will alwasy run,
even if the 'before' or 'it' function failed.
 its = All the 'it' functions that will test the thing.

Examples:
----
	describe("example_library#thing_to_test",
		before(delegate() {
			// setup code here
		}),
		after(delegate() {
			// tear down code here
		}),
		it("Should NOT fail", delegate() {
			// test code here
		})
	);
----
+/
void describe(string describe_message, BeforeFunc before, AfterFunc after, ItFunc[] its ...) {
	foreach (ItFunc it; its) {
		// Run before function
		bool before_threw = false;
		try {
			if (before != BeforeFunc.init) {
				before.func();
			}
		} catch (Throwable ex) {
			before_threw = true;
			addFail(describe_message, before, ex);
		}

		// Run it function
		try {
			if (! before_threw) {
				it.func();
				addSuccess();
			}
		} catch (Throwable ex) {
			addFail(describe_message, it, ex);
		}

		// Run after function
		try {
			if (after != AfterFunc.init) {
				after.func();
			}
		} catch (Throwable ex) {
			addFail(describe_message, after, ex);
		}
	}
}

/++
The message should describe what the test should do.

Params:
 message = The message to print when the test fails.
 func = The delegate to call when running the test.
 file = The file name that the 'it' is located in. Should be left as default.
 line = The file line that the 'it' is located at. Should be left as default.

Examples:
----
int a = 4;
describe("example_library#a",
	it("Should equal 4", delegate() {
		a.shouldEqual(4);
	}),
	it("Should Not equal 5", delegate() {
		a.shouldNotEqual(5);
	})
);
----
+/
ItFunc it(string message, void delegate() func, string file=__FILE__, size_t line=__LINE__) {
	ItFunc retval;
	retval.it_message = message;
	retval.func = func;
	retval.file = file;
	retval.line = line;

	return retval;
}

unittest {
	int counter = 0;

	describe("BDD#it",
		it("Should inc counter", delegate() {
			counter++;
		}),
		it("Should inc counter again", delegate() {
			counter++;
		})
	);

	counter.shouldEqual(2);
}

// Should call everything, even if it throws
unittest {
	int counter = 0;

	startSavingExceptions();

	describe("BDD#it_throw",
		// Should run
		before(delegate() {
			counter++;
		}),
		// Should run
		after(delegate() {
			counter++;
		}),
		// Should run
		it("Should throw", delegate() {
			counter++;
			throw new Exception("It function is throwing!");
		}),
		it("Should throw again", delegate() {
			counter++;
			throw new Exception("Other it function is throwing!");
		}),
	);

	counter.shouldEqual(6);
	_saved_exceptions.length.shouldEqual(2);
	_saved_exceptions[0].msg.shouldEqual("It function is throwing!");
	_saved_exceptions[1].msg.shouldEqual("Other it function is throwing!");

	stopSavingExceptions();
}

/++
The function to call before each 'it' function.

Params:
 func = The function to call before running each test.
 file = The file name that the 'before' is located in. Should be left as default.
 line = The file line that the 'before' is located at. Should be left as default.

Examples:
----
int a = 4;
describe("example_library#a",
	before(delegate() {
		a.shouldEqual(4);
	}),
	it("Should test more things", delegate() {
		//
	})
);
----
+/
BeforeFunc before(void delegate() func, string file=__FILE__, size_t line=__LINE__) {
	BeforeFunc retval;
	retval.func = func;
	retval.file = file;
	retval.line = line;

	return retval;
}

unittest {
	int before_counter = 0;

	describe("BDD#before",
		before(delegate() {
			before_counter++;
		}),
		it("Should call before", delegate() {
			before_counter.shouldEqual(1);
		}),
		it("Should call before again", delegate() {
			before_counter.shouldEqual(2);
		})
	);
}

// Should call before and after, even if before throws
unittest {
	int counter = 0;

	startSavingExceptions();

	describe("BDD#before_throw",
		// Should run
		before(delegate() {
			counter++;
			throw new Exception("Before function is throwing!");
		}),
		// Should run
		after(delegate() {
			counter++;
		}),
		// Should NOT run
		it("Should inc counter", delegate() {
			counter++;
		}),
		// Should NOT run
		it("Should inc counter again", delegate() {
			counter++;
		}),
	);

	counter.shouldEqual(4);
	_saved_exceptions.length.shouldEqual(2);
	foreach (err ; _saved_exceptions) {
		err.msg.shouldEqual("Before function is throwing!");
	}

	stopSavingExceptions();
}

/++
The function to call after each 'it' function.

Params:
 func = The function to call after running each test.
 file = The file name that the 'after' is located in. Should be left as default.
 line = The file line that the 'after' is located at. Should be left as default.

Examples:
----
int a = 4;
describe("example_library#a",
	after(delegate() {
		a.shouldEqual(4);
	}),
	it("Should test more things", delegate() {
		//
	})
);
----
+/
AfterFunc after(void delegate() func, string file=__FILE__, size_t line=__LINE__) {
	AfterFunc retval;
	retval.func = func;
	retval.file = file;
	retval.line = line;

	return retval;
}

unittest {
	int after_counter = 0;

	describe("BDD#after",
		after(delegate() {
			after_counter++;
		}),
		it("Should call after", delegate() {
			after_counter.shouldEqual(0);
		}),
		it("Should call after again", delegate() {
			after_counter.shouldEqual(1);
		})
	);
}

// Should call everything, even if after throws
unittest {
	int counter = 0;

	startSavingExceptions();

	describe("BDD#after_throw",
		// Should run
		before(delegate() {
			counter++;
		}),
		// Should run
		after(delegate() {
			counter++;
			throw new Exception("After function is throwing!");
		}),
		// Should run
		it("Should inc counter", delegate() {
			counter++;
		}),
		// Should run
		it("Should inc counter again", delegate() {
			counter++;
		}),
	);

	counter.shouldEqual(6);
	_saved_exceptions.length.shouldEqual(2);
	foreach (err ; _saved_exceptions) {
		err.msg.shouldEqual("After function is throwing!");
	}

	stopSavingExceptions();
}

unittest {
	int before_counter = 0;
	int after_counter = 0;

	describe("BDD#before_and_after",
		before(delegate() {
			before_counter++;
		}),
		after(delegate() {
			after_counter++;
		}),
		it("Should call after", delegate() {
			before_counter.shouldEqual(1);
			after_counter.shouldEqual(0);
		}),
		it("Should call after again", delegate() {
			before_counter.shouldEqual(2);
			after_counter.shouldEqual(1);
		})
	);
}

private:

struct BeforeFunc {
	void delegate() func;
	string file;
	size_t line;
}

struct AfterFunc {
	void delegate() func;
	string file;
	size_t line;
}

struct ItFunc {
	string it_message;
	void delegate() func;
	string file;
	size_t line;
}

void addSuccess() {
	_success_count++;
}

void addFail(M, F, E)(M describe_message, F func, E err)
	if (is(M == string) &&
	is(F == ItFunc) || is(F == BeforeFunc) || is(F == AfterFunc) &&
	is(E == Throwable)) {

	import std.string : split, format;
	import std.array : replace;
	import std.conv : to;

	// Just save the exception if desired
	if (_save_exceptions) {
		_saved_exceptions ~= err;
		return;
	}

	// Get the message, file, and line of the func
	string it_message = "Unknown";
	static if (is(F == ItFunc)) {
		it_message = "    - \"%s\" %s(%s)".format(func.it_message, func.file, func.line);
	} else static if (is(F == BeforeFunc)) {
		it_message = "    - \"before()\" %s(%s)".format(func.file, func.line);
	} else static if (is(F == AfterFunc)) {
		it_message = "    - \"after()\" %s(%s)".format(func.file, func.line);
	} else {
		static assert(0, `Unexpected op "%s"`.format(F.stringof));
	}

	// Get the stack trace
	string stack_trace = "        %s".format(err.to!string.replace("\n", "\n        "));

	string message = "%s\n%s".format(it_message, stack_trace);
	_fail_messages[describe_message] ~= message;
	_fail_count++;
}

void startSavingExceptions() {
	_saved_exceptions = [];
	_save_exceptions = true;
}

void stopSavingExceptions() {
	_saved_exceptions = [];
	_save_exceptions = false;
}

string escapeASCII(string message) {
	import std.string : format;
	import std.ascii : isControl;
	import std.array : replace;

	// Replace clear rule, new line, and tab
	message = message.replace("\r", "\\r").replace("\n", "\\n").replace("\t", "\\t");

	string retval = "";
	foreach (char n ; message) {
		if (isControl(n)) {
			retval ~= `\0x%x`.format(cast(int) n);
		} else {
			retval ~= n;
		}
	}

	return retval;
}

unittest {
	describe("BDD#escapeASCII",
		it("Should escape ascii", delegate() {
			escapeASCII("ab cd").shouldEqual("ab cd");
			escapeASCII("ab\tcd\r\n").shouldEqual("ab\\tcd\\r\\n");
			escapeASCII("abcd\017").shouldEqual(`abcd\0xf`);
			escapeASCII("abcd\22").shouldEqual(`abcd\0x12`);
			escapeASCII("abcd\2\0").shouldEqual(`abcd\0x2\0x0`);
			escapeASCII("うぇ \022 えぉ").shouldEqual(`うぇ \0x12 えぉ`);
		})
	);
}

bool _save_exceptions = false;
Throwable[] _saved_exceptions;
string[][string] _fail_messages;
ulong _fail_count;
ulong _success_count;
