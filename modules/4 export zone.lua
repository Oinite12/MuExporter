local simple_ev = Mu_f.simple_ev
G.STAGES.muexp_EXPORTZONE = "muexp_1"
G.STATES.muexp_EXPORTZONE = "muexp_1"
G.STAGE_OBJECTS[G.STAGES.muexp_EXPORTZONE] = {}

local export_zone_stylesheet = {}

local export_zone_jtml =
{"root", class="root", {

}}

-- Generates the export zone.\
-- (similar to a run starting)\
-- For proper functionality, please use G.FUNCS.start_export_zone.
---@return nil
function Game:generate_export_zone()
	-- bc tfym ts nil atp???
	self.CONTROLLER = {locks = {}}
	self.SETTINGS = {}

	self:prep_stage(G.STAGES.muexp_EXPORTZONE, G.STATES.muexp_EXPORTZONE)
	G.STAGE = G.STAGES.muexp_EXPORTZONE
    set_screen_positions()

	G.SPLASH_BACK = Sprite(-30, -6, G.ROOM.T.w+60, G.ROOM.T.h+12, G.ASSET_ATLAS["ui_1"], {x = 2, y = 0})
	G.SPLASH_BACK:set_alignment({
		major = G.play,
		type = 'cm',
		bond = 'Strong',
		offset = {x=0,y=0}
	})

	G.ARGS.spin = {
		amount = 0,
		real = 0,
		eased = 0
	}

	G.SPLASH_BACK:define_draw_steps({{
		shader = 'background',
		send = {
			{name = 'time', ref_table = G.TIMERS, ref_value = 'REAL_SHADER'},
			{name = 'spin_time', ref_table = G.TIMERS, ref_value = 'BACKGROUND'},
			{name = 'colour_1', ref_table = G.C.BACKGROUND, ref_value = 'C'},
			{name = 'colour_2', ref_table = G.C.BACKGROUND, ref_value = 'L'},
			{name = 'colour_3', ref_table = G.C.BACKGROUND, ref_value = 'D'},
			{name = 'contrast', ref_table = G.C.BACKGROUND, ref_value = 'contrast'},
			{name = 'spin_amount', ref_table = G.ARGS.spin, ref_value = 'amount'}
		}
	}})

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		blocking = false,
		blockable = false,
		func = (function()
			local _dt = G.ARGS.spin.amount > G.ARGS.spin.eased and G.real_dt*2. or 0.3*G.real_dt
			local delta = G.ARGS.spin.real - G.ARGS.spin.eased
			if math.abs(delta) > _dt then delta = delta*_dt/math.abs(delta) end
			G.ARGS.spin.eased = G.ARGS.spin.eased + delta
			G.ARGS.spin.amount = _dt*(G.ARGS.spin.eased) + (1 - _dt)*G.ARGS.spin.amount
			G.TIMERS.BACKGROUND = G.TIMERS.BACKGROUND - 60*(G.ARGS.spin.eased - G.ARGS.spin.amount)*_dt
		end)
	}))

	self.HUD = UIBox {
		definition = Mu_f.jtml_to_uibox(export_zone_jtml, export_zone_stylesheet),
		config = {
			align = "cli",
			offset = {x=-0.7, y=0},
			major = G.ROOM_ATTACH
		}
	}
end

-- Switches the game stage to the export zone.\
-- To be used as a button function.
---@return nil
G.FUNCS.start_export_zone = function()
	G.E_MANAGER:clear_queue()
	G.FUNCS.wipe_on()

	G.E_MANAGER:add_event(Event({
		no_delete = true,
		func = function()
			G:delete_run()
			return true
		end
	}))

	G.E_MANAGER:add_event(Event({
		trigger = 'immediate',
		no_delete = true,
		func = function()
			Game:generate_export_zone()
			return true
		end
	}))

	G.FUNCS.wipe_off()
end

--[[

G.FUNCS.start_export_zone()

]]
