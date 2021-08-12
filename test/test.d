
import BDD;
import std.stdio;
import core.exception : AssertError;

unittest {
	describe("BDD https://github.com/workhorsy/BDD/issues/18",
		it("Should escape non display characters in error messages", delegate() {
			shouldThrow("shouldEqual failed\nExpected:\n<abcd\\0x0\\0x0>\nTo equal:\n<abcd\\0x0>", delegate() {
				"abcd\0\0".shouldEqual("abcd\0");
			});
		}),
	);
}
