




import std.stdio : stdout;


int add(int a, int b) {
	return a + b;
}

unittest {
	import BDD;

	describe("math#add",
		it("Should add positive numbers", delegate() {
			add(5, 7).shouldEqual(12);
		}),
		it("Should add negative numbers", delegate() {
			add(5, -7).shouldEqual(-2);
		})
	);
}
