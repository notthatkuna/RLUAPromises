return function(f)
	local Promise = {}
	local iCoroutine = nil
	
	local ENV = getfenv(f)
	ENV["CurrentPromise"] = Promise
	setfenv(f,ENV)
	
	Promise.Active = true
	Promise.ReturnState = nil
	Promise.Message = ""
	local ev = Instance.new("BindableEvent",script)
	ev.Name = "FINALLY"
	
	function Promise.finally(f)
		local x
		x = ev.Event:Connect(function()
			f(Promise.ReturnState,Promise.Message)
			x:Disconnect()
		end)
		return Promise
	end
	
	function Promise.resolve()
		Promise.Active = false
		Promise.ReturnState = true
		Promise.Message = "Resolved successfully (auto-generated message - Promise Module)"
		ev:Fire()
		coroutine.yield(iCoroutine,"Resolved")
		return Promise
	end
	
	function Promise.reject(message)
		if not message then message = "No description was given to this rejection - Promise Module" end
		Promise.Active = false
		Promise.ReturnState = false
		Promise.Message = message
		ev:Fire()
		coroutine.yield(iCoroutine,"Rejected")
		return Promise
	end
	
	iCoroutine = coroutine.create(f)
	coroutine.resume(iCoroutine)
	
	return Promise
end
