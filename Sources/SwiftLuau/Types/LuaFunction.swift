import SwiftLuauBindings

/// Representation of a Lua function.
public struct LuaFunction: Sendable, LuaPushable, LuaGettable {
    /// The reference to the Lua function.
    public let reference: LuaRef

    /// Initialize a LuaFunction with a LuaRef.
    /// - Parameter reference: The LuaRef to initialize the function with.
    public init(reference: LuaRef) {
        self.reference = reference
    }

    /// Create a LuaFunction from a function.
    /// - Parameters:
    ///   - debugName: An optional debug name for the function.
    ///   - function: The Swift function to wrap.
    /// - Returns: A LuaFunction wrapping the provided Swift function.
    public static func create(
        debugName: String? = nil,
        function: @escaping @convention(c) (OpaquePointer?) -> Int32,
        in state: LuaState
    ) -> LuaFunction {
        lua_pushcclosurek(state.state, function, debugName, 0, nil)
        let ref = LuaRef.store(-1, in: state)
        return LuaFunction(reference: ref)
    }

    /// Push the Lua function onto the Lua stack.
    /// - Parameter state: The Lua state to push the function to.
    public func push(to state: LuaState) {
        reference.push(to: state)
    }

    /// Get a Lua function from the Lua stack at the given index.
    /// - Parameters:
    ///   - index: The stack index to get the value from.
    ///   - state: The Lua state to get the value from.
    /// - Returns: The LuaFunction if it exists and is a function, nil otherwise.
    public static func get(from state: LuaState, at index: Int32) -> LuaFunction? {
        if LuaType.get(from: state, at: index) != .function {
            return nil
        }
        let ref = LuaRef.store(index, in: state)
        return LuaFunction(reference: ref)
    }

    /// Perform a protected call to a Lua function.
    /// - Parameters:
    ///   - nargs: The number of arguments to pass to the function.
    ///   - nresults: The number of results expected from the function.
    ///   - errorHandler: An optional stack index of an error handler function.
    /// - Returns: A SwiftLuaResult indicating success or failure.
    @discardableResult
    public func protectedCall(
        arguments: [LuaPushable],
        nresults: Int32,
        errorHandler: LuaFunction? = nil,
    ) -> SwiftLuaResult<(), String?> {
        let state = reference.state.take()
        let nargs = Int32(arguments.count)
        var errFuncIndex: Int32 = 0

        if let errorHandler = errorHandler {
            errorHandler.push(to: state)
            // After pushing error handler, it will be at -(nargs + 1) after all pushes
            errFuncIndex = -(nargs + 1)
        }

        // Push the function to call
        push(to: state)
        // Push arguments
        for argument in arguments {
            argument.push(to: state)
        }

        let result = lua_pcall(state.state, nargs, nresults, errFuncIndex)
        if result == LUA_OK.rawValue {
            return .success(())
        } else {
            let errorMessage = LuaString.get(from: state, at: -1)
            Lua.pop(state, 1)
            return .failure(errorMessage.toStringConverting())
        }
    }
}
