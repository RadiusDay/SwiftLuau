import CLua

#if canImport(Foundation)
import Foundation
#endif

/// A compiled Lua bytecode chunk.
/// Note: Compiled bytecode doesn't mean that it is free of syntax errors.
public final class LuaBytecode {
    /// The size of the bytecode in bytes.
    internal let size: size_t
    /// The raw bytecode data.
    internal let data: UnsafeMutablePointer<UInt8>

    /// Create a LuaBytecode from size and data.
    /// - Parameters:
    ///   - size: The size of the bytecode in bytes.
    ///   - data: The raw bytecode data.
    private init(size: size_t, data: UnsafeMutablePointer<UInt8>) {
        self.size = size
        self.data = data
    }

    /// Deallocate the bytecode data when the LuaBytecode is deinitialized.
    deinit {
        data.deallocate()
    }

    /// Create a LuaBytecode from a byte array.
    /// - Parameter bytes: The byte array to create the LuaBytecode from.
    /// - Returns: A LuaBytecode.
    public static func from(bytes: [UInt8]) -> LuaBytecode {
        let data = UnsafeMutablePointer<UInt8>.allocate(capacity: bytes.count)
        data.initialize(from: bytes, count: bytes.count)
        return LuaBytecode(size: bytes.count, data: data)
    }

    #if canImport(Foundation)
    /// Create a LuaBytecode from Data.
    /// - Parameter data: The Data to create the LuaBytecode from.
    /// - Returns: A LuaBytecode.
    public static func from(data: Data) -> LuaBytecode {
        let byteArray = [UInt8](data)
        return LuaBytecode.from(bytes: byteArray)
    }
    #endif

    /// Compile Lua source code into bytecode.
    /// - Parameter source: The Lua source code to compile.
    /// - Returns: A LuaBytecode if compilation was successful, nil otherwise.
    public static func compile(source: String) -> LuaBytecode? {
        var bytecodeSize: size_t = 0
        let utf8 = Array(source.utf8)

        let bytecodeData = utf8.withUnsafeBufferPointer { buffer in
            luau_compile(
                buffer.baseAddress,
                buffer.count,
                nil,
                &bytecodeSize
            )
        }

        guard let bytecodeData = bytecodeData else {
            return nil
        }

        return LuaBytecode(
            size: bytecodeSize,
            data: UnsafeMutableRawPointer(bytecodeData).assumingMemoryBound(to: UInt8.self)
        )
    }

    /// Get the bytecode as a byte array.
    public func toBytes() -> [UInt8] {
        return .init(UnsafeBufferPointer(start: data, count: size))
    }

    #if canImport(Foundation)
    /// Get the bytecode as Data.
    /// - Returns: The bytecode as Data.
    public func toData() -> Data {
        return Data(bytes: data, count: size)
    }
    #endif
}
