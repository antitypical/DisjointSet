//  Copyright (c) 2015 Rob Rix. All rights reserved.

final class DisjointSetTests: XCTestCase {
	let set: DisjointSet<String> = [ "a", "b", "c", "d", "e" ]

	func testEveryElementIsInitiallyDisjoint() {
		var set = self.set
		if !reduce(lazy(enumerate(set))
			.map { index, _ in (index, set.find(index)) }
			.map(==), true, { $0 && $1 }) {
				failure("it didn't work")
		}
	}

	func testUnionCombinesPartitions() {
		var set = self.set
		set.union(1, 3)
		assertEqual(set.findAll().count, 4)
	}
}


// MARK: - Imports

import Assertions
import DisjointSet
import XCTest
