//  Copyright (c) 2015 Rob Rix. All rights reserved.

/// A disjoint set is a collection whose elements are grouped together into disjoint (non-overlapping) partitions.
///
/// No restrictions are placed on the elements themselves, but access to the partitions is almost exclusively mediated by index. Therefore, the caller will need to be able to produce the index for a given element from a binary search or a dictionary if they do not wish to resort to linear search via `find`.
public struct DisjointSet<T>: ArrayLiteralConvertible, CollectionType, CustomStringConvertible {
	/// Constructs a disjoint set with the elements in a `sequence`.
	public init<S: SequenceType where S.Generator.Element == T>(_ sequence: S) {
		sets = sequence.enumerate().map { (parent: $0, rank: 0, value: $1) }
	}


	/// The number of elements in the set.
	///
	/// This is distinct from the number of partitions in the set.
	public var count: Int {
		return sets.count
	}

	/// The set’s elements, partitioned into arrays.
	public var partitions: LazyMapCollection<Dictionary<Int, [T]>, [T]> {
		return enumerate().lazy
			.map { (self.find($0), $1) }
			.reduce([Int: [T]]()) { (var g, kv) in
				g[kv.0] = (g[kv.0] ?? []) + [ kv.1 ]
				return g
			}
			.values
	}


	// MARK: Union

	/// Returns the disjoint set created by merging the sets at indices `a` and `b` if they are not already merged.
	public func union(a: Int, _ b: Int) -> DisjointSet {
		var copy = self
		copy.unionInPlace(a, b)
		return copy
	}

	/// Merges the sets at indices `a` and `b` if they are not already merged.
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


	// MARK: Find

	/// Returns the index of the representative of the set for the element at index `a`.
	public func find(var a: Int) -> Int {
		while sets[a].parent != a {
			a = sets[a].parent
		}
		return a
	}

	/// Returns the index of the representative of the set for the element at index `a`.
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

	/// Returns the indices of the representatives of each set.
	public mutating func findAllInPlace() -> Set<Int> {
		return Set(sets.lazy
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
		sets.append((parent: count, rank: 0, value: value))
	}

	public mutating func extend<S: SequenceType where S.Generator.Element == T>(values: S) {
		for each in values {
			append(each)
		}
	}


	// MARK: Printable

	public var description: String {
		let groups = enumerate().lazy
			.map { (self.find($0), String($1)) }.reduce([Int: [String]]()) { (var g, kv) in
				g[kv.0] = (g[kv.0] ?? []) + [ kv.1 ]
				return g
			}
		return "{\(groups.lazy.map { "{\($1.joinWithSeparator(", "))}" }.joinWithSeparator(", "))}"
	}


	// MARK: SequenceType

	public func generate() -> AnyGenerator<T> {
		return anyGenerator(sets.lazy.map { $2 }.generate())
	}


	// MARK: Private

	/// The storage for the sets operated upon by the disjoint set.
	///
	/// The sets are logically an in-tree: each element has a parent index pointing at the next representative of its set. When the element is its set’s representative, `parent` will be its own index.
	///
	/// They are additionally ranked, which is an optimization which helps to ensure that the trees are as flat as possible.
	///
	/// Finally, they hold the caller-facing value of type `T`.
	private var sets: [(parent: Int, rank: Int, value: T)]
}
