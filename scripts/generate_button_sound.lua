local function generateButtonSound()
    -- Create a pleasant dlonk sound
    local sampleRate = 44100
    local duration = 0.25  -- 250ms (longer for smoother decay)
    local baseFreq = 300  -- Even lower base frequency for a deeper sound
    local samples = {}
    
    -- Generate a complex tone with multiple harmonics
    for i = 1, sampleRate * duration do
        local t = i / sampleRate
        
        -- Combine multiple harmonics with different amplitudes and slight detuning
        local amplitude = 
            1.0 * math.sin(2 * math.pi * baseFreq * t) +                  -- Base frequency
            0.6 * math.sin(2 * math.pi * (baseFreq * 1.5) * t) +         -- Sub-harmonic for warmth
            0.3 * math.sin(2 * math.pi * (baseFreq * 2.001) * t) +       -- Second harmonic (reduced)
            0.15 * math.sin(2 * math.pi * (baseFreq * 3.002) * t)        -- Third harmonic (reduced)
            
        -- Apply an envelope for a more natural sound
        local attack = 0.03  -- 30ms attack (longer for smoother start)
        local decay = duration - attack
        local envelope
        if t < attack then
            envelope = (t / attack) * (t / attack)  -- Quadratic attack for smoother start
        else
            -- Much slower exponential decay for smoother sound
            envelope = math.exp(-(t - attack) * 2.5)
        end
        
        amplitude = amplitude * envelope * 0.5  -- Reduced amplitude for less volume
        
        -- Convert to 16-bit PCM (using most of the range but avoiding clipping)
        local sample = math.floor(amplitude * 25000)  -- Reduced maximum to avoid any potential clipping
        table.insert(samples, sample)
    end
    
    -- Create the sound file
    local file = io.open("assets/sounds/button_select.wav", "wb")
    
    -- Write WAV header
    -- RIFF header
    file:write(string.char(0x52, 0x49, 0x46, 0x46))  -- "RIFF"
    local fileSize = #samples * 2 + 36
    file:write(string.char(
        fileSize % 256,
        math.floor(fileSize / 256) % 256,
        math.floor(fileSize / 65536) % 256,
        math.floor(fileSize / 16777216) % 256
    ))
    file:write(string.char(0x57, 0x41, 0x56, 0x45))  -- "WAVE"
    
    -- Format chunk
    file:write(string.char(0x66, 0x6D, 0x74, 0x20))  -- "fmt "
    file:write(string.char(16, 0, 0, 0))  -- Chunk size
    file:write(string.char(1, 0))  -- Audio format (PCM)
    file:write(string.char(1, 0))  -- Channels (mono)
    file:write(string.char(
        sampleRate % 256,
        math.floor(sampleRate / 256) % 256,
        math.floor(sampleRate / 65536) % 256,
        math.floor(sampleRate / 16777216) % 256
    ))  -- Sample rate
    local byteRate = sampleRate * 2
    file:write(string.char(
        byteRate % 256,
        math.floor(byteRate / 256) % 256,
        math.floor(byteRate / 65536) % 256,
        math.floor(byteRate / 16777216) % 256
    ))  -- Byte rate
    file:write(string.char(2, 0))  -- Block align
    file:write(string.char(16, 0))  -- Bits per sample
    
    -- Data chunk
    file:write(string.char(0x64, 0x61, 0x74, 0x61))  -- "data"
    local dataSize = #samples * 2
    file:write(string.char(
        dataSize % 256,
        math.floor(dataSize / 256) % 256,
        math.floor(dataSize / 65536) % 256,
        math.floor(dataSize / 16777216) % 256
    ))  -- Chunk size
    
    -- Write samples
    for _, sample in ipairs(samples) do
        file:write(string.char(
            sample % 256,
            math.floor(sample / 256) % 256
        ))
    end
    
    file:close()
    print("Button sound generated successfully!")
end

generateButtonSound() 