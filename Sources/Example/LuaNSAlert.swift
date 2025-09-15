import AppKit
import SwiftLuau

public enum LuaNSAlert {
    public static let key = Tag()

    private static func new(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        // Assert main thread
        if !Thread.isMainThread {
            LuaString.push("NSAlert:new must be called on the main thread", to: state)
            Lua.error(state)
        }

        // Get the first argument, which should be the class table
        guard LuaType.get(from: state, at: 1) == .table else {
            LuaString.push("Expected table as first argument", to: state)
            Lua.error(state)
        }

        // Create a new table
        LuaTable.pushEmpty(to: state)

        // setmetatable(alertTable, classTable)
        Lua.push(state, at: -2)
        LuaTable.setMetatable(in: state, at: -2)

        // alertTable[PTR] = userdata
        LuaLightUserdata.push(
            key.getAddress(),
            to: state
        )
        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            // Create the NSAlert instance
            let alert = NSAlert()
            let userdata = SwiftLuaReferenceBox(alert)
            LuaUserdata.push(userdata.toLua(), to: state)
        }
        LuaTable.setItem(in: state, at: -3)

        return 1
    }

    private static func setMessageText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        // Ensure we are on the UI thread
        if !Thread.isMainThread {
            LuaString.push("NSAlert:setMessageText must be called on the main thread", to: state)
            Lua.error(state)
        }

        // Get the first argument, which should be the alert table
        guard LuaType.get(from: state, at: 1) == .table else {
            LuaString.push("Expected table as first argument", to: state)
            Lua.error(state)
        }

        // Get the second argument, which should be the message text
        guard let messageText = LuaString.get(from: state, at: 2) else {
            LuaString.push("Expected string as second argument", to: state)
            Lua.error(state)
        }

        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            // Get the userdata from the alert table
            LuaLightUserdata.push(
                key.getAddress(),
                to: state
            )
            LuaTable.loadItem(from: state, at: 1)
            let userdata = LuaUserdata.get(from: state, at: -1)
            guard let box = SwiftLuaReferenceBox<NSAlert>.fromLua(userdata) else {
                Lua.setTop(state, 0)
                LuaString.push("Invalid userdata in alert table", to: state)
                Lua.error(state)
            }
            Lua.pop(state, 1)
            let alert = box.get()
            alert.messageText = messageText
        }

        return 0
    }

    private static func setInformativeText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        // Assert main thread
        if !Thread.isMainThread {
            LuaString.push(
                "NSAlert:setInformativeText must be called on the main thread",
                to: state
            )
            Lua.error(state)
        }

        // Get the first argument, which should be the alert table
        guard LuaType.get(from: state, at: 1) == .table else {
            LuaString.push("Expected table as first argument", to: state)
            Lua.error(state)
        }

        // Get the second argument, which should be the informative text
        guard let informativeText = LuaString.get(from: state, at: 2) else {
            LuaString.push("Expected string as second argument", to: state)
            Lua.error(state)
        }

        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            // Get the userdata from the alert table
            LuaLightUserdata.push(
                key.getAddress(),
                to: state
            )
            LuaTable.loadItem(from: state, at: 1)
            let userdata = LuaUserdata.get(from: state, at: -1)
            Lua.pop(state, 1)
            guard let box = SwiftLuaReferenceBox<NSAlert>.fromLua(userdata) else {
                LuaString.push("Invalid userdata in alert table", to: state)
                Lua.error(state)
            }
            let alert = box.get()
            alert.informativeText = informativeText
        }
        return 0
    }

    private static func runModal(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        // Assert main thread
        if !Thread.isMainThread {
            LuaString.push("NSAlert:runModal must be called on the main thread", to: state)
            Lua.error(state)
        }

        // Get the first argument, which should be the alert table
        guard LuaType.get(from: state, at: 1) == .table else {
            LuaString.push("Expected table as first argument", to: state)
            Lua.error(state)
        }

        let sendableState = SendableLuaState.from(state)
        let result = MainActor.assumeIsolated {
            let state = sendableState.take()
            // Get the userdata from the alert table
            LuaLightUserdata.push(
                key.getAddress(),
                to: state
            )
            LuaTable.loadItem(from: state, at: 1)
            let userdata = LuaUserdata.get(from: state, at: -1)
            Lua.pop(state, 1)
            guard let box = SwiftLuaReferenceBox<NSAlert>.fromLua(userdata) else {
                LuaString.push("Invalid userdata in alert table", to: state)
                Lua.error(state)
            }
            let alert = box.get()
            return alert.runModal()
        }

        LuaNumber.push(Int32(result.rawValue), to: state)
        return 1
    }

    public static func register(in state: LuaState) -> Bool {
        LuaTable.pushEmpty(to: state)

        // classTable["__index"] = classTable
        LuaString.push("__index", to: state)
        Lua.push(state, at: -2)  // push classTable again
        LuaTable.setItem(in: state, at: -3)

        // classTable["new"] = function
        LuaString.push("new", to: state)
        LuaFunction.push(
            .init(
                debugName: "NSAlert:new",
                function: { LuaNSAlert.new($0) }
            ),
            to: state
        )
        LuaTable.setItem(in: state, at: -3)

        // classTable["setMessageText"] = function
        LuaString.push("setMessageText", to: state)
        LuaFunction.push(
            .init(
                debugName: "NSAlert:setMessageText",
                function: { LuaNSAlert.setMessageText($0) }
            ),
            to: state
        )
        LuaTable.setItem(in: state, at: -3)

        // classTable["setInformativeText"] = function
        LuaString.push("setInformativeText", to: state)
        LuaFunction.push(
            .init(
                debugName: "NSAlert:setInformativeText",
                function: { LuaNSAlert.setInformativeText($0) }
            ),
            to: state
        )
        LuaTable.setItem(in: state, at: -3)

        // classTable["runModal"] = function
        LuaString.push("runModal", to: state)
        LuaFunction.push(
            .init(
                debugName: "NSAlert:runModal",
                function: { LuaNSAlert.runModal($0) }
            ),
            to: state
        )
        LuaTable.setItem(in: state, at: -3)

        return true
    }
}
