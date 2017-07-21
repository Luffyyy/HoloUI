if Holo:ShouldModify("Menu", "Lobby") then
	Hooks:PostHook(HUDLootScreen, "init", "HoloInit", function(self)
		self._background_layer_full:child(0):hide() --fuck off with your bg text
	end)
	Hooks:PostHook(HUDLootScreen, "create_peer", "HoloCreatePeer", function(self, peers_panel, peer_id)
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
	Hooks:PostHook(HUDLootScreen, "create_selected_panel", "HoloCreateSelectedPanel", function(self, peer_id)
		Holo.Utils:SetBlendMode(self._peers_panel)
	end)
end