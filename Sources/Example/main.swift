import AppKit
import Luau

class AppDelegate: NSObject, NSApplicationDelegate {
    var state: LuaState
    var table: LuaTable

    init(state: LuaState, luaAppTable: LuaTable) {
        self.state = state
        self.table = luaAppTable
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        let function = table.get(LuaFunction.self, key: "applicationDidFinishLaunching")
        if let function = function {
            let result = function.protectedCall(arguments: [], nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationDidFinishLaunching: \(error ?? "unknown error")")
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        let function = table.get(LuaFunction.self, key: "applicationWillTerminate")
        if let function = function {
            let result = function.protectedCall(arguments: [], nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationWillTerminate: \(error ?? "unknown error")")
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        let function = table.get(
            LuaFunction.self,
            key: "applicationShouldTerminateAfterLastWindowClosed"
        )
        if let function = function {
            let result = function.protectedCall(arguments: [], nresults: 1)
            if case let .failure(error) = result {
                print(
                    "Error calling applicationShouldTerminateAfterLastWindowClosed: \(error ?? "unknown error")"
                )
                return false
            }
            return LuaBoolean.get(from: state, at: -1).toBoolConverting()
        }
        return false
    }
}

private final class LuaImports: Sendable {
    static let shared = LuaImports()
    let importTable: [String: @Sendable (LuaState) -> Bool] = [
        "NSAlert": LuaNSAlert.register
    ]

    private init() {}
}

private func lua_import(_ state: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: state) else { return 0 }

    let arguments = SwiftLuaArgument.create(from: state, count: 1)
    let moduleName = arguments[0].toString()

    if let importFunction = LuaImports.shared.importTable[moduleName] {
        if importFunction(state) {
            return 1
        } else {
            // LuaString.push("Failed to import module \(moduleName)", to: state)
            Lua.error(state, data: "Failed to import module \(moduleName)")
        }
    } else {
        Lua.error(state, data: "Unknown module \(moduleName)")
    }
}

private func lua_print(_ state: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: state) else { return 0 }

    let args = SwiftLuaArgument.create(from: state, count: -1)
    print("[Lua] ", terminator: "")
    var first = true
    for arg in args {
        if !first {
            print("\t", terminator: "")
        }
        first = false
        print(arg.toStringConverting(), terminator: "")
    }
    print()

    return 0
}

guard let state = LuaState.create() else {
    fatalError("Failed to create Luau state")
}

state.setGlobal(
    key: "import",
    to: LuaFunction.create(debugName: "import", function: lua_import, in: state)
)
state.setGlobal(
    key: "print",
    to: LuaFunction.create(debugName: "print", function: lua_print, in: state)
)
state.enableSandbox()

// Load lua app from resources
guard let luaAppURL = Bundle.module.url(forResource: "luaApp", withExtension: "luau"),
    let luaAppData = try? Data(contentsOf: luaAppURL)
else {
    fatalError("Failed to load app.luau from resources")
}
guard let luaAppSource = String(data: luaAppData, encoding: .utf8) else {
    fatalError("Failed to decode app.luau as UTF-8")
}

guard let bytecode = LuaBytecode.compile(source: luaAppSource) else {
    fatalError("Failed to compile lua app")
}

let loadResult = state.load(chunkName: "=luaApp.luau", bytecode: bytecode)
guard case .success = loadResult else {
    if case let .failure(error) = loadResult {
        fatalError("Failed to load lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

let ref = LuaRef.store(-1, in: state)
let function = LuaFunction(reference: ref)
let callResult = function.protectedCall(arguments: [], nresults: 1)
// Get the returned value, which should be a table
guard case .success = callResult else {
    if case let .failure(error) = callResult {
        fatalError("Failed to run lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to run lua app: unknown error")
    }
}

// Get the returned value, which should be a table
guard let table = LuaTable.get(from: state, at: -1) else {
    fatalError("Lua app did not return a table")
}

let delegate = AppDelegate(state: state, luaAppTable: table)
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
