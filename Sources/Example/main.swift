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
        LuaTable.loadItem(from: state, at: -1, key: "applicationDidFinishLaunching")
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, at: -1, nargs: 0, nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationDidFinishLaunching: \(error)")
            }
        }
    }

    func applicationWillTerminate(_ notification: Notification) {
        ref.push()
        LuaTable.loadItem(from: state, at: -1, key: "applicationWillTerminate")
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, at: -1, nargs: 0, nresults: 0)
            if case let .failure(error) = result {
                print("Error calling applicationWillTerminate: \(error)")
            }
        }
    }

    func applicationShouldTerminateAfterLastWindowClosed(_ sender: NSApplication) -> Bool {
        ref.push()
        LuaTable.loadItem(from: state, at: -1, key: "applicationShouldTerminateAfterLastWindowClosed")
        defer { Lua.pop(state, 1) }
        if LuaFunction.isFunction(at: -1, in: state) {
            let result = LuaFunction.protectedCall(from: state, at: -1, nargs: 0, nresults: 1)
            if case let .failure(error) = result {
                print("Error calling applicationShouldTerminateAfterLastWindowClosed: \(error)")
                return false
            }
            if let shouldTerminate = LuaBoolean.get(from: state, at: -1) {
                Lua.pop(state, 1)
                return shouldTerminate
            } else {
                Lua.pop(state, 1)
                print("Error: applicationShouldTerminateAfterLastWindowClosed did not return a boolean")
                return false
            }
        }
        return false
    }
}

private func lua_alert(_ L: OpaquePointer?) -> Int32 {
    guard let state = LuaState.from(optional: L) else { return 0 }

    if !Thread.isMainThread {
        LuaString.push("alert() must be called from the main thread", to: state)
        Lua.error(state)
        return 0
    }

    // Get the first argument as a string
    guard let message = LuaString.get(from: state, at: 1) else {
        LuaString.push("alert() requires a string argument", to: state)
        Lua.error(state)
        return 0
    }

    // Create and show the alert
    MainActor.assumeIsolated {
        let alert = NSAlert()
        alert.messageText = message
        alert.addButton(withTitle: "OK")
        alert.runModal()
    }

    return 0
}

guard let state = LuaState.create() else {
    fatalError("Failed to create Luau state")
}

LuaFunction.push(LuaFunction(debugName: "alert", function: lua_alert), to: state)
state.setGlobal(name: "alert")

state.enableSandbox()

// Load lua app from resources
guard let luaAppURL = Bundle.module.url(forResource: "luaApp", withExtension: "luau"),
      let luaAppData = try? Data(contentsOf: luaAppURL) else {
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
        fatalError("Failed to load lua app: \(error)")
    } else {
        fatalError("Failed to load lua app: unknown error")
    }
}

let callResult = LuaFunction.protectedCall(from: state, at: 0, nargs: 0, nresults: 1)
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
