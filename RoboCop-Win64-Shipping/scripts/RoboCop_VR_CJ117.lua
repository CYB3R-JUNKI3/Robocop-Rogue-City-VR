--##########################
--# RoboCop Vr Fix - CJ117 #
--##########################

--########################
--# D_Pad_Method Options #
--########################
-- 0 = Right Thumbrest + Left Joystick
-- 1 = Left Thumbrest + Right Joystick
-- 4 = Gesture (Head) + Left Joystick
-- 5 = Gesture (Head) + Right Joystick

local D_Pad_Method = 0
local Enable_Scan_Fix = true

--# Do Not Edit Below This Line #

local api = uevr.api
local params = uevr.params
local callbacks = params.sdk.callbacks

local Mactive = false
local Playing = false
local mDown = false
local mUp = false
local offset = {}
local adjusted_offset = {}
local base_pos = { 0, 0, 0 }
local mAttack = false
local mDownC = 0
local mUpC = 0
local mDB = false
local base_dif = 0
local JustCentered = false
local is_running = false
local is_scanning = false
local weap_loc = nil
local active_weap = nil
local active_weap_name = "None"
local cur_weap = nil
local seq_active = false
local cut_paused = false
local eval_active = false
local panel_active = false
local move_mode = nil
local is_hidden = false
local is_load = false
local detective = false
local is_input = false
local is_view = false
local interact_with = nil
local det_enable = false
local crossmesh = nil
local retmesh = nil
local is_menu = false
local in_gallery = false
local is_end = false
local is_tut = false
local shake_obj = nil
local muzzle_obj = nil
local is_punch = false
local is_logo = false
local on_ladder = false
local is_breach = false
local is_interact = false
local shady_active = false
local is_crosshair_visible = false
local pause_time = 0
local alt_time = 0
local is_false = 0
local last_weapon = nil

local function find_required_object(name)
	local obj = uevr.api:find_uobject(name)
	if not obj then
		return nil
	end

	return obj
end

local rot_mod_c = find_required_object("Class /Script/Game.RotationLimitCameraModifier")
local end_cred_c = find_required_object("WidgetBlueprintGeneratedClass /Game/UI/Popups/Comics/WB_ComicsCard.WB_ComicsCard_C")
local int_logo_c = find_required_object("Class /Script/UMG.UserWidget")
local game_engine_class = find_required_object("Class /Script/Engine.GameEngine")
local melee_mesh_c = find_required_object("Class /Script/Game.PlayerMeleeWeapon")

local function ShadyFix()
	local game_engine = UEVR_UObjectHook.get_first_object_by_class(game_engine_class)

	local viewport = game_engine.GameViewport
	if viewport == nil then

		return
	end

	local world = viewport.World

	local mg_mesh_c = world.OwningGameInstance:get_outer()
	if mg_mesh_c ~= nil then
		local mg_mesh = mg_mesh_c.GameUserSettings

		if mg_mesh ~= nil then
			crossmesh = mg_mesh
			is_crosshair_visible = mg_mesh.bCrosshairVisible
		end
	end	
end

local function RetRem()
	--RetMesh
	local rpawn = api:get_local_pawn(0)
	local ret_mesh = rpawn.FPPHudWidget.CurrentReticle

	if ret_mesh ~= nil and is_crosshair_visible == true then
		ret_mesh.Image_DownLaser.Brush.DrawAs = 0
		ret_mesh.Image_UpLaser.Brush.DrawAs = 0
		ret_mesh.Image_LeftLaser.Brush.DrawAs = 0
		ret_mesh.Image_RightLaser.Brush.DrawAs = 0

		if shady_active == true then
			ret_mesh.Image_CenterDotLaser.Brush.DrawAs = 0
			ret_mesh.Image_CenterSquareLaser.Brush.DrawAs = 0
		end
	end	
end

local function GalleryFix()
	local wpawn = api:get_local_pawn(0)
	local cur_weap = wpawn.Weapon.WeaponMesh

	if rot_mod_c ~= nil then
		local rot_mod = rot_mod_c:get_objects_matching(false)

		for i, mesh in ipairs(rot_mod) do
			if mesh:get_fname():to_string() == "RotationLimitCameraModifier_0" then
				cur_weap:call("SetVisibility", true)
				mesh:DisableModifier(Disable)

				--print(tostring(mesh:get_full_name()))
				break
			end
		end
	end
end

local function reset_height()
	local base = UEVR_Vector3f.new()
	params.vr.get_standing_origin(base)
	local hmd_index = params.vr.get_hmd_index()
	local hmd_pos = UEVR_Vector3f.new()
	local hmd_rot = UEVR_Quaternionf.new()
	params.vr.get_pose(hmd_index, hmd_pos, hmd_rot)
	base.x = hmd_pos.x
	base.y = hmd_pos.y
	base.z = hmd_pos.z
	params.vr.set_standing_origin(base)
end

local function ResetPlayUI()
	params.vr.set_mod_value("VR_EnableGUI", "true")
	params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
	params.vr.set_mod_value("UI_Distance", "8.500")
	params.vr.set_mod_value("UI_Size", "7.50")
	params.vr.set_mod_value("UI_X_Offset", "0.00")
	params.vr.set_mod_value("UI_Y_Offset", "0.00")
	params.vr.set_mod_value("VR_DPadShiftingMethod", D_Pad_Method)
end

local function Tut_Eval_Check()
	
	local game_engine = UEVR_UObjectHook.get_first_object_by_class(game_engine_class)

	local viewport = game_engine.GameViewport
	if viewport == nil then 
		print("Viewport is nil")
		return
	end
	
	world = viewport.World
	
	if world.AuthorityGameMode ~= nil then
		pause_time = world.GameState.ReplicatedWorldTimeSecondsDouble
		--print(pause_time)
		--print(alt_time)
		if pause_time == alt_time then
			is_false = is_false+1
			if is_false > 30 then
				is_paused = true
				--is_tut = true
				eval_active = true
				--print("Paused")	
				--print("Paused")
				--print(is_false)
			end
		else
			is_false = 0
			is_paused = false
			eval_active = false
			--print("Playing")
		end
	end
end

local function ScaleFix()
	local spawn = api:get_local_pawn(0)
	local sactive_weap = spawn.Weapon
	if Playing == true and sactive_weap ~= nil then

		if spawn ~= nil then
			
			local materials = sactive_weap.WeaponMesh.OverrideMaterials
			local mat_num = #materials
			--print(mat_num)

			for i=1, mat_num do
				
				local d_material = sactive_weap.WeaponMesh:CreateAndSetMaterialInstanceDynamicFromMaterial(i-1, sactive_weap.WeaponMesh.OverrideMaterials[i])
				d_material:SetScalarParameterValue("UsePanini", 0.0)
				--print(i)
				
			end
			
		end
	end
end

local function Melee()
	if melee_mesh_c ~= nil then
		local melee_mesh = melee_mesh_c:get_objects_matching(false)

		for i, mesh in ipairs(melee_mesh) do
			if string.find(mesh:get_fname():to_string(), "WP_MeleeWeapon_C_") then
				if mesh.bHidden == false then
					is_punch = true
					params.vr.set_mod_value("VR_EnableGUI", "true")

					break
				else
					is_punch = false
				end
			else
				is_punch = false
			end
		end
	end	
end

local function EndCredits()
	if end_cred_c ~= nil then
		local end_cred = end_cred_c:get_objects_matching(false)

		for i, mesh in ipairs(end_cred) do
			if string.find(mesh:get_fname():to_string(), "WB_ComicsCard_") and string.find(mesh:get_full_name(), "Transient.GameEngine") then
				is_end = true
				params.vr.set_mod_value("VR_EnableGUI", "true")
				--print(tostring(mesh:get_full_name()))

				break
			else
				is_end = false
			end
		end
	end
end

local function IntroLogo()
	local lpawn = api:get_local_pawn(0)
	if string.find(lpawn:get_full_name(), "L01_PrologueTVstation_ALL") then
		if int_logo_c ~= nil then
			local int_logo = UEVR_UObjectHook.get_objects_by_class(int_logo_c, false)

			for i, mesh in ipairs(int_logo) do
				if string.find(mesh:get_fname():to_string(), "WB_LogoEnter_C") and string.find(mesh:get_full_name(), "Transient.GameEngine") then
					is_logo = true
					params.vr.set_mod_value("VR_EnableGUI", "true")
					--print(tostring(mesh:get_full_name()))

					break
				else
					is_logo = false
				end
			end
		end
	end
end

print("Robocop: Rogue City VR - CJ117")
params.vr.set_mod_value("VR_GhostingFix", "false")
params.vr.set_aim_method(0)
reset_height()
ResetPlayUI()

local pawn = nil
local sactive_mesh = nil

uevr.sdk.callbacks.on_pre_engine_tick(function(engine, delta)
	
	local game_engine = UEVR_UObjectHook.get_first_object_by_class(game_engine_class)

	local viewport = game_engine.GameViewport
	if viewport == nil then

		return
	end

	local world = viewport.World

	pawn = api:get_local_pawn(0)
	local pcont = api:get_player_controller(0)

	if pawn ~= nil then
		active_weap = pawn.Weapon
		sactive_mesh = pawn.Mesh
		is_mouse = pcont.bShowMouseCursor
		is_hidden = pawn.bHidden
		is_load = pawn.bNetLoadOnClient
		detective = pawn.DetectiveModeComponent.bIsActive
		is_input = pawn.bInputEnabled
		is_view = pawn.bIsLocalViewTarget
		interact_with = pawn.PawnInteractionComponent.InteractionWith
		is_interact = pawn.PawnInteractionComponent.InteractionTextHidden
		is_menu = world.AuthorityGameMode.bIsInGameMenuShown
		shake_obj = pcont.PlayerCameraManager.CachedCameraShakeMod
		ShadyFix()

		
		if active_weap ~= nil then
			active_weap_name = active_weap:get_full_name()
		end

		if pawn.BreachOverlapActor ~= nil then
			if string.find(pawn.BreachOverlapActor:get_full_name(), "BP_Ladder_C") then
				on_ladder = pawn.BreachOverlapActor.bIsClimbing
			else
				on_ladder = false
			end
			if string.find(pawn.BreachOverlapActor:get_full_name(), "Door")
				or string.find(pawn.BreachOverlapActor:get_full_name(), "Breachable") then
				is_breach = true
			else
				is_breach = false
			end
		end

		if not string.find(pawn:get_full_name(), "Starting") then

			Tut_Eval_Check()

			if string.find(pawn:get_full_name(), "PoliceStation") then
				if is_input == false then
					GalleryFix()
				end
			end

			if interact_with == nil and eval_active == false and is_interact == false then
				if is_input == false and is_view == false then
					params.vr.set_mod_value("VR_EnableGUI", "false")
				elseif is_input == true and is_view == false then
					params.vr.set_mod_value("VR_EnableGUI", "false")
				elseif is_input == true and is_view == true then
					params.vr.set_mod_value("VR_EnableGUI", "true")
					is_tut = false
					eval_active = false
				end
			else
				if is_input == false and is_view == false then
					params.vr.set_mod_value("VR_EnableGUI", "false")
				elseif is_input == true and is_view == false then
					params.vr.set_mod_value("VR_EnableGUI", "true")
				elseif is_input == true and is_view == true then
					params.vr.set_mod_value("VR_EnableGUI", "true")
					is_tut = false
				end
			end

			if is_mouse == true then
				params.vr.set_mod_value("VR_EnableGUI", "true")
			end

			if string.find(pawn:get_full_name(), "L27_OCPHQ_ALL") then
				EndCredits()
			end
		end

		if pawn.Weapon ~= nil and active_weap ~= nil then
			if not string.find(active_weap:get_full_name(), "NoWeapon") then
				cur_weap = pawn.Weapon.WeaponMesh
				if cur_weap == last_weapon then 
				
				else
					local u_exist = UEVR_UObjectHook.exists(last_weapon)
					if u_exist == true then
						weap_loc = UEVR_UObjectHook.remove_motion_controller_state(last_weapon)
					end	
					ScaleFix()
				end
			end
		end
	end

	if pawn == nil or string.find(pawn:get_full_name(), "Starting") or seq_active == true or is_mouse == true or eval_active == true or is_hidden == true or is_load == false or detective == true or is_input == false or is_view == false or is_menu == true or on_ladder == true or is_tut == true then
		if Mactive == false then
			print("InCut")
			Mactive = true
			Playing = false
			mDB = false
			params.vr.set_mod_value("VR_GhostingFix", "false")
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "false")
			UEVR_UObjectHook.set_disabled(true)
			params.vr.set_aim_method(0)
		end
		
		IntroLogo()
		if cut_paused == true or string.find(pawn:get_full_name(), "Starting") or eval_active == true or panel_active == true or is_mouse == true or detective == true or is_input == true or is_menu == true or is_end == true or is_tut == true or is_logo == true and seq_active == false then
			if string.find(pawn:get_full_name(), "Starting") or is_mouse == true or eval_active == true or is_end == true or is_tut == true then
				if interact_with == nil then
					UEVR_UObjectHook.set_disabled(false)
					params.vr.set_mod_value("UI_FollowView", "false")
					params.vr.set_mod_value("UI_Distance", "8.500")
					params.vr.set_mod_value("UI_Size", "7.50")
				else
					if is_menu == false and is_end == false then
						params.vr.set_mod_value("VR_DPadShiftingMethod", D_Pad_Method)
						params.vr.set_mod_value("UI_Distance", "0.500")
						params.vr.set_mod_value("UI_Size", "0.70")
					else
						params.vr.set_mod_value("UI_FollowView", "false")
						params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "false")
						params.vr.set_mod_value("UI_Distance", "8.500")
						params.vr.set_mod_value("UI_Size", "7.50")
					end
				end
			else
				params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
				if is_logo == true or eval_active == true and interact_with == nil then
					params.vr.set_mod_value("UI_Distance", "8.500")
					params.vr.set_mod_value("UI_Size", "7.50")
				else
					params.vr.set_mod_value("UI_Distance", "0.500")
					params.vr.set_mod_value("UI_Size", "0.70")
				end
			end
		end

		if is_view == false or is_tut == true then
			params.vr.set_mod_value("VR_DPadShiftingMethod", "2")
		end

		if is_input == false and is_breach == true then
			pawn.Mesh:call("SetRenderInMainPass", true)
		end
		
		if eval_active == true then
			params.vr.set_mod_value("VR_EnableGUI", "true")
		end
	else
		if Playing == false then
			print("Playing")
			Mactive = false
			Playing = true
			mDB = false
			
			ResetPlayUI()
			params.vr.set_mod_value("VR_GhostingFix", "true")
			UEVR_UObjectHook.set_disabled(false)
			params.vr.set_aim_method(2)
		end

		Melee()

		if string.find(pawn:get_full_name(), "L15_ShadyMeeting") then
			params.vr.set_mod_value("VR_DecoupledPitchUIAdjust", "true")
			params.vr.set_mod_value("UI_FollowView", "true")
			ShadyFix()
			shady_active = true
		else
			shady_active = false
			if is_crosshair_visible == true then
				crossmesh.bCrosshairVisible = true
			end
			params.vr.set_mod_value("UI_FollowView", "false")
		end

		if active_weap ~= nil and cur_weap ~= nil and not string.find(active_weap:get_full_name(), "NoWeapon") then
			weap_loc = UEVR_UObjectHook.get_or_add_motion_controller_state(cur_weap)
			
		 	RetRem()

		 	if Playing == true then
		 		weap_loc:set_hand(1)
		 		weap_loc:set_permanent(true)
		 		
				last_weapon = cur_weap			
		 		if string.find(cur_weap:get_full_name(), "BerettaAuto") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-2.500, -3.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "SmgUZI") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-2.500, -3.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "SigSauer") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-2.500, -3.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "AKM") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-7.500, -7.500, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "Mossberg") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(0.000, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "HK21") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-7.00, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "BrowningM60") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-7.00, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "DesertEagle") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-2.500, -3.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "ATGM") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "IntraTec") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "SteyrAUG") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "HKG11") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "Spas12") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-2.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "MM1GL") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "Sniper") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-3.500, -5.000, 0.000))
		 		elseif string.find(cur_weap:get_full_name(), "BarrettM82") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(-7.00, -5.000, 0.000))
				elseif string.find(cur_weap:get_full_name(), "SterlingMk6") then
		 			weap_loc:set_rotation_offset(Vector3f.new(-0.00, 1.575, -0.000))
		 			weap_loc:set_location_offset(Vector3f.new(0.00, -5.00, 0.000))	
		 		end
		 	end
			
			if eval_active == true then
				params.vr.set_aim_method(0)
			else
				params.vr.set_aim_method(2)
			end

		 	if Playing == true and not string.find(active_weap:get_full_name(), "NoWeapon") then
		 		local right_controller_index = params.vr.get_right_controller_index()
		 		local right_controller_position = UEVR_Vector3f.new()
		 		local right_controller_rotation = UEVR_Quaternionf.new()
		 		params.vr.get_pose(right_controller_index, right_controller_position, right_controller_rotation)

		 		offset[1] = right_controller_position.y - base_pos[1]
		 		offset[2] = right_controller_position.z - base_pos[2]
		 		adjusted_offset[2] = offset[2] + base_dif
		 		if offset[1] <= -0.02 then
		 			mDown = true
		 		end
		 		if adjusted_offset[2] <= -0.0112 then
		 			mUp = true
		 		end
		 		if mDown == true and mUp == true and mDB == true then
		 			mDownC = 0
		 			mUpC = 0
		 			mDown = false
		 			mUp = false
		 			mAttack = true
		 		end
		 		base_pos[1] = right_controller_position.y
		 		base_pos[2] = right_controller_position.z
		 		base_dif = 0
		 		if offset[2] < 0 then
		 			base_dif = offset[2]
		 		end
		 		if mUp == true then
		 			mUpC = mUpC + 1
		 		end
		 		if mDown == true then
		 			mDownC = mDownC + 1
		 		end
		 		if mDownC > 10 or mUpC > 10 then
		 			mDownC = 0
		 			mUpC = 0
		 			mDown = false
		 			mUp = false
		 			mDB = true
		 		end

		 		if mAttack == true then
		 			mDB = false
		 		end
		 	end

		 	if is_punch == true then
		 		pawn.Mesh:call("SetRenderInMainPass", true)
		 	end
		 end
	end

	alt_time = world.GameState.ReplicatedWorldTimeSecondsDouble
end)


uevr.sdk.callbacks.on_xinput_get_state(function(retval, user_index, state)
	if (state ~= nil) then
		if Playing == false then
			if state.Gamepad.bLeftTrigger ~= 0 and state.Gamepad.bRightTrigger ~= 0 then
				if JustCentered == false then
					JustCentered = true
					reset_height()
					params.vr.recenter_view()
					state.Gamepad.bLeftTrigger = 0
					state.Gamepad.bRightTrigger = 0
				end
			else
				JustCentered = false
			end
		end

		if Playing == true then
			if state.Gamepad.sThumbRY >= 30000 then
				if is_running == false then
					is_running = true
					state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_LEFT_THUMB
				end
			else
				is_running = false
			end
		end

		if Playing == true then
			if state.Gamepad.sThumbRY <= -30000 then
				if is_scanning == false then
					is_scanning = true
					state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_RIGHT_THUMB
				end
			else
				is_scanning = false
			end
		end

		if Playing == true and in_gallery == true then
			if state.Gamepad.bLeftTrigger ~= 0 then
				state.Gamepad.bLeftTrigger = 0
			end
		end



		if Playing == true and mAttack == true then
			mAttack = false
			state.Gamepad.wButtons = state.Gamepad.wButtons | XINPUT_GAMEPAD_RIGHT_SHOULDER
		end


		if Playing == true and active_weap ~= nil then
			if state.Gamepad.bRightTrigger ~= 0 then
				shake_obj:DisableModifier(Disable)
			end
		end

		if pawn ~= nil and Enable_Scan_Fix == true then
			if active_weap == nil or string.find(active_weap_name, "NoWeapon") then
				if Playing == true then
					if state.Gamepad.bLeftTrigger ~= 0 then
						if det_enable == false then
							det_enable = true
							params.vr.set_mod_value("VR_RenderingMethod", "1")
						end
					else
						local cur_meth = params.vr:get_mod_value("VR_RenderingMethod")
						det_enable = false
						if cur_meth ~= 0 then
							params.vr.set_mod_value("VR_RenderingMethod", "0")
						end
					end
				end
			end
		end
	end
end)
