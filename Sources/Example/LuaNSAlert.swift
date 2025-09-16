import AppKit
import SwiftLuau

public enum LuaNSAlert {
    public static let objectKey = Tag()
    public static let key = Tag()

    private static func assertMainThread(_ state: LuaState) {
        if !Thread.isMainThread {
            Lua.error(state, data: "NSAlert methods must be called on the main thread")
        }
    }

    public static func getNSAlert(_ state: LuaState, table: LuaTable) -> NSAlert? {
        let data = table.get(LuaUserdata.self, key: LuaLightUserdata(pointer: key.getAddress()))
        guard let pointer = data?.toPointer() else {
            return nil
        }
        guard let box = SwiftLuaReferenceBox<NSAlert>.fromLua(pointer) else {
            return nil
        }
        return box.get()
    }

    private static func new(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }
        assertMainThread(state)

        let arguments = SwiftLuaArgument.create(from: state, count: 1)

        // Get the class table
        let classTable = arguments[0].toTable()
        let classTableValid = classTable.get(
            LuaBoolean.self,
            key: LuaLightUserdata(pointer: objectKey.getAddress())
        )
        if classTableValid.toBool() != true {
            Lua.error(state, data: "Expected NSAlert classTable in #1")
        }

        let alertTable = LuaTable.create(in: state)
        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            let alert = NSAlert()
            let userdata = SwiftLuaReferenceBox(alert)
            alertTable.set(
                key: LuaLightUserdata(pointer: key.getAddress()),
                to: userdata.toLua(in: state)
            )
        }
        alertTable.setMetaTable(classTable)
        alertTable.push(to: state)

        return 1
    }

    private static func setMessageText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }
        assertMainThread(state)

        let arguments = SwiftLuaArgument.create(from: state, count: 2)
        let alertTable = arguments[0].toTable()
        let messageText = arguments[1].toString()

        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            guard let alert = getNSAlert(state, table: alertTable) else {
                Lua.error(state, data: "Expected NSAlert in #1")
            }
            alert.messageText = messageText
        }

        return 0
    }

    private static func setInformativeText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }
        assertMainThread(state)

        let arguments = SwiftLuaArgument.create(from: state, count: 2)
        let alertTable = arguments[0].toTable()
        let messageText = arguments[1].toString()

        let sendableState = SendableLuaState.from(state)
        MainActor.assumeIsolated {
            let state = sendableState.take()
            guard let alert = getNSAlert(state, table: alertTable) else {
                Lua.error(state, data: "Expected NSAlert in #1")
            }
            alert.informativeText = messageText
        }

        return 0
    }

    private static func runModal(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }
        assertMainThread(state)

        let arguments = SwiftLuaArgument.create(from: state, count: 1)
        let alertTable = arguments[0].toTable()

        let sendableState = SendableLuaState.from(state)
        let result = MainActor.assumeIsolated {
            let state = sendableState.take()
            guard let alert = getNSAlert(state, table: alertTable) else {
                Lua.error(state, data: "Expected NSAlert in #1")
            }
            return alert.runModal()
        }

        let number = LuaNumber.create(Int32(result.rawValue), in: state)
        number.push(to: state)
        return 1
    }

    public static func register(in state: LuaState) -> Bool {
        let table = LuaTable.create(in: state)
        table.set(key: LuaLightUserdata(pointer: objectKey.getAddress()), to: true)

        // classTable["__index"] = classTable
        table.set(key: "__index", to: table)

        // Add the functions
        table.set(
            key: "new",
            to: LuaFunction.create(
                debugName: "NSAlert:new",
                function: { LuaNSAlert.new($0) },
                in: state
            )
        )
        table.set(
            key: "setMessageText",
            to: LuaFunction.create(
                debugName: "NSAlert:setMessageText",
                function: { LuaNSAlert.setMessageText($0) },
                in: state
            )
        )
        table.set(
            key: "setInformativeText",
            to: LuaFunction.create(
                debugName: "NSAlert:setInformativeText",
                function: { LuaNSAlert.setInformativeText($0) },
                in: state
            )
        )
        table.set(
            key: "runModal",
            to: LuaFunction.create(
                debugName: "NSAlert:runModal",
                function: { LuaNSAlert.runModal($0) },
                in: state
            )
        )

        // Push the table to the stack
        table.push(to: state)

        return true
    }
}
