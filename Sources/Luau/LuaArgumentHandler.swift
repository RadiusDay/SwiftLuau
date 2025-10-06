/// Utility class to handle Lua function arguments.
public final class LuaArgumentHandler {
    /// Argument index.
    public let index: Int32
    /// The Lua reference.
    public let reference: LuaRef

    /// Private initializer.
    private init(_ index: Int32, reference: LuaRef) {
        self.index = index
        self.reference = reference
    }

    /// Create a SwiftLuaArguments from the Lua stack.
    /// - Parameters:
    ///   - state: The Lua state.
    ///   - argumentCount: The number of arguments to retrieve. Use -1 to get all.
    /// - Returns: An array of SwiftLuaArgument instances.
    public static func create(
        from state: LuaState,
        count argumentCount: Int
    ) -> [LuaArgumentHandler] {
        var args: [LuaArgumentHandler] = []
        let argCount = Lua.getTop(state)
        if argumentCount != -1 && argCount < argumentCount {
            Lua.error(state, data: "Expected at least \(argumentCount) arguments, got \(argCount)")
        }
        for i in 1...argCount {
            let ref = LuaRef.store(i, in: state, remove: false)
            args.append(LuaArgumentHandler(i, reference: ref))
        }
        Lua.pop(state, argCount)
        return args
    }

    /// Convert the argument to a Bool value, converting if necessary.
    /// - Returns: The Bool value.
    public func toBoolConverting() -> Bool {
        let bool = LuaBoolean(reference: reference).toBoolConverting()
        return bool
    }

    /// Convert the argument to a Bool value.
    /// - Returns: The Bool value.
    public func toBool() -> Bool {
        guard let bool = LuaBoolean(reference: reference).toBool() else {
            Lua.error(reference.state, data: "Expected boolean at argument #\(index)")
        }
        return bool
    }

    /// Convert the argument to a LuaBuffer.
    /// - Returns: The LuaBuffer.
    public func toBuffer() -> LuaBuffer {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .buffer {
            Lua.error(reference.state, data: "Expected buffer at argument #\(index)")
        }
        let buffer = LuaBuffer(reference: reference)
        Lua.pop(reference.state, 1)
        return buffer
    }

    /// Convert the argument to function.
    /// - Returns: The LuaFunction.
    public func toFunction() -> LuaFunction {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .function {
            Lua.error(reference.state, data: "Expected function at argument #\(index)")
        }
        let function = LuaFunction(reference: reference)
        Lua.pop(reference.state, 1)
        return function
    }

    /// Convert the argument to light user data.
    /// - Returns: The light user data.
    public func toLightUserData() -> LuaLightUserdata {
        reference.push(to: reference.state)
        let lightUserdata = LuaLightUserdata.get(from: reference.state, at: -1)
        guard let lightUserdata else {
            Lua.error(reference.state, data: "Expected light user data at argument #\(index)")
        }
        Lua.pop(reference.state, 1)
        return lightUserdata
    }

    /// Convert the argument to nil.
    /// - Returns: The LuaNil.
    public func toNil() -> LuaNil {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .nilType {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected nil at argument #\(index)")
        }
        Lua.pop(reference.state, 1)
        let nilValue = LuaNil()
        return nilValue
    }

    /// Convert the argument to number.
    /// - Returns: The LuaNumber.
    public func toNumber() -> LuaNumber {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .number {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected number at argument #\(index)")
        }
        let number = LuaNumber(reference: reference)
        Lua.pop(reference.state, 1)
        return number
    }

    /// Convert the argument to string, converting if necessary.
    /// - Returns: The String.
    public func toStringConverting() -> String {
        let string = LuaString(reference: reference)
        guard let stringValue = string.toStringConverting() else {
            Lua.error(
                reference.state,
                data: "String conversion failed at argument #\(index)"
            )
        }
        return stringValue
    }

    /// Convert the argument to string.
    /// - Returns: The String.
    public func toString() -> String {
        let string = LuaString(reference: reference)
        guard let stringValue = string.toString() else {
            Lua.error(reference.state, data: "Expected string at argument #\(index)")
        }
        return stringValue
    }

    /// Convert the argument to string.
    /// - Returns: The LuaString, note the underlying value may not be a string.
    public func toLuaString() -> LuaString {
        let string = LuaString(reference: reference)
        return string
    }

    /// Convert the argument to table.
    /// - Returns: The LuaTable.
    public func toTable() -> LuaTable {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .table {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected table at argument #\(index)")
        }
        let table = LuaTable(reference: reference)
        Lua.pop(reference.state, 1)
        return table
    }

    /// Convert the argument to thread.
    /// - Returns: The LuaThread.
    public func toThread() -> LuaThread {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .thread {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected thread at argument #\(index)")
        }
        let thread = LuaThread(reference: reference)
        Lua.pop(reference.state, 1)
        return thread
    }

    /// Convert the argument to user data.
    /// - Returns: The LuaUserdata.
    public func toUserdata() -> LuaUserdata {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .userdata {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected userdata at argument #\(index)")
        }
        let userdata = LuaUserdata(reference: reference)
        Lua.pop(reference.state, 1)
        return userdata
    }

    /// Convert the argument to vector.
    /// - Returns: The LuaVector.
    public func toVector() -> LuaVector {
        reference.push(to: reference.state)
        if LuaType.get(from: reference.state, at: -1) != .vector {
            Lua.pop(reference.state, 1)
            Lua.error(reference.state, data: "Expected vector at argument #\(index)")
        }
        let vector = LuaVector(reference: reference)
        Lua.pop(reference.state, 1)
        return vector
    }
}
