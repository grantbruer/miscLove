function love.conf(t)
    t.identity = nil                    -- The name of the save directory (string)
    t.version = "11.5"                -- The LÖVE version this game was made for (string)
    local major, minor, revision, codename = love.getVersion()
    if major == 0 and minor == 10 then -- It works with 0.10, too.
        t.version = major .. '.' .. minor .. '.' .. revision
    end
 
    t.window.title = "Wavy"         -- The window title (string)
    t.window.icon = nil                 -- Filepath to an image to use as the window's icon (string)
    t.window.resizable = true          -- Let the window be user-resizable (boolean)
    t.window.fullscreen = false         -- Enable fullscreen (boolean)
    t.window.fullscreentype = "desktop" -- Choose between "desktop" fullscreen or "exclusive" fullscreen mode (string)
 
    t.modules.audio = false              -- Enable the audio module (boolean)
    t.modules.joystick = false           -- Enable the joystick module (boolean)
    t.modules.physics = false            -- Enable the physics module (boolean)
    t.modules.sound = false              -- Enable the sound module (boolean)
    t.modules.touch = false              -- Enable the touch module (boolean)
    t.modules.video = false              -- Enable the video module (boolean)
end