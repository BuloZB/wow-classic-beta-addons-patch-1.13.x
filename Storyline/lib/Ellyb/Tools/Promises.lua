---@type Ellyb
local Ellyb = Ellyb:GetInstance(...);

-- Lua imports
local pairs = pairs;
local insert = table.insert;

--- Helpers to handle one or more promises
local Promises = {};

Promises.STATUS = {
	PENDING = 0, -- The promise hasn't been resolved or rejected yet
	FULFILLED = 1, -- The promise has been resolved
	REJECTED = -1, -- The promise has been rejected
}

--- Create a new promise that will gather all promises
---@param promises Promise[]
---@return Promise all
function Promises.all(promises)
	local allPromise = Ellyb.Promise();

	-- This table will hold the values of each Promise resolution
	local promisesResolutionArgs = {};

	for _, promise in pairs(promises) do
		-- If any of the promise fail, the we reject the promise
		promise:Fail(function(...)
			allPromise:Reject(...);
		end);

		promise:Success(function(...)
			insert(promisesResolutionArgs, { ... });
			local allPromisesHaveBeenFulfilled = true;
			for _, otherPromise in pairs(promises) do
				if not otherPromise:HasBeenFulfilled() then
					allPromisesHaveBeenFulfilled = false;
				end
			end

			if allPromisesHaveBeenFulfilled then
				-- If all promises have been resolved, we resolve the allPromise with the table of all the resolutions values
				allPromise:Resolve(promisesResolutionArgs);
			end
		end)
	end

	return allPromise;
end

Ellyb.Promises = Promises;