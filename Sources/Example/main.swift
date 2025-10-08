// import AppKit
import Luau

print("Starting Luau example app...")

private func lua_getPlatform(_ state: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: state) else { return 0 }

    let _ = LuaValue.parseArgs(from: state, count: 0)

    #if os(macOS)
    "macOS".push(to: state)
    #elseif os(iOS)
    "iOS".push(to: state)
    #elseif os(tvOS)
    "tvOS".push(to: state)
    #elseif os(watchOS)
    "watchOS".push(to: state)
    #elseif os(visionOS)
    "visionOS".push(to: state)
    #elseif os(Linux)
    "Linux".push(to: state)
    #elseif os(Windows)
    "Windows".push(to: state)
    #else
    "Unknown".push(to: state)
    #endif

    return 1
}

private func lua_print(_ state: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: state) else { return 0 }

    let args = LuaValue.parseArgs(from: state, count: -1)
    print("[Lua] ", terminator: "")
    var first = true
    for arg in args {
        if !first {
            print("\t", terminator: "")
        }
        first = false
        print(arg.toStringConverting(), terminator: "")
    }
    print("")

    return 0
}

func main() {
    guard let state = LuaState.create() else {
        fatalError("Failed to create Luau state")
    }

    state.setGlobal(
        key: "getPlatform",
        to: LuaFunction.create(debugName: "getPlatform", function: lua_getPlatform, in: state)
    )
    state.setGlobal(
        key: "print",
        to: LuaFunction.create(debugName: "print", function: lua_print, in: state)
    )
    state.enableSandbox()

    // Load lua app from resources
    let luaAppSource = """
        print(`Hello from Luau on {getPlatform()}`)

        local function factorial(n)
            if n == 0 then
                return 1
            else
                return n * factorial(n - 1)
            end
        end

        return factorial(5)
        """

    guard let bytecode = LuaBytecode.compile(source: luaAppSource) else {
        fatalError("Failed to compile lua app")
    }

    let loadResult = state.load(chunkName: "=luaApp.luau", bytecode: bytecode)
    guard case .success(let function) = loadResult else {
        if case let .failure(error) = loadResult {
            fatalError("Failed to load lua app: \(error.message ?? "unknown error")")
        } else {
            fatalError("Failed to load lua app: unknown error")
        }
    }

    let callResult = function.protectedCall(arguments: [])
    // Get the returned value, which should be a table
    guard case .success(let returnValues) = callResult else {
        if case let .failure(error) = callResult {
            fatalError("Failed to run lua app: \(error.message ?? "unknown error")")
        } else {
            fatalError("Failed to run lua app: unknown error")
        }
    }

    print(
        "Lua app ran successfully; return values are: [\(returnValues.map { $0.toStringConverting() }.joined(separator: ", "))]"
    )
}

main()
