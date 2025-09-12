import SwiftLuauBindings

public final class LuauState {
    internal var state: OpaquePointer

    private init(state: OpaquePointer) {
        self.state = state
        luaL_openlibs(state)
    }

    deinit {
        lua_close(state)
    }

    /// Create a new Luau state.
    public static func create(openLibs: Bool = true) -> LuauState? {
        guard let L = luaL_newstate() else {
            return nil
        }
        let luauState = LuauState(state: L)
        if openLibs {
            luaL_openlibs(L)
        }
        return luauState
    }

    /// Load luau bytecode into the state.
    public func load(chunkName: String, bytecode: LuauBytecode) -> Bool {
        let result = luau_load(state, chunkName, bytecode.data, bytecode.size, 0)
        return result == 0
    }

    /// Call the loaded chunk.
    public func call(nArgs: Int32 = 0, nResults: Int32 = LUA_MULTRET) -> Bool {
        let result = lua_pcall(state, nArgs, nResults, 0)
        return result == 0
    }
}

public final class LuauBytecode {
    internal let size: size_t
    internal let data: UnsafeMutablePointer<CChar>

    private init(size: size_t, data: UnsafeMutablePointer<CChar>) {
        self.size = size
        self.data = data
    }

    deinit {
        data.deallocate()
    }

    public static func compile(source: String) -> LuauBytecode? {
        var bytecodeSize: size_t = 0
        let utf8 = Array(source.utf8)

        let bytecodeData = utf8.withUnsafeBufferPointer { buffer in
            luau_compile(
                buffer.baseAddress,
                buffer.count,
                nil,
                &bytecodeSize
            )
        }

        guard let data = bytecodeData else {
            return nil
        }

        return LuauBytecode(size: bytecodeSize, data: data)
    }
}
