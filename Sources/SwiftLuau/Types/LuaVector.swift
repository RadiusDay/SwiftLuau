import SwiftLuauBindings

/// A 3D vector type for Lua. Along with related functions.
public struct LuaVector: Sendable, LuaPushable, LuaGettable {
    /// A 3D vector type.
    public struct Vector: Sendable, Equatable, Hashable, Codable {
        public var x: Float
        public var y: Float
        public var z: Float

        public init(x: Float, y: Float, z: Float) {
            self.x = x
            self.y = y
            self.z = z
        }
    }

    /// A reference to the Lua value.
    public let reference: LuaRef

    /// Initialize a LuaVector with a LuaRef.
    /// - Parameter reference: The LuaRef to the vector value.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaVector from x, y, z components.
    /// - Parameters:
    ///   - vector: The Vector components.
    ///   - state: The Lua state.
    /// - Returns: A LuaVector instance.
    public static func create(vector: Vector, in state: LuaState) -> LuaVector {
        lua_pushvector(state.state, vector.x, vector.y, vector.z)
        let ref = LuaRef.store(-1, in: state)
        return LuaVector(reference: ref)
    }

    /// The vector value.
    /// - Parameter state: The Lua state.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a LuaVector from the Lua stack at the given index.
    /// - Parameters:
    ///   - state: The Lua state.
    ///   - index: The stack index.
    /// - Returns: A LuaVector if it exists and is a vector, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaVector? {
        if LuaType.get(from: state, at: index) != .vector {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaVector(reference: ref)
    }

    /// Get the Vector value.
    /// - Returns: The Vector value if it exists and is a vector, nil otherwise.
    public func toVector() -> Vector? {
        let state = reference.state.take()
        push(to: state)
        guard let ptr = lua_tovector(state.state, -1) else {
            Lua.pop(state, 1)
            return nil
        }
        let vector = Vector(x: ptr[0], y: ptr[1], z: ptr[2])
        Lua.pop(state, 1)
        return vector
    }
}
