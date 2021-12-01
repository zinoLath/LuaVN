_author="LuaSTG User"
_mod_version=4096
_allow_practice=true
_allow_sc_practice=true

stage.group.New('menu',{},"Normal",{},true,1)
stage.group.AddStage('Normal','Stage 1@Normal',{},true)
stage.group.DefStageFunc('Stage 1@Normal','init',function(self)

    task.New(self,function()

		while true do task.Wait(100) end
    end)

    task.New(self,function()
		while coroutine.status(self.task[1])~='dead' do task.Wait() end
		stage.group.FinishReplay()
		New(mask_fader,'close')
		task.New(self,function()
			local _,bgm=EnumRes('bgm')
			for i=1,30 do 
				for _,v in pairs(bgm) do
					if GetMusicState(v)=='playing' then
					SetBGMVolume(v,1-i/30) end
				end
				task.Wait()
		end end)
		task.Wait(30)
		stage.group.FinishStage()
	end)
end)
