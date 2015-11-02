//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class DisjointSetTests: XCTestCase {
	let set: DisjointSet<String> = [ "a", "b", "c", "d", "e" ]

	func testEveryElementIsInitiallyDisjoint() {
		var set = self.set
		if !(set.enumerate().lazy
			.map { index, _ in (index, set.findInPlace(index)) }
			.map(==)).reduce(true, combine: { $0 && $1 }) {
				failure("it didn't work")
		}
	}

	func testUnionCombinesPartitions() {
		var set = self.set
		set.unionInPlace(1, 3)
		assertEqual(set.findAllInPlace().count, 4)
	}

	func testAppendedElementsAreInitiallyDisjoint() {
		var set = self.set
		set.append("f")
		assert(set.findInPlace(5), ==, 5)
	}
}


// MARK: - Imports

import Assertions
import DisjointSet
import XCTest
