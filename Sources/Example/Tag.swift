public class Tag: @unchecked Sendable {
    public var value: UInt8 = 0

    public init() {}

    public func getAddress() -> UnsafeMutableRawPointer {
        return UnsafeMutableRawPointer(Unmanaged.passUnretained(self).toOpaque())
    }
}
