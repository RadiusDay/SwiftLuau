import SwiftLuauBindings

/// Functions related to Lua functions.
public struct LuaFunction: Sendable {
    public var debugName: String?
    public var function: @convention(c) (OpaquePointer?) -> Int32

    /// Create a LuaFunction.
    /// - Parameters:
    ///   - debugName: An optional debug name for the function.
    ///   - function: The Swift function to wrap.
    /// - Returns: A LuaFunction wrapping the provided Swift function.
    public init(
        debugName: String? = nil,
        function: @escaping @convention(c) (OpaquePointer?) -> Int32
    ) {
        self.debugName = debugName
        self.function = function
    }

    /// Push a Swift function onto the Lua stack.
    /// - Parameters:
    ///   - function: The Swift function to push.
    ///   - state: The Lua state to push to.
    public static func push(_ function: LuaFunction, to state: LuaState) {
        lua_pushcclosurek(state.state, function.function, function.debugName, 0, nil)
    }

    /// Pcall a Lua function at the given index with the specified number of arguments and expected results.
    /// - Parameters:
    ///   - index: The stack index of the function to call.
    ///   - nargs: The number of arguments to pass to the function.
    ///   - nresults: The number of results expected from the function.
    ///   - state: The Lua state to operate in.
    /// - Returns: True if the call was successful, false otherwise.
    @discardableResult
    public static func protectedCall(
        from state: LuaState,
        nargs: Int32,
        nresults: Int32,
        errorHandler index: Int32? = nil
    ) -> SwiftLuaResult<(), String> {
        let result = lua_pcall(state.state, nargs, nresults, index ?? 0)
        if result == LUA_OK.rawValue {
            return .success(())
        } else {
            if let errorMessage = LuaString.get(from: state, at: -1) {
                Lua.pop(state, 1)
                return .failure(errorMessage)
            } else {
                return .failure("Unknown error")
            }
        }
    }

    /// Check if the value at the given index is a function.
    /// - Parameters:
    ///   - index: The stack index to check.
    ///   - state: The Lua state to check in.
    /// - Returns: True if the value is a function, false otherwise.
    public static func isFunction(at index: Int32, in state: LuaState) -> Bool {
        LuaType.get(from: state, at: index) == .function
    }
}
