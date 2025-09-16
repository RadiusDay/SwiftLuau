local NSAlert = import("NSAlert")

local AppDelegate = {}
AppDelegate.__index = AppDelegate

function AppDelegate:new()
    local newObj = {}
    return setmetatable(newObj, self)
end

function AppDelegate:applicationDidFinishLaunching()
    print("Application did finish launching")
    local alert = NSAlert:new()
    alert:setMessageText("Hello from Luau!")
    alert:setInformativeText("This is a simple alert from the Luau application.")
    local result = alert:runModal()
    print(`Alert result: {result}`)
end

function AppDelegate:applicationWillTerminate()
    print("Application will terminate")
end

function AppDelegate:applicationShouldTerminateAfterLastWindowClosed()
    return true
end

return AppDelegate:new()
