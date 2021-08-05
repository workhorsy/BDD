
import BDD;
import core.exception : AssertError;

unittest {
	// https://github.com/workhorsy/BDD/issues/18
	describe("BDD#bug_18",
		it("Should escape non display characters in error messages", delegate() {
			// Create an error message from failing to compare 2 strings
			string message = null;
			try {
				string a = "abcd\0\0";
				string b = "abcd\0";
				a.shouldEqual(b);
			} catch (AssertError err) {
				message = cast(string) err.message;
			}

			// Make sure the error message is escaped correctly
			message.shouldEqual(`<abcd\0x0\0x0> expected to equal <abcd\0x0>.`);
		}),
	);
}
