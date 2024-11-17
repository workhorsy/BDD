# BDD
Behavior Driven Development testing framework for the D programming language

# Documentation

[https://workhorsy.github.io/BDD/4.1.0/](https://workhorsy.github.io/BDD/4.1.0/)

# Example

```d
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
```

# Generate documentation

```
dub --build=docs
```

# Run unit tests

```
dub test
```

[![Dub version](https://img.shields.io/dub/v/bdd.svg)](https://code.dlang.org/packages/bdd)
[![Dub downloads](https://img.shields.io/dub/dt/bdd.svg)](https://code.dlang.org/packages/bdd)
[![License](https://img.shields.io/badge/license-BSL_1.0-blue.svg)](https://raw.githubusercontent.com/workhorsy/BDD/master/LICENSE)
