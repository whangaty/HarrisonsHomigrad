util.AddNetworkString("afk")

net.Receive("afk",function(len,ply)
	ply:KillSilent()
	ply:Kick("Due to High Server Demand, you have been kicked for idling.")
end)