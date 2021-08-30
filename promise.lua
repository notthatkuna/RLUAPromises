-- created by lanjt#2129 on Discord
-- github: https://raw.githubusercontent.com/notthatkuna/RLUAPromises/main/promise.lua

local promise = {}
local all = {}

if not game.ServerScriptService:FindFirstChild("promiseFolder") then
	local pf = Instance.new("Folder",game:GetService("ServerScriptService"))
	pf.Name = "promiseFolder"
	local ev1 = Instance.new("BindableEvent",pf)
	ev1.Name = "rejected"
	local ev2 = Instance.new("BindableEvent", pf)
	ev2.Name = "resolved"
end

function promise.discontinue(reason)
	-- When disallowing new promises to be made, use __newindex to detect when a change to the ``all`` table has been made
	local disclog = {}
	local OK = true
	disclog.rejectedPromises = {}
	for _,cPromise in pairs(all) do -- set all promises's status to rejected
		if cPromise.isUnresolved() == true then
			table.insert(disclog.rejectedPromises,cPromise.identification)
			cPromise.reject("Terminated by discontinuation of master script with reason: "..tostring(reason))
		end
	end
	-- make sure no new promises are made
	all = setmetatable(all,{
		__newindex = function(self,i,v)
			rawset(self,i,v)
			v.reject("Creation rejected: master script has discontinued this module with reason: "..reason)
		end,
		__metatable = nil, -- dont let rawset()/rawget() be used on the all table
	})
	return disclog -- return the discontinue log as a table
end

function promise.new()
	local newpromise = {}
	newpromise.db = false
	newpromise.state = {'unresolved', ''}
	newpromise.identification = game:GetService("HttpService"):GenerateGUID(true);
	newpromise._function = nil
	local _resolved = game:GetService("ServerScriptService").promiseFolder.resolved
	local _rejected = game:GetService("ServerScriptService").promiseFolder.rejected
	newpromise.resolved = game:GetService("ServerScriptService").promiseFolder.resolved.Event
	newpromise.rejected = game:GetService("ServerScriptService").promiseFolder.rejected.Event
	local idCopy = newpromise.identification

	local function nError(message)
		error("\nError generated by <Promise>#"..newpromise.identification.."\n"..message)
	end

	spawn(function()
		while wait() do
			if newpromise.identification ~= idCopy then
				newpromise.identification = idCopy
				print("<Promise>#"..idCopy.."'s identification was changed; rolled back to latest copy")
			end
		end
	end)
	function newpromise.resolve(reason)
		if newpromise.db then return end
		newpromise.db = true
		spawn(function()
			wait()
			newpromise.db = false
		end)
		if newpromise.state[1] ~= 'unresolved' then nError("Cannot resolve/reject a promise without state \"unresolved\"") end

		newpromise.state = {'resolved', reason or "Undefined reason"}
		_resolved:Fire(newpromise.identification,newpromise.state)
	end
	function newpromise.reject(reason)
		if newpromise.db then return end
		newpromise.db = true
		spawn(function()
			wait()
			newpromise.db = false
		end)
		if newpromise.state[1] ~= 'unresolved' then nError("Cannot resolve/reject a promise without state \"unresolved\"") end

		newpromise.state = {'rejected', reason or "Undefined reason"}
		_rejected:Fire(newpromise.identification,newpromise.state)
	end
	function newpromise.getstate()
		return newpromise.state
	end
	function newpromise.setFunction(f)
		newpromise._function = f
	end
	function newpromise.execute()
		if typeof(newpromise._function) ~= "function" then nError("<Promise>._function was *nil* or was not a function; use <Promise>.setFunction(type function)") end
		spawn(function()
			newpromise._function()
		end)
	end
	function newpromise.isUnresolved()
		if newpromise.getstate()[1] == 'unresolved' then return true else return false end
	end
	function newpromise._then_(f,timeout)
		if typeof(f) ~= "function" then nError("function in function Promise._then_(function) was nil or not a function") end
		spawn(function()
			local l = 0
			repeat
				wait(1)
				l = l + 1
			until newpromise.isUnresolved() == false
			if l <= timeout then
				spawn(function()
					f()
				end)
			end
		end)
	end
	all[#all+1]=newpromise
	return newpromise
end

function promise.resolveAll(reason:string,usepcall:boolean)
	local dumpLog = {}
	if typeof(reason) ~= "string" then error("reason in function PromiseModule.resolveAll* was not a string") end
	if typeof(usepcall) ~= "boolean" then error("usepcall in function PromiseModule.resolveAll* was not a boolean value") end
	if usepcall then
		for _,currentPromise in pairs(all) do
			local s,e = pcall(function()
				currentPromise.resolve(reason)
			end)
			if e then table.insert(dumpLog,e) end
		end
		return dumpLog
	else
		for _,currentPromise in pairs(all) do
			currentPromise.resolve(reason)
		end
	end	
end

return promise
