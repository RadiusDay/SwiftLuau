local AppDelegate = {}
AppDelegate.__index = AppDelegate

function AppDelegate:new()
    local newObj = {}
    self.__index = self
    return setmetatable(newObj, self)
end

function AppDelegate:applicationDidFinishLaunching()
    local answerToLife = 42
    alert("The answer to life, the universe, and everything is " .. answerToLife)
end

function AppDelegate:applicationWillTerminate()
    alert("Goodbye from Luau!")
end

function AppDelegate:applicationShouldTerminateAfterLastWindowClosed()
    return true
end

return AppDelegate:new()
