import SwiftLuauBindings

/// Representation of a Lua light userdata.
public struct LuaLightUserdata: @unchecked Sendable, Equatable, LuaPushable, LuaGettable {
    /// The pointer wrapped by the light userdata.
    public let pointer: UnsafeMutableRawPointer

    /// Initialize a LuaLightUserdata with a pointer.
    /// - Parameter pointer: The pointer to wrap.
    public init(pointer: UnsafeMutableRawPointer) {
        self.pointer = pointer
    }

    /// Push the light userdata onto the Lua stack.
    /// - Parameter state: The Lua state to push the light userdata to.
    public func push(to state: LuaState) {
        LuaLightUserdata.push(self.pointer, to: state)
    }

    /// Push a light userdata onto the Lua stack.
    /// - Parameters:
    ///   - pointer: The pointer to push as light userdata.
    ///   - state: The Lua state to push to.
    public static func push(_ pointer: UnsafeMutableRawPointer, to state: LuaState) {
        lua_pushlightuserdatatagged(state.state, pointer, 0)
    }

    /// Get a light userdata from the Lua stack.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The light userdata if it exists and is a light userdata, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaLightUserdata? {
        if LuaType.get(from: state, at: index) != .lightUserdata {
            return nil
        }
        guard let pointer = lua_tolightuserdatatagged(state.state, index, 0) else {
            return nil
        }
        return LuaLightUserdata(pointer: pointer)
    }
}
