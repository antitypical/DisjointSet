//  Copyright (c) 2015 Rob Rix. All rights reserved.

public struct DisjointSet<T>: ArrayLiteralConvertible, ExtensibleCollectionType {
	public init<S: SequenceType where S.Generator.Element == T>(_ sequence: S) {
		sets = map(enumerate(sequence)) { (parent: $0, rank: 0, value: $1) }
	}


	/// The number of elements in the set.
	///
	/// This is distinct from the number of partitions in the set.
	public var count: Int {
		return sets.count
	}


	public mutating func unionInPlace(a: Int, _ b: Int) {
		let (r1, r2) = (findInPlace(a), findInPlace(b))
		let (n1, n2) = (sets[r1], sets[r2])
		if r1 != r2 {
			if n1.rank < n2.rank {
				sets[r1].parent = r2
			} else {
				sets[r2].parent = r1
				if n1.rank == n2.rank {
					++sets[r1].rank
				}
			}
		}
	}


	public mutating func findInPlace(a: Int) -> Int {
		let n = sets[a]
		if n.parent == a {
			return a
		} else {
			let parent = findInPlace(n.parent)
			sets[a].parent = parent
			return parent
		}
	}

	public mutating func findAllInPlace() -> Set<Int> {
		return Set(lazy(sets)
			.map { $0.0 }
			.map(findInPlace))
	}


	// MARK: ArrayLiteralConvertible

	public init(arrayLiteral elements: T...) {
		self.init(elements)
	}


	// MARK: CollectionType

	public let startIndex = 0

	public var endIndex: Int {
		return count
	}

	public subscript (index: Int) -> T {
		return sets[index].value
	}


	// MARK: ExtensibleCollectionType

	public init() {
		sets = []
	}

	public mutating func reserveCapacity(minimumCapacity: Int) {
		sets.reserveCapacity(minimumCapacity)
	}

	public mutating func append(value: T) {
		sets.append(parent: count, rank: 0, value: value)
	}

	public mutating func extend<S: SequenceType where S.Generator.Element == T>(values: S) {
		for each in values {
			append(each)
		}
	}


	// MARK: SequenceType

	public func generate() -> GeneratorOf<T> {
		return GeneratorOf(lazy(sets).map { $2 }.generate())
	}


	// MARK: Private

	private var sets: [(parent: Int, rank: Int, value: T)]
}
