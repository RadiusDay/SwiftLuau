import AppKit
import Luau

public enum LuaNSAlert {
    public static let objectKey = Tag()
    public static let key = Tag()

    public static func getNSAlert(_ state: LuaState, table: LuaTable) -> NSAlert? {
        let data = table.get(LuaUserdata.self, key: LuaLightUserdata(pointer: key.getAddress()))
        guard let pointer = data?.toPointer() else {
            return nil
        }
        guard let box = RefBox<NSAlert>.fromLua(pointer) else {
            return nil
        }
        return box.get()
    }

    @MainActor private static func new(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        let arguments = LuaArgumentHandler.create(from: state, count: 1)

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
        let alert = NSAlert()
        let userdata = RefBox(alert)
        alertTable.set(
            key: LuaLightUserdata(pointer: key.getAddress()),
            to: userdata.toLua(in: state)
        )

        alertTable.setMetaTable(classTable)
        alertTable.push(to: state)

        return 1
    }

    @MainActor private static func setMessageText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        let arguments = LuaArgumentHandler.create(from: state, count: 2)
        let alertTable = arguments[0].toTable()
        let messageText = arguments[1].toString()

        guard let alert = getNSAlert(state, table: alertTable) else {
            Lua.error(state, data: "Expected NSAlert in #1")
        }
        alert.messageText = messageText

        return 0
    }

    @MainActor private static func setInformativeText(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        let arguments = LuaArgumentHandler.create(from: state, count: 2)
        let alertTable = arguments[0].toTable()
        let messageText = arguments[1].toString()

        guard let alert = getNSAlert(state, table: alertTable) else {
            Lua.error(state, data: "Expected NSAlert in #1")
        }
        alert.informativeText = messageText

        return 0
    }

    @MainActor private static func runModal(_ state: OpaquePointer?) -> Int32 {
        guard let state = LuaState.from(optional: state) else { return 0 }

        let arguments = LuaArgumentHandler.create(from: state, count: 1)
        let alertTable = arguments[0].toTable()

        guard let alert = getNSAlert(state, table: alertTable) else {
            Lua.error(state, data: "Expected NSAlert in #1")
        }

        Int32(alert.runModal().rawValue).push(to: state)
        return 1
    }

    private static func assumeIsolated(
        _ function: @escaping @MainActor (OpaquePointer?) -> Int32
    ) -> (OpaquePointer?) -> Int32 {
        class UncheckedBox<Type>: @unchecked Sendable {
            public let data: Type

            init(data: Type) {
                self.data = data
            }
        }
        return { state in
            let box = UncheckedBox(data: state)
            return MainActor.assumeIsolated {
                function(box.data)
            }
        }
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
                function: { state in LuaNSAlert.assumeIsolated({ LuaNSAlert.new($0) })(state) },
                in: state
            )
        )
        table.set(
            key: "setMessageText",
            to: LuaFunction.create(
                debugName: "NSAlert:setMessageText",
                function: { state in
                    LuaNSAlert.assumeIsolated({ LuaNSAlert.setMessageText($0) })(state)
                },
                in: state
            )
        )
        table.set(
            key: "setInformativeText",
            to: LuaFunction.create(
                debugName: "NSAlert:setInformativeText",
                function: { state in
                    LuaNSAlert.assumeIsolated({ LuaNSAlert.setInformativeText($0) })(state)
                },
                in: state
            )
        )
        table.set(
            key: "runModal",
            to: LuaFunction.create(
                debugName: "NSAlert:runModal",
                function: { state in LuaNSAlert.assumeIsolated({ LuaNSAlert.runModal($0) })(state)
                },
                in: state
            )
        )

        // Push the table to the stack
        table.push(to: state)

        return true
    }
}
