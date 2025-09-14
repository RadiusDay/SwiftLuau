import CoreFoundation
import SwiftLuauBindings

/// A compiled Lua bytecode chunk.
/// Note: Compiled bytecode doesn't mean that it is free of syntax errors.
public final class LuaBytecode {
    /// The size of the bytecode in bytes.
    internal let size: size_t
    /// The raw bytecode data.
    internal let data: UnsafeMutablePointer<CChar>

    /// Create a LuaBytecode from size and data.
    /// - Parameters:
    ///   - size: The size of the bytecode in bytes.
    ///   - data: The raw bytecode data.
    private init(size: size_t, data: UnsafeMutablePointer<CChar>) {
        self.size = size
        self.data = data
    }

    /// Deallocate the bytecode data when the LuaBytecode is deinitialized.
    deinit {
        data.deallocate()
    }

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

        return LuaBytecode(size: bytecodeSize, data: bytecodeData)
    }
}
