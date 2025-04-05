local Audio = {
    sounds = {},
    currentVolume = 1.0,
    baseVolume = 0.5  -- Reduced base volume multiplier for a more subtle sound
}

function Audio.load()
    -- Load button selection sound
    Audio.sounds.buttonSelect = love.audio.newSource("assets/sounds/button_select.wav", "static")
    -- Set to maximum volume
    Audio.sounds.buttonSelect:setVolume(Audio.currentVolume * Audio.baseVolume)
end

function Audio.playButtonSelect()
    if Audio.sounds.buttonSelect then
        -- Stop and rewind the sound if it's already playing
        Audio.sounds.buttonSelect:stop()
        -- Ensure volume is at maximum before playing
        Audio.sounds.buttonSelect:setVolume(Audio.currentVolume * Audio.baseVolume)
        Audio.sounds.buttonSelect:play()
    end
end

function Audio.setVolume(volume)
    Audio.currentVolume = volume
    for _, sound in pairs(Audio.sounds) do
        sound:setVolume(volume * Audio.baseVolume)
    end
end

return Audio 