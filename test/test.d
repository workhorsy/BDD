
import BDD;
import std.stdio;
import core.exception : AssertError;

unittest {
	describe("BDD https://github.com/workhorsy/BDD/issues/18",
		it("Should escape non display characters in error messages", delegate() {
			// Create an error message from failing to compare 2 strings
			ShouldAssertError err;
			try {
				"abcd\0\0".shouldEqual("abcd\0");
			} catch (ShouldAssertError ex) {
				err = ex;
			}

			// Make sure the error message is escaped correctly
			err.msg.shouldEqual("Not equal");
			err._details.shouldEqual(
				"Expected:\n<abcd\\0x0\\0x0>\nTo equal:\n<abcd\\0x0>");
		}),
	);

	describe("BDD https://github.com/workhorsy/BDD/issues/14",
		it("Should put error message values on own lines", delegate() {
			// Create an error message from failing to compare 2 strings
			ShouldAssertError err;
			try {
				"abc".shouldEqual("xyz");
			} catch (ShouldAssertError ex) {
				err = ex;
			}

			// Make sure the error message is escaped correctly
			err.msg.shouldEqual("Not equal");
			err._details.shouldEqual(
				"Expected:\n<abc>\nTo equal:\n<xyz>");
		}),
	);
}
