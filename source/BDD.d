// Copyright (c) 2017 Matthew Brennan Jones <matthew.brennan.jones@gmail.com>
// Boost Software License - Version 1.0
// Behavior Driven Development for the D programming language
// https://github.com/workhorsy/BDD

/++
Behavior Driven Development for the D programming language

Home page:
$(LINK https://github.com/workhorsy/BDD)

License:
Boost Software License - Version 1.0

Example:
----
import BDD;

int add(int a, int b) {
	return a + b;
}

unittest {
	describe("math#add",
		it("Should add positive numbers", delegate() {
			add(5, 7).should_equal(12);
		}),
		it("Should add negative numbers", delegate() {
			add(5, -7).should_equal(-2);
		})
	);
}

// Prints the results of the tests
int main() {
	return BDD.print_results();
}
----
+/


module BDD;

import std.array;
import std.stdio;
import std.conv;
import std.string;
import core.exception;


/++
Used to assert that a value is equal to another value. Works just like assert.
 But it will automatically fill in the error message with you not having to do
it yourself.

Params:
 a = The value to test.
 b = The value it should be equal to.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will throw an exception like "AssertError@example.d(6): <3> expected to equal <5>."
int z = 3;
z.should_equal(5);
----
+/
void should_equal(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a != b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to equal <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_equal",
		it("Should succeed when equal", delegate() {
			"abc".should_equal("abc");
		}),
		it("Should fail when NOT equal", delegate() {
			should_throw(delegate() {
				"abc".should_equal("xyz");
			}, "<abc> expected to equal <xyz>.");
		})
	);
}

/++
Used to assert that a value is NOT equal to another value. Works just
like assert. But it will automatically fill in the error message with you
not having to do it yourself.

Params:
 a = The value to test.
 b = The value it should NOT be equal to.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will throw an exception like "AssertError@example.d(6): <3> expected to NOT equal <3>."
int z = 3;
z.should_not_equal(3);
----
+/
void should_not_equal(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a == b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to NOT equal <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_not_equal",
		it("Should succeed when NOT equal", delegate() {
			"abc".should_not_equal("xyz");
		}),
		it("Should fail when equal", delegate() {
			should_throw(delegate() {
				"abc".should_not_equal("abc");
			}, "<abc> expected to NOT equal <abc>.");
		})
	);
}

/++
Used to assert that a value is equal to null. Works just
like assert. But it will automatically fill in the error message with you
not having to do it yourself.

Params:
 a = The value that should equal null.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will throw an exception like "AssertError@example.d(6): expected to be <null>."
string z = "blah";
z.should_be_null();
----
+/
void should_be_null(T)(T a, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a !is null) {
		if (! message) {
			message = "expected to be <null>.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_null",
		it("Should succeed when it is null", delegate() {
			string value = null;
			value.should_be_null();
		}),
		it("Should fail when it is NOT null", delegate() {
			should_throw(delegate() {
				string value = "abc";
				value.should_be_null();
			}, "expected to be <null>.");
		})
	);
}

/++
Used to assert that a value is NOT equal to null. Works just
like assert. But it will automatically fill in the error message with you
not having to do it yourself.

Params:
 a = The value that should NOT equal null.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will throw an exception like "AssertError@example.d(6): expected to NOT be <null>."
string z = null;
z.should_not_be_null();
----
+/
void should_not_be_null(T)(T a, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a is null) {
		if (! message)
			message = "expected to NOT be <null>.";
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_not_be_null",
		it("Should succeed when it is NOT null", delegate() {
			"abc".should_not_be_null();
		}),
		it("Should fail when it is null", delegate() {
			should_throw(delegate() {
				string value = null;
				value.should_not_be_null();
			}, "expected to NOT be <null>.");
		})
	);
}

/++
Used to assert that a value is in an array of specified values. Works just like
assert. But it will automatically fill in the error message with you not having
to do it yourself.

Params:
 value = The value to test.
 valid_values = An array of valid values.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will thow an exception like "AssertError@example.d(6): <Bobrick> is not in <[Tim, Al]>."
"Bobrick".should_be_in(["Tim", "Al"]);
----
+/
void should_be_in(T, U)(T value, U[] valid_values, string file=__FILE__, size_t line=__LINE__) {
	bool is_valid = false;

	foreach (valid; valid_values) {
		if (value == valid) {
			is_valid = true;
		}
	}

	if (! is_valid) {
		string message = "<" ~ value.to!string ~ "> is not in <[" ~ valid_values.join(", ") ~ "]>.";
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_in",
		it("Should succeed when the string is in the array", delegate() {
			"abc".should_be_in(["abc", "xyz"]);
		}),
		it("Should fail when the string is NOT in the array", delegate() {
			should_throw(delegate() {
				"qed".should_be_in(["abc", "xyz"]);
			}, "<qed> is not in <[abc, xyz]>.");
		})
	);
}

/++
Used to assert that a value is greater than another value. Works just like
assert. But it will automatically fill in the error message with you not having
to do it yourself.

Params:
 a = The value to test.
 b = The value it should be greater than.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will thow an exception like "AssertError@example.d(6): <5> expected to be greater than <10>."
5.should_be_greater(10);
----
+/
void should_be_greater(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a <= b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to be greater than <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_greater",
		it("Should succeed when one is greater", delegate() {
			10.should_be_greater(5);
		}),
		it("Should fail when one is NOT greater", delegate() {
			should_throw(delegate() {
				5.should_be_greater(10);
			}, "<5> expected to be greater than <10>.");
		})
	);
}

/++
Used to assert that a value is less than another value. Works just like
assert. But it will automatically fill in the error message with you not having
to do it yourself.

Params:
 a = The value to test.
 b = The value it should be less than.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will thow an exception like "AssertError@example.d(6): <10> expected to be less than <5>."
10.should_be_less(5);
----
+/
void should_be_less(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a >= b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to be less than <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_less",
		it("Should succeed when one is less", delegate() {
			5.should_be_less(10);
		}),
		it("Should fail when one is NOT less", delegate() {
			should_throw(delegate() {
				10.should_be_less(5);
			}, "<10> expected to be less than <5>.");
		})
	);
}

/++
Used to assert that a value is greater or equal than another value. Works just like
assert. But it will automatically fill in the error message with you not having
to do it yourself.

Params:
 a = The value to test.
 b = The value it should be greater or equal than.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will thow an exception like "AssertError@example.d(6): <5> expected to be greater or equal to <10>."
5.should_be_greater_or_equal(10);
----
+/
void should_be_greater_or_equal(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a < b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to be greater or equal to <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_greater_or_equal",
		it("Should succeed when one is greater", delegate() {
			10.should_be_greater_or_equal(5);
		}),
		it("Should succeed when one is equal", delegate() {
			10.should_be_greater_or_equal(10);
		}),
		it("Should fail when one is less", delegate() {
			should_throw(delegate() {
				5.should_be_greater_or_equal(10);
			}, "<5> expected to be greater or equal to <10>.");
		})
	);
}

/++
Used to assert that a value is less or equal than another value. Works just like
assert. But it will automatically fill in the error message with you not having
to do it yourself.

Params:
 a = The value to test.
 b = The value it should be less or equal than.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Will thow an exception like "AssertError@example.d(6): <10> expected to be less or equal to <5>."
10.should_be_less_or_equal(5);
----
+/
void should_be_less_or_equal(T, U)(T a, U b, string message=null, string file=__FILE__, size_t line=__LINE__) {
	if (a > b) {
		if (! message) {
			message = "<" ~ a.to!string ~ "> expected to be less or equal to <" ~ b.to!string ~ ">.";
		}
		message = message.replace("\r", "\\r").replace("\n", "\\n");
		throw new core.exception.AssertError(message, file, line);
	}
}

unittest {
	describe("dlang_helper#should_be_less_or_equal",
		it("Should succeed when one is less", delegate() {
			5.should_be_less_or_equal(10);
		}),
		it("Should succeed when one is equal", delegate() {
			10.should_be_less_or_equal(10);
		}),
		it("Should fail when one is less", delegate() {
			should_throw(delegate() {
				10.should_be_less_or_equal(5);
			}, "<10> expected to be less or equal to <5>.");
		})
	);
}

/++
Used for asserting that a piece of code will throw an exception.

Params:
 cb = The delegate that is expected to throw the exception.
 message = The message that is expected to be in the exception. Will not
be tested, if it is null.
 file = The file name that the assert failed in. Should be left as default.
 line = The file line that the assert failed in. Should be left as default.

Example:
----
// Makes sure it thows with the message "boom!"
should_throw(delegate() {
	throw new Exception("boom!");
}, "boom!");

// Makes sure it throws, but does not check the message
should_throw(delegate() {
	throw new Exception("boom!");
});
----
+/
void should_throw(void delegate() cb, string message=null, string file=__FILE__, size_t line=__LINE__) {
	bool has_thrown = false;
	try {
		cb();
	} catch (Exception ex) {
		has_thrown = true;
		if (message && message != ex.msg) {
			throw new Exception("Exception was thrown. But expected: " ~ message, file, line);
		}
	} catch (Error err) {
		has_thrown = true;
		if (message && message != err.msg) {
			throw new Exception("Error was thrown. But expected: " ~ message, file, line);
		}
	}

	if (! has_thrown) {
		if (message) {
			throw new Exception("Exception was not thrown. Expected: " ~ message, file, line);
		} else {
			throw new Exception("Exception was not thrown. Expected one.", file, line);
		}
	}
}

unittest {
	describe("dlang_helper#should_throw",
		it("Should succeed when an exception is thrown", delegate() {
			bool has_thrown = false;

			should_throw(delegate() {
				has_thrown = true;
				throw new Exception("boom!");
			});

			has_thrown.should_equal(true);
		}),
		it("Should fail when an exception is not thrown", delegate() {
			Exception ex = null;
			try {
				should_throw(delegate() {
					// Does not throw
				});
			} catch (Exception exception) {
				ex = exception;
			}

			ex.should_not_be_null();
			ex.msg.should_equal("Exception was not thrown. Expected one.");
		})
	);
}

private string[][string] _fail_messages;
private ulong _fail_count;
private ulong _success_count;
private void delegate() _before_it;
private void delegate() _after_it;

private struct TestPair {
	string it_message;
	void delegate() func;
}

private void add_success() {
	_success_count++;
}

// Error
private void add_fail(string describe_message, TestPair pair, core.exception.Error err) {
	_fail_messages[describe_message] ~= "\"" ~ pair.it_message ~ ": " ~ err.msg ~ "\" " ~ err.file ~ "(" ~ err.line.to!string() ~ ")";
	_fail_count++;
}

// Exception
private void add_fail(string describe_message, TestPair pair, core.exception.Exception err) {
	_fail_messages[describe_message] ~= "\"" ~ pair.it_message ~ ": " ~ err.msg ~ "\" " ~ err.file ~ "(" ~ err.line.to!string() ~ ")";
	_fail_count++;
}

void before_it(void delegate() cb) {
	_before_it = cb;
}

void after_it(void delegate() cb) {
	_after_it = cb;
}

int print_results() {
	stdout.writeln("Unit Test Results:");
	stdout.writefln("%d total, %d successful, %d failed", _success_count + _fail_count, _success_count, _fail_count);

	foreach (a, b; _fail_messages) {
		stdout.writefln("%s", a);
		foreach (c; b) {
			stdout.writefln("- %s", c);
		}
	}

	return _fail_count > 0;
}

/++
Used for writing the 'describe' part of a Behavior Driven Development test.

Params:
 describe_message = The thing that is being described.
 pairs = All the 'it' delegate functions that will test the thing.

Example:
----
	describe("example_library#thing_to_test",
		it("Should NOT fail", delegate() {
			assert(true);
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

			add_success();
		} catch (core.exception.Error err) {
			add_fail(describe_message, pair, err);
		} catch (core.exception.Exception err) {
			add_fail(describe_message, pair, err);
		}
	}
}

/++
Used for writing the 'it' part of a Behavior Driven Development test.

Params:
 message = The message to print when the test fails.
 func = The delegate to call when running the test.

Example:
----
int a = 4;
describe("example_library#a",
	it("Should equal 4", delegate() {
		assert(a == 4);
	}),
	it("Should Not equal 5", delegate() {
		assert(a != 5);
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

/*
	TODO:
	* Change multiple catch Error, and Exception to one catch Throwble
	* Make indentation in docs use 4 space sized tabs
	* Change naming convention to proper D style. EG: should_equal to ShouldEqual?
	* Remove asserts, as they may mislead people to not use should functions.
	* Change string concatenation to string format.
*/
