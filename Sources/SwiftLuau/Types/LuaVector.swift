import SwiftLuauBindings

/// A 3D vector type for Lua. Along with related functions.
public struct LuaVector: Sendable, Equatable, Hashable, Identifiable, Codable {
    public var id: String {
        return "\(x),\(y),\(z)"
    }
    public var x: Float
    public var y: Float
    public var z: Float

    public init(x: Float, y: Float, z: Float) {
        self.x = x
        self.y = y
        self.z = z
    }

    /// Push a LuaVector onto the Lua stack as a table.
    /// - Parameters:
    ///   - vector: The LuaVector to push.
    ///   - state: The Lua state to push to.
    public static func push(_ vector: LuaVector, to state: LuaState) {
        lua_pushvector(state.state, vector.x, vector.y, vector.z)
    }

    /// Get a LuaVector from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaVector if it exists and is a vector, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaVector? {
        guard let ptr = lua_tovector(state.state, index) else {
            return nil
        }
        return LuaVector(x: ptr[0], y: ptr[1], z: ptr[2])
    }
}
