# RLUAPromises
My attempt at creating promises in Roblox Lua

Example script:
```lua
local promise = require(script.Parent.promise)

local p1 = promise.new()

p1.setFunction(function() -- setting the function to be executed with the promise
	local partCount = 0
	for _,v in pairs(workspace:GetChildren()) do
		if v.Name == "Part" then
			wait()
			partCount = partCount + 1
			v:Destroy()
		end
	end
	if partCount >= 1 then
		p1.resolve("Destroyed all parts in the workspace") -- resolve promise
	else
		p1.reject("There were no parts in the workspace") -- reject promise
	end
end)

p1.resolved:Connect(function(identification,state)
	print(identification.." was resolved with reason: "..state[2])
end)
p1.rejected:Connect(function(identification,state)
	print(identification.." was rejected with reason: "..state[2])
end)

p1.execute()
print("This print was ran after the .execute(*) function, and it runs asynchronously from eachother because the function assigned to the Promise is wrapped in a spawn(function() end), meaning if you want the promise to work correctly you need to make a variable and discontinue execution until the variable becomes true.")
```

Main module script is held in promise.lua

# Documentation

## <Object> PromiseModule
  
  ### <Object> PromiseModule.new()
  
  Returns a new promise object
  
  ### <Function> PromiseModule.resolveAll(string reason, boolean usepcall)
  
  Resolves all promise objects that were created for this module, even if they are unresolved. Set ``usepcall`` to true if you want to ignore errors from setting resolved/rejected promises' states. This will also make the function return a table which contains every error received in the pcall function. **This function is very buggy and should not be used. The reason there is no Promise.rejectAll() is because the resolved/rejected event for each promise fires with the number of promises that exist. For example, if there are 3 promises created by this module, then each promise's .resolved event will be fired 3 times each.**
  

## <Object> Promise
  
  ### <Event> Promise.resolved * :Connect(function( * **string** identification, **table** state * ) *
  
  Fired when this promise is resolved, identification is the GUID associated with the promise and state is the state (which looks similar to ``{[1]: 'resolved', [2]: 'reason'}``)
  
  ### <Event> Promise.rejected:Connect(function( *string* identification, *table* state )
  
  The same exact thing as ``Promise.resolved`` except it is fired when the promise is rejected
  
  ### <Function> Promise.resolve(*string* reason) -> nil
  
  Resolves the current promise and fires the ``Promise.resolved`` event. This function will error if the promise is not unresolved
  
  ### <Function> Promise.reject(*string* reason) -> nil
  
  Rejects the current promise and fires the ``Promise.rejected`` event. This function will error if the promise is not unresolved
  
  ### <Function> Promise.getstate() -> { [1]: string CurrentState, [2}: string CurrentReason }
  
  Gets the state table of the promise
  
  ### <Function> Promise.setFunction(*function* f) -> nil
  
  Assigns function ``f`` to the promise, required for use of the function ``Promise.execute()``
  
  ### <Function> Promise.execute() -> nil
  
  This function will error if ``Promise.setFunction(f)`` was not used beforehand. Executes the promise's assigned function **in a new thread**
  
  ### <Function> Promise.isUnresolved() -> boolean
  
  If the promise is unresolved, return true, otherwise return false
	


# Important notes
* Promise.execute() runs asynchronously from the thread it was called in, meaning your script will not wait for the function inside of .execute() to finish. To avoid this problem, create a variable that changes when the promise's ``resolved/rejected`` events are fired, and ``repeat wait() until $VARIABLE$``
