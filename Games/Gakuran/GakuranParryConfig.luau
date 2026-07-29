return {
	GameName = "Gakuran",
	IgnoreIds = {
		73766443218740, 111699625251889, 85823794654077, 83600639547203, 99661732639863, 106268941365574,
		109816855387997, 122561749929324, 129805948180599, 90752347516770, 135133599113049, 132695091086148,
		137015026151472, 114511731321756, 122541287927198, 80309578200579, 100794890036133, 109303037515668,
		117293898907979, 74690341409113, 73090768467054, 72284079162560, 92787945841620, 89016181362524,
		76945839486275, 101161965631044, 80135556847061, 128307941333158, 85931837451298, 91352556581859,
		104407197874289, 77911299793653, 129335968179665, 122384188141033, 132695766056641, 113331696487725,
		124220338099067, 99799500309776, 108636808436488, 90015977935891, 87932588807124, 132477488202815,
		102982320608759, 109278619250401, 79971841883936, 97783129267001, 72822821848529, 79974955602012,
		77798715679680, 85845666927963, 108862846290180, 108045962864902, 93184693099565, 120399899079666,
		99958962160522,
	},
	ParriedAnimation = {
		"rbxassetid://100773926241456",
		"rbxassetid://102823909334302",
		"rbxassetid://96304721384743",
		"rbxassetid://82979105739696",
		"rbxassetid://96600699015093",
		"rbxassetid://138519505081692",
	},
	StunnedAnimation = {
		"rbxassetid://9598562590",
		"rbxassetid://9598537410",
		"rbxassetid://9598551746",
	},
	ParryingAnimation = {
		"rbxassetid://118147060185189",
	},
	ParryFailed = {
		"rbxassetid://4210597123",
	},
	GameConfig = {
		["KarateAnims"] = {
			["rbxassetid://137837926745158"] = { DisplayName = "1stM1", ReactionTime = 0.15 },
			["rbxassetid://100981571094705"] = { DisplayName = "2ndM1", ReactionTime = 0.15 },
			["rbxassetid://130865087635587"] = { DisplayName = "3rdM1", ReactionTime = 0.22 },
			["rbxassetid://86495068205420"] = { DisplayName = "4thM1", ReactionTime = 0.22 },
			["rbxassetid://120393553812903"] = { DisplayName = "M2", ReactionTime = 0.3 },
		},
		["BasicAnims"] = {
			["rbxassetid://83491849294956"] = { DisplayName = "1stM1" },
			["rbxassetid://89420531853362"] = { DisplayName = "2ndM1" },
			["rbxassetid://83730275893449"] = { DisplayName = "3rdM1" },
			["rbxassetid://106980660082799"] = { DisplayName = "4thM1" },
			["rbxassetid://78888626472394"] = { DisplayName = "M2", ReactionTime = 0.3 },
			M1Time = 0.14,
		},
		["WrestlingAnims"] = {
			["rbxassetid://91485623489753"] = { DisplayName = "4thM1", ParryTime = 0.08 },
			["rbxassetid://73748315742870"] = { DisplayName = "M2", ReactionTime = 0.3 },
			["rbxassetid://82903450925391"] = { DisplayName = "1stM1", ParryTime = 0.08 },
			["rbxassetid://119685134442395"] = { DisplayName = "2ndM1", ParryTime = 0.08 },
			["rbxassetid://107464726433388"] = { DisplayName = "3rdM1", ParryTime = 0.08 },
			M1Time = 0.11,
		},
		["MuayThaiAnims"] = {
			["rbxassetid://137034747040618"] = { DisplayName = "M2", ReactionTime = 0.3 },
			["rbxassetid://74960202100098"] = { DisplayName = "4thM1", ParryTime = 0.08 },
			["rbxassetid://104515319350296"] = { DisplayName = "3rdM1", ParryTime = 0.08 },
			["rbxassetid://139911027872047"] = { DisplayName = "2ndM1", ParryTime = 0.08 },
			["rbxassetid://96726284968458"] = { DisplayName = "1stM1", ParryTime = 0.08 },
			M1Time = 0.1,
		},
		["BoxingAnims"] = {
			["rbxassetid://137980914350618"] = { DisplayName = "1stM1", ReactionTime = 0.12 },
			["rbxassetid://100408082509740"] = { DisplayName = "2ndM1", ReactionTime = 0.12 },
			["rbxassetid://94803478352691"] = { DisplayName = "3rdM1", ReactionTime = 0.15 },
			["rbxassetid://78695517680318"] = { DisplayName = "4thM1", ReactionTime = 0.15 },
			["rbxassetid://132022052139564"] = {
				DisplayName = "M2",
				ParryFunction = function(data, helpers)
					if data.RegistryData.Processed then
						return
					end
					data.RegistryData.Processed = true
					task.spawn(function()
						task.wait(0.3)
						helpers.Dodge()
						task.wait(0.35)
						helpers.BlockStart(os.clock(), 0.6)
					end)
				end,
			},
		},
		["HakariAnims"] = {
			["rbxassetid://82855179231529"] = { DisplayName = "MomentumM2" },
			["rbxassetid://76236532060812"] = { DisplayName = "1stM1", ReactionTime = 0.15 },
			["rbxassetid://74206130671324"] = { DisplayName = "2ndM1", ReactionTime = 0.17 },
			["rbxassetid://71919935695307"] = { DisplayName = "3rdM1", ReactionTime = 0.15 },
			["rbxassetid://122861547142657"] = { DisplayName = "4thM1", ReactionTime = 0.21 },
			["rbxassetid://92851992709496"] = { DisplayName = "M2", ReactionTime = 0.35 },
		},
		["CapoeiraAnims"] = {
			["rbxassetid://125976167173936"] = { DisplayName = "1stM1", ReactionTime = 0.15 },
			["rbxassetid://134945199381140"] = { DisplayName = "2ndM1", ReactionTime = 0.22 },
			["rbxassetid://117877243065533"] = { DisplayName = "3rdM1", ReactionTime = 0.16 },
			["rbxassetid://106965238908791"] = { DisplayName = "4thM1", ReactionTime = 0.16 },
			["rbxassetid://131071815103338"] = { DisplayName = "Whirlwind", ReactionTime = 0.32 },
		},
		["SluggerAnims"] = {
			["rbxassetid://134829666925953"] = { DisplayName = "1stM1", ReactionTime = 0.24 },
			["rbxassetid://104867156139010"] = { DisplayName = "2ndM1", ReactionTime = 0.22 },
			["rbxassetid://112759168172605"] = { DisplayName = "3rdM1", ReactionTime = 0.22 },
			["rbxassetid://114647502301740"] = { DisplayName = "4thM1", ReactionTime = 0.19 },
			["rbxassetid://118943955490014"] = { DisplayName = "M2", ReactionTime = 0.65 },
		},
		["StrikerAnims"] = {
			["rbxassetid://127909081017342"] = { DisplayName = "1stM1" },
			["rbxassetid://79563637573277"] = { DisplayName = "2ndM1" },
			["rbxassetid://118070233153900"] = { DisplayName = "3rdM1" },
			["rbxassetid://77710266587706"] = { DisplayName = "4thM1" },
			["rbxassetid://114364673509520"] = { DisplayName = "M2" },
			["rbxassetid://132840225082238"] = { DisplayName = "1stM1" },
			["rbxassetid://88761422474765"] = { DisplayName = "2ndM1" },
			["rbxassetid://98462236639320"] = { DisplayName = "3rdM1" },
			["rbxassetid://122451562066756"] = { DisplayName = "4thM1" },
		},
		["KureAnims"] = {
			["rbxassetid://71676634048602"] = { DisplayName = "4thM1" },
			["rbxassetid://102407060635393"] = { DisplayName = "M2", ReactionTime = 0.01 },
			["rbxassetid://82904229252991"] = { DisplayName = "1stM1" },
			["rbxassetid://103732110215321"] = { DisplayName = "2ndM1" },
			["rbxassetid://103964436023727"] = { DisplayName = "3rdM1" },
		},
		["HakariOtherAnims"] = {
			["rbxassetid://126612786608030"] = { DisplayName = "1stM1" },
			["rbxassetid://113719263885794"] = { DisplayName = "2ndM1" },
			["rbxassetid://136305578634960"] = { DisplayName = "3rdM1" },
			["rbxassetid://89039586375625"] = { DisplayName = "4thM1" },
			["rbxassetid://82855179231529"] = { DisplayName = "MomentumM2" },
			["rbxassetid://101619248052969"] = { DisplayName = "M2" },
		},
	},
}
