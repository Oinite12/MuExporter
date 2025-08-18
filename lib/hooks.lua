local addtodeck_hook = Card.add_to_deck
function Card:add_to_deck(from_debuff)
	if G.STAGE ~= G.STAGES.muexp_EXPORTZONE then
		addtodeck_hook(self, from_debuff)
	end
end

local removefromdeck_hook = Card.remove_from_deck
function Card:remove_from_deck(from_debuff)
	if G.STAGE ~= G.STAGES.muexp_EXPORTZONE then
		removefromdeck_hook(self, from_debuff)
	end
end