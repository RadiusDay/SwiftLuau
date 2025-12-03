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

private func lua_require(_ state: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: state) else { return 0 }

    let args = LuaValue.parseArgs(from: state, count: 1)
    let moduleName = args[0].toString()

    switch moduleName {
    case "swiftLuau.example":
        let table = LuaTable.create(in: state)
        table.set(
            key: "getPlatform",
            to: LuaFunction.create(
                debugName: "example.getPlatform",
                function: lua_getPlatform,
                in: state
            )
        )
        table.setReadOnly(true)
        table.push(to: state)
        return 1
    default:
        Lua.error(state, data: "Module '\(moduleName)' not found")
    }
}

func main() {
    guard let state = LuaState.create() else {
        print("Failed to create Lua state")
        fatalError()
    }

    state.setGlobal(
        key: "require",
        to: LuaFunction.create(debugName: "require", function: lua_require, in: state)
    )
    state.setGlobal(
        key: "print",
        to: LuaFunction.create(debugName: "print", function: lua_print, in: state)
    )
    state.enableSandbox()

    // Load lua app from resources
    let luaAppSource = """
        local example = require("swiftLuau.example")

        print(`Hello from Luau on {example.getPlatform()}`)

        local status, err = pcall(function()
            example.test = 123
        end)
        if status then
            print("Modified read-only table successfully, which is unexpected")
        else
            print("Task failed successfully: " .. err)
        end

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
        print("Failed to compile lua app")
        fatalError()
    }

    let loadResult = state.load(chunkName: "=luaApp.luau", bytecode: bytecode)
    guard case .success(let function) = loadResult else {
        if case let .failure(error) = loadResult {
            print("Failed to load lua app: \(error.message ?? "unknown error")")
        } else {
            print("Failed to load lua app: unknown error")
        }
        fatalError()
    }

    let callResult = function.protectedCall(arguments: [])
    // Get the returned value, which should be a table
    guard case .success(let returnValues) = callResult else {
        if case let .failure(error) = callResult {
            print("Failed to run lua app: \(error.message ?? "unknown error")")
        } else {
            print("Failed to run lua app: unknown error")
        }
        fatalError()
    }

    print(
        "Lua app ran successfully; return values are: [\(returnValues.map { $0.toStringConverting() }.joined(separator: ", "))]"
    )
}

main()
