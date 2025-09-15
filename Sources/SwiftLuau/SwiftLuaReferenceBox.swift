import Foundation

/// A box that holds a reference to a Swift object, allowing it to be passed to Lua as userdata.
public struct SwiftLuaReferenceBox<T: AnyObject> {
    /// The retained pointer to the Swift object.
    public let pointer: UnsafeRawPointer

    /// Create a ReferenceBox that retains the given object.
    /// - Parameter value: The object to retain.
    public init(_ value: T) {
        // Retain the object and store its pointer
        let unmanaged = Unmanaged.passRetained(value)
        self.pointer = UnsafeRawPointer(unmanaged.toOpaque())
    }

    /// Initalize from a retained pointer.
    /// - Parameter retainedPointer: A pointer to a retained object.
    private init(retainedPointer: UnsafeRawPointer) {
        self.pointer = retainedPointer
    }

    /// Reconstruct a ReferenceBox from raw bytes.
    /// - Parameter bytes: The raw bytes representing the pointer.
    /// - Returns: A ReferenceBox if the bytes are valid, otherwise nil.
    public static func fromBytes(_ bytes: [UInt8]) -> SwiftLuaReferenceBox<T>? {
        guard bytes.count == MemoryLayout<UnsafeRawPointer>.size else { return nil }
        let ptr = bytes.withUnsafeBytes { $0.load(as: UnsafeRawPointer.self) }
        return SwiftLuaReferenceBox<T>(retainedPointer: ptr)
    }

    /// Get the object without changing its reference count.
    public func get() -> T {
        return Unmanaged<T>.fromOpaque(pointer).takeUnretainedValue()
    }

    /// Release the retained object.
    ///
    /// You should not call this. Use the `toLua` function to transfer ownership to Lua instead.
    /// Lua will call this when the userdata is garbage collected.
    public func release() {
        Unmanaged<T>.fromOpaque(pointer).release()
    }

    /// Convert the ReferenceBox to raw bytes for storage in Lua userdata.
    ///
    /// You should not call this. Use the `toLua` function to push to Lua instead.
    ///
    /// - Returns: The raw bytes representing the pointer.
    public func toBytes() -> [UInt8] {
        // Convert pointer to bytes for storage
        var ptr = pointer
        return withUnsafeBytes(of: &ptr) { Array($0) }
    }

    /// Convert the ReferenceBox to Lua userdata, transferring ownership to Lua.
    /// - Returns: A LuaUserdata containing the ReferenceBox.
    public func toLua() -> LuaUserdata {
        let bytes = toBytes()
        let deallocater: @convention(c) (UnsafeMutableRawPointer?) -> Void = { ptr in
            guard let ptr = ptr else { return }

            // Get the bytes back from the pointer
            let byteBuffer = UnsafeBufferPointer<UInt8>(
                start: ptr.assumingMemoryBound(to: UInt8.self),
                count: MemoryLayout<UnsafeRawPointer>.size
            )
            let bytes = Array(byteBuffer)
            if let box = SwiftLuaReferenceBox<AnyObject>.fromBytes(bytes) {
                box.release()
            }
        }
        let userdata = LuaUserdata(buffer: bytes, deallocater: deallocater)
        return userdata
    }

    /// From Lua userdata.
    /// - Parameter userdata: The LuaUserdata to extract the ReferenceBox from.
    /// - Returns: A ReferenceBox if the userdata is valid, otherwise nil.
    public static func fromLua(_ userdata: UnsafeMutableRawPointer?) -> SwiftLuaReferenceBox<T>? {
        guard let userdata = userdata else { return nil }

        // Get the bytes back from the pointer
        let byteBuffer = UnsafeBufferPointer<UInt8>(
            start: userdata.assumingMemoryBound(to: UInt8.self),
            count: MemoryLayout<UnsafeRawPointer>.size
        )
        let bytes = Array(byteBuffer)
        return SwiftLuaReferenceBox<T>.fromBytes(bytes)
    }
}
