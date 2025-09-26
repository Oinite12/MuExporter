Mu_f.simple_ev(function ()
	-- Hook to ignore add_to_deck events in export zone
	local addtodeck_hook = Card.add_to_deck
	function Card:add_to_deck(from_debuff)
		if G.STAGE ~= G.STAGES.muexp_EXPORTZONE then
			addtodeck_hook(self, from_debuff)
		end
	end

	-- Hook to ignore remove_from_deck events in export zone
	local removefromdeck_hook = Card.remove_from_deck
	function Card:remove_from_deck(from_debuff)
		if G.STAGE ~= G.STAGES.muexp_EXPORTZONE then
			removefromdeck_hook(self, from_debuff)
		end
	end

	-- Injecting image data into atlas for low-contrast playing cards (needed for Ace of Spades in enhancement image exports)
	G.ASSET_ATLAS.cards_1.image_data = love.image.newImageData("resources/textures/"..G.SETTINGS.GRAPHICS.texture_scaling.."x/8BitDeck.png")
end)