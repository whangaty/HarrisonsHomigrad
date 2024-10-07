function GM:MouthMoveAnimation( ply )

	local flexes = {
		ply:GetFlexIDByName( "jaw_drop" ),
		ply:GetFlexIDByName( "left_part" ),
		ply:GetFlexIDByName( "right_part" ),
		ply:GetFlexIDByName( "left_mouth_drop" ),
		ply:GetFlexIDByName( "right_mouth_drop" )
	}

	local weight = ply:IsSpeaking() && math.Clamp( ply:VoiceVolume() * 6, 0, 6 ) || 0

	for k, v in pairs( flexes ) do

		ply:SetFlexWeight( v, weight * 6)

	end

end