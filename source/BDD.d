// Copyright (c) 2017-2021 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Behavior Driven Development for the D programming language
// https://github.com/workhorsy/BDD

/++
Behavior Driven Development for the D programming language

Home page:
$(LINK https://github.com/workhorsy/BDD)

Version: 2.0.0

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
		foreach (m; modules) {
//			stdout.writefln("test module: %s", m.name); stdout.flush();
			m.unitTest()();
		}

		// Print the results
		stdout.writeln("Unit Test Results:"); stdout.flush();
		stdout.writefln("%d total, %d successful, %d failed", _success_count + _fail_count, _success_count, _fail_count); stdout.flush();

		foreach (a, b; _fail_messages) {
			stdout.writefln("%s", a); stdout.flush();
			foreach (c; b) {
				stdout.writefln("- %s", c); stdout.flush();
			}
		}

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
	import std.array : replace;
	import core.exception : AssertError;

	if (a != b) {
		if (! message) {
			message = "<%s> expected to equal <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldEqual",
		it("Should succeed when equal", delegate() {
			"abc".shouldEqual("abc");
		}),
		it("Should fail when NOT equal", delegate() {
			shouldThrow(delegate() {
				"abc".shouldEqual("xyz");
			}, "<abc> expected to equal <xyz>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a == b) {
		if (! message) {
			message = "<%s> expected to NOT equal <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldNotEqual",
		it("Should succeed when NOT equal", delegate() {
			"abc".shouldNotEqual("xyz");
		}),
		it("Should fail when equal", delegate() {
			shouldThrow(delegate() {
				"abc".shouldNotEqual("abc");
			}, "<abc> expected to NOT equal <abc>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a !is null) {
		if (! message) {
			message = "expected to be <null>.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
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
			shouldThrow(delegate() {
				string value = "abc";
				value.shouldBeNull();
			}, "expected to be <null>.");
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
			shouldThrow(delegate() {
				string value = null;
				value.shouldNotBeNull();
			}, "expected to NOT be <null>.");
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
	import std.array : replace, join;
	import core.exception : AssertError;

	bool is_valid = false;

	foreach (valid; valid_values) {
		if (value == valid) {
			is_valid = true;
		}
	}

	if (! is_valid) {
		string message = "<%s> is not in <[%s]>.".format(value, valid_values.join(", "));
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeIn",
		it("Should succeed when the string is in the array", delegate() {
			"abc".shouldBeIn(["abc", "xyz"]);
		}),
		it("Should fail when the string is NOT in the array", delegate() {
			shouldThrow(delegate() {
				"qed".shouldBeIn(["abc", "xyz"]);
			}, "<qed> is not in <[abc, xyz]>.");
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
	import std.array : replace, join;
	import core.exception : AssertError;

	bool is_valid = true;

	foreach (valid; valid_values) {
		if (value == valid) {
			is_valid = false;
		}
	}

	if (! is_valid) {
		string message = "<%s> is in <[%s]>.".format(value, valid_values.join(", "));
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldNotBeIn",
		it("Should succeed when the string is NOT in the array", delegate() {
			"xxx".shouldNotBeIn(["abc", "xyz"]);
		}),
		it("Should fail when the string is in the array", delegate() {
			shouldThrow(delegate() {
				"abc".shouldNotBeIn(["abc", "xyz"]);
			}, "<abc> is in <[abc, xyz]>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a <= b) {
		if (! message) {
			message = "<%s> expected to be greater than <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeGreater",
		it("Should succeed when one is greater", delegate() {
			10.shouldBeGreater(5);
		}),
		it("Should fail when one is NOT greater", delegate() {
			shouldThrow(delegate() {
				5.shouldBeGreater(10);
			}, "<5> expected to be greater than <10>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a >= b) {
		if (! message) {
			message = "<%s> expected to be less than <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new AssertError(message, file, line);
	}
}

unittest {
	describe("BDD#shouldBeLess",
		it("Should succeed when one is less", delegate() {
			5.shouldBeLess(10);
		}),
		it("Should fail when one is NOT less", delegate() {
			shouldThrow(delegate() {
				10.shouldBeLess(5);
			}, "<10> expected to be less than <5>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a < b) {
		if (! message) {
			message = "<%s> expected to be greater or equal to <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
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
			shouldThrow(delegate() {
				5.shouldBeGreaterOrEqual(10);
			}, "<5> expected to be greater or equal to <10>.");
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
	import std.array : replace;
	import core.exception : AssertError;

	if (a > b) {
		if (! message) {
			message = "<%s> expected to be less or equal to <%s>.".format(a, b);
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
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
			shouldThrow(delegate() {
				10.shouldBeLessOrEqual(5);
			}, "<10> expected to be less or equal to <5>.");
		})
	);
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
shouldThrow(delegate() {
	throw new Exception("boom!");
}, "boom!");

// Makes sure it throws, but does not check the message
shouldThrow(delegate() {
	throw new Exception("boom!");
});

// Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected: boom!"
shouldThrow(delegate() {

}, "boom!");

// Will throw an exception like "AssertError@test/example.d(7): Exception was not thrown. Expected one.
shouldThrow(delegate() {

});
----
+/
void shouldThrow(void delegate() cb, string message=null, string file=__FILE__, size_t line=__LINE__) {
	import core.exception : AssertError;

	bool has_thrown = false;
	try {
		cb();
	} catch (Throwable ex) {
		has_thrown = true;
		if (message && message != ex.msg) {
			throw new AssertError("Exception was thrown. But expected: " ~ message, file, line);
		}
	}

	if (! has_thrown) {
		if (message) {
			throw new AssertError("Exception was not thrown. Expected: " ~ message, file, line);
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

			shouldThrow(delegate() {
				has_thrown = true;
				throw new Exception("smack!");
			}, "smack!");

			has_thrown.shouldEqual(true);
		}),
		it("Should fail when a wrongly named exception is thrown", delegate() {
			Throwable ex = null;
			try {
				shouldThrow(delegate() {
					throw new Exception("Nooooooo!");
				}, "Yeeeeeeeeeeesssss!");
			} catch (Throwable exception) {
				ex = exception;
			}

			ex.shouldNotBeNull();
			ex.msg.shouldEqual("Exception was thrown. But expected: Yeeeeeeeeeeesssss!");
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
				shouldThrow(delegate() {
					// Does not throw
				}, "kapow!");
			} catch (Throwable exception) {
				ex = exception;
			}

			ex.shouldNotBeNull();
			ex.msg.shouldEqual("Exception was not thrown. Expected: kapow!");
		})
	);
}


/++
The message is usually the name of the thing being tested.

Params:
 describe_message = The thing that is being described.
 pairs = All the 'it' delegate functions that will test the thing.

Examples:
----
	describe("example_library#thing_to_test",
		it("Should NOT fail", delegate() {
			// code here
		})
	);
----
+/
void describe(TestPair...)(string describe_message, TestPair pairs) {
	foreach (pair; pairs) {
		try {
			if (_before_it) {
				_before_it();
			}

			pair.func();

			if (_after_it) {
				_after_it();
			}

			addSuccess();
		} catch (Throwable ex) {
			addFail(describe_message, pair, ex);
		}
	}
}

/++
The message should describe what the test should do.

Params:
 message = The message to print when the test fails.
 func = The delegate to call when running the test.

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
TestPair it(string message, void delegate() func) {
	TestPair retval;
	retval.it_message = message;
	retval.func = func;

	return retval;
}

void beforeIt(void delegate() cb) {
	_before_it = cb;
}

void afterIt(void delegate() cb) {
	_after_it = cb;
}

private:

struct TestPair {
	string it_message;
	void delegate() func;
}

void addSuccess() {
	_success_count++;
}

void addFail(string describe_message, TestPair pair, Throwable err) {
	import std.string : format;

	_fail_messages[describe_message] ~= `"%s: %s" %s(%s)`.format(pair.it_message, err.msg, err.file, err.line);
	_fail_count++;
}

string[][string] _fail_messages;
ulong _fail_count;
ulong _success_count;
void delegate() _before_it;
void delegate() _after_it;

/*
	TODO:
	* Make indentation in docs use 4 space sized tabs
*/
