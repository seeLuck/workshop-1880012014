GLOBAL.AddModUserCommand("u-rollback", "rollback", {
	prettyname = function(command) return "rollback" end,
	desc = function() return "User Rollback" end,
	permission = "USER",
	params = {},
	emote = false,
	slash = true,
	usermenu = false,
	servermenu = false,
	vote = false,
	serverfn = function(params, caller)
		print("u-rollback by user "..caller.userid)
		GLOBAL.TheNet:SendWorldRollbackRequestToServer(2)
	end
})