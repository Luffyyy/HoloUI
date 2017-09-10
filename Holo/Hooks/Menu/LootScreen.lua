if Holo:ShouldModify("Menu", "Lobby") then
	Holo:Post(HUDLootScreen, "init", function(self)
		self._background_layer_full:child(0):hide() --fuck off with your bg text
	end)
	Holo:Post(HUDLootScreen, "create_peer", function(self, peers_panel, peer_id)
		Holo.Utils:SetBlendMode(peers_panel)
		for _, o in pairs(peers_panel:child("peer" .. tostring(peer_id)):children()) do
			if o.child then
				for _, ob in pairs(o:children()) do
					if ob:name() == "BoxGui" then
						o:hide()
					end
				end
			end
		end
	end)
	Holo:Post(HUDLootScreen, "create_selected_panel", function(self, peer_id)
		Holo.Utils:SetBlendMode(self._peers_panel)
	end)
end