




import std.stdio : stdout;


int add(int a, int b) {
	return a + b;
}

unittest {
	import BDD;

	describe("math#add",
		before(delegate() {
			stdout.writeln("Before called ...");
		}),
		after(delegate() {
			stdout.writeln("After called ...");
		}),
		it("Should add positive numbers", delegate() {
			add(5, 7).shouldEqual(12);
		}),
		it("Should add negative numbers", delegate() {
			add(5, -7).shouldEqual(-2);
		})
	);
}
