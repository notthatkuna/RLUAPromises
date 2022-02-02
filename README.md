# RLUAPromises
My attempt at creating promises in Roblox Lua

# RLUAPromises V2 is now out!

RLUAPromises V2 is better for syntax and has less functions for ease of use. Find it in promiseV2.lua.

EXAMPLE SCRIPT OF V2:
```lua
local promise = require(script.Parent.promise)

print(Promise(function()
	-- New module utilized the SETFENV function, so now you don't have to declare any upper-scope variables to resolve itself.
	task.wait(1)
	CurrentPromise.resolve()
end).finally(function(...)
	print(...) -- If resolved, prints ReturnState<bool>, otherwise prints Tuple( ReturnState<bool>, Message<string> )
end).Active) -- prints TRUE because the promise has not been resolved/rejected yet (Promise.Active<bool>)

-- The ".finally()" function will return the PROMISE table each time it is called, so you can stack functions on top of each-other or reference variables just like in JavaScript!
```

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

p1._then_(function()
	print("This is an easier way to generally tell if a promise has been completed (not specifically resolved or rejected, just completed")
end,math.huge) -- timeout is math.huge

p1.execute()
```

Main module script is held in promise.lua

# Documentation

# V2

## <Function> PromiseModule(PromiseFunction<function>) -> PromiseTable

  ### Important note: "CurrentPromise" is a variable set at the function's top level scope, so there is no need to declare any variables!
	
  ### <Function> PromiseTable.finally(FinalFunction<function>) -> PromiseTable ( inherited from PromiseModule<function>() )
	
  Function is called when the PromiseFunction either calls ``PromiseTable.resolve()`` or ``PromiseTable.reject(message<string>)``
	
  ### <Function> PromiseTable.resolve() -> PromiseTable ( inherited from PromiseModule<function>() )
	
  Resolves the promise and yields the internal coroutine

  ### <Function> PromiseTable.reject(message<string>) -> PromiseTable ( inherited from PromiseModule<function>() )
	
  Rejects the promise and yields the internal coroutine

## <Object> PromiseModule
  
  ### <Object> PromiseModule.new()
  
  Returns a new promise object
  
  ### <Function> PromiseModule.resolveAll(string reason, boolean usepcall)
  
  Resolves all promise objects that were created for this module, even if they are unresolved. Set ``usepcall`` to true if you want to ignore errors from setting resolved/rejected promises' states. This will also make the function return a table which contains every error received in the pcall function. **This function is very buggy and should not be used. The reason there is no Promise.rejectAll() is because the resolved/rejected event for each promise fires with the number of promises that exist. For example, if there are 3 promises created by this module, then each promise's .resolved event will be fired 3 times each.**
	
  ### <Function> PromiseModule.discontinue(string reason) -> <Table>discontinue_log
	
  Rejects all alive promises and stops new promises from being created, either by PromiseModule.new() or by directly adding it to the table. Also metatable locks the promise table.
  

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
	
  ### <Function> Promise.\_then\_(*function* f, *timeout (seconds)* timeout)
	
  Executes ``f`` after the promise's state is no longer ``unresolved``, meaning either ``resolved`` or ``rejected``. ``timeout`` will not run the function unless the promise's execution time is under ``timeout`` which is in seconds form. I added this for a more general way to tell if a promise has completed without using individual events.
	


# Important notes
* Promise.execute() runs asynchronously from the thread it was called in, meaning your script will not wait for the function inside of .execute() to finish. To avoid this problem, create a variable that changes when the promise's ``resolved/rejected`` events are fired, and ``repeat wait() until $VARIABLE$``
