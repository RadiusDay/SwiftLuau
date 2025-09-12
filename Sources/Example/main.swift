import SwiftLuau

func main() {
    guard let luau = LuauState.create() else {
        print("Failed to create Luau state")
        return
    }

    let source = """
        local x = 10
        local y = 20
        local sum = x + y
        print("The sum of "..x.." and "..y.." is "..sum)
        """

    guard let bytecode = LuauBytecode.compile(source: source) else {
        print("Failed to compile Luau source")
        return
    }

    // Load the bytecode into the Luau state
    let loadStatus = luau.load(chunkName: "example", bytecode: bytecode)
    if !loadStatus {
        print("Failed to load Luau bytecode")
        return
    }
    // Call the loaded chunk
    let callStatus = luau.call()
    if !callStatus {
        print("Failed to execute Luau bytecode")
        return
    }
}

main()
