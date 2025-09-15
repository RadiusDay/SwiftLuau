import AppKit
import SwiftLuau

class AppDelegate: NSObject, NSApplicationDelegate {
    var state: LuaState
    var ref: LuaRef

    init(state: LuaState) {
        self.state = state
        self.ref = LuaRef.store(-1, in: state)
    }

    func applicationDidFinishLaunching(_ notification: Notification) {
        ref.push()
        LuaString.push("applicationDidFinishLaunching", to: state)
        LuaTable.loadItem(from: state, at: -2)
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, nargs: 0, nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationDidFinishLaunching: \(error)")
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        ref.push()
        LuaString.push("applicationWillTerminate", to: state)
        LuaTable.loadItem(from: state, at: -2)
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, nargs: 0, nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationWillTerminate: \(error)")
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        ref.push()
        LuaString.push("applicationShouldTerminateAfterLastWindowClosed", to: state)
        LuaTable.loadItem(from: state, at: -2)
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, nargs: 0, nresults: 1)
            if case let .failure(error) = result {
                print("Error calling applicationShouldTerminateAfterLastWindowClosed: \(error)")
                return false
            }
            if let shouldTerminate = LuaBoolean.get(from: state, at: -1) {
                Lua.pop(state, 1)
                return shouldTerminate
            } else {
                Lua.pop(state, 1)
                print(
                    "Error: applicationShouldTerminateAfterLastWindowClosed did not return a boolean"
                )
                return false
            }
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

private func lua_import(_ L: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: L) else { return 0 }

    // Get the module name from the first argument
    guard let moduleName = LuaString.get(from: state, at: 1) else {
        LuaString.push("Expected string as first argument", to: state)
        Lua.error(state)
    }

    if let importFunction = LuaImports.shared.importTable[moduleName] {
        if importFunction(state) {
            return 1
        } else {
            LuaString.push("Failed to import module \(moduleName)", to: state)
            Lua.error(state)
        }
    } else {
        LuaString.push("Module \(moduleName) not found", to: state)
        Lua.error(state)
    }
}

guard let state = LuaState.create() else {
    fatalError("Failed to create Luau state")
}

LuaFunction.push(LuaFunction(debugName: "import", function: lua_import), to: state)
state.setGlobal(name: "import")

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

let loadResult = state.load(chunkName: "luaApp", bytecode: bytecode)
guard case .success = loadResult else {
    if case let .failure(error) = loadResult {
        fatalError("Failed to load lua app: \(error ?? "unknown error")")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

let callResult = LuaFunction.protectedCall(from: state, nargs: 0, nresults: 1)
guard case .success = callResult else {
    if case let .failure(error) = callResult {
        fatalError("Failed to run lua app: \(error)")
    } else {
        fatalError("Failed to run lua app: unknown error")
    }
}

let delegate = AppDelegate(state: state)
NSApplication.shared.delegate = delegate
_ = NSApplicationMain(CommandLine.argc, CommandLine.unsafeArgv)
