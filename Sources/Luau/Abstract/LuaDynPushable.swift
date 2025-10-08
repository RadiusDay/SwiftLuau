#if hasFeature(Embedded)
/// A struct that implements type erasure for LuaPushable.
public struct LuaDynPushable {
    private struct FunctionPointers {
        let push: (LuaState) -> Void
    }
    private let functionPointers: FunctionPointers
    init<T: LuaPushable>(_ value: T) {
        functionPointers = FunctionPointers(
            push: { state in value.push(to: state) }
        )
    }

    func push(to state: LuaState) {
        functionPointers.push(state)
    }
}
#endif
