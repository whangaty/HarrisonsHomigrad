util.AddNetworkString("afk")

net.Receive("afk",function(len,ply)
	ply:KillSilent()
	ply:Kick("You have been kicked for idling for 5 minutes.")
end)