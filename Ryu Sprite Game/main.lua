
--NAME JOSEPH LAMBO
local widget = require("widget")
local mode = "Low" -- This is the mode for the radio buttons. It starts on low as a default.
local punchSound = audio.loadSound("punchgrunt.wav") -- Sound for punches
local kickSound = audio.loadSound("kickgrunt.wav") -- sound for kicks
local opt =
{
	frames = {
    {x = 2, y = 14, width = 53, height = 88}, -- IDLE
   {x = 51, y = 14, width = 51, height = 88}, -- frame 2
   {x = 101,y = 14, width = 53, height = 88},-- frame 3
   {x = 150, y = 14, width = 53, height = 88}, -- frame 4
   {x = 201, y = 14, width = 51, height = 88}, -- WALKING
   {x = 248, y = 14, width = 51, height = 88}, -- frame 6
   {x = 297, y = 14, width = 53, height = 88}, -- frame 7
   {x = 347, y = 14, width = 53, height = 88}, -- frame 8
   {x = 397, y = 14, width = 53, height = 88}, -- frame 9
   {x = -1, y = 130, width = 51, height = 88}, -- L PUNCH
   {x = 48, y = 130, width = 64, height = 88}, -- frame 11
   {x = 113, y = 130, width = 53, height = 88}, -- frame 12
   {x = 166, y = 130, width = 51, height = 88}, -- H PUNCH
   {x = 217, y = 130, width = 53, height = 88}, -- frame 14
   {x = 273, y = 130, width = 80, height = 88}, -- frame 15
   {x = 352, y = 130, width = 55, height = 88}, -- frame 16
   {x = 407, y = 130, width = 55, height = 88}, -- frame 17
   {x = 0, y = 261, width = 59, height = 88}, -- L/M KICK
   {x = 68, y = 261, width = 67, height = 88}, -- frame 19
   {x = 129, y = 261, width = 57, height = 88}, -- frame 20
   {x = 191, y = 259, width = 54, height = 90}, -- H KICK
   {x = 245, y = 259, width = 59, height = 90}, -- frame 22
   {x = 304, y = 259, width = 78, height = 90}, -- frame 23
   {x = 378, y = 267, width = 66, height = 82}, -- frame 24
   {x = 444, y = 267, width = 58, height = 82}, -- frame 25
	}
}  --Frames for the Ryu character. The L/M Kick is erratic and does not line up with other shadows without cutting off a significant portion of its shoulder.
local sheet = graphics.newImageSheet( "Ryu.png", opt);



local seqData = {
	{name = "Idle", start = 1, count = 4, time=700},
	{name = "Walking", start=5, count = 5, time=700}, 
	{name = "L Punch", start=10, count = 3, time=700},
	{name = "M Punch", start=13, count = 5, time=700}, 
	{name = "L Kick", start=18, count = 3, time=700},
	{name = "H Kick", start=21, count = 5, time=700},
}
local background = display.newImage("boxing_ring.png") --image for background
background.xScale = 3
background.yScale = 3
background.x = display.contentCenterX
background.y = display.contentCenterY-100 --required to get the specific part of background with the arena
local anim = display.newSprite (sheet, seqData); --generate the sprite
anim.anchorX = 0
anim.anchorY = 1 --anchor at bottom left position
anim:setSequence("Idle");
anim:play() 
anim.x = 215 -- Coordinate for middle of the screen
anim.y = 180

local function lowRadioPress(event) --Function for when the "Low" radio is switched on
    mode = "Low"
    print("System mode set to "..mode)
end


local function highRadioPress(event) --Function for when the "High" radio is switched on
    mode = "High"
    print("System mode set to "..mode) 
end

local function punchPressed(event) --Function for when the Punch Button is Pressed
    audio.play(punchSound)
    if(mode == "High") then 
        anim:setSequence("M Punch")
        anim:play()
       
    elseif (mode == "Low") then
        anim:setSequence("L Punch")
        anim:play()
        
    end
end

local function kickPressed(event) --Function for when the Kick Button is Pressed
    audio.play(kickSound)
    if(mode == "High") then 
        anim:setSequence("H Kick")
        anim:play()
       
    elseif (mode == "Low") then
        anim:setSequence("L Kick")
        anim:play()
        
    end
end


local radioGroup = display.newGroup( ) --Create group for radio buttons
local radioBox = display.newRoundedRect( radioGroup, 80, 240, 100, 110, 5 )
local lowText = display.newText( radioGroup, "Low", 105, 215, 'New Times Roman', 15 ) -- Text for radio buttons
local highText = display.newText( radioGroup, "High", 105, 270, 'New Times Roman', 15 ) -- Text for radio buttons
radioBox.strokeWidth = 4
radioBox.alpha = 0.2 --set it to near transparent

local lowRadio = widget.newSwitch({
        left = 50,
        top = 200,
        style = "radio",
        id = "lowRadio",
        initialSwitchState = true,
        onPress = lowRadioPress
    }) -- Generate the "Low" option for the radio

radioGroup:insert(lowRadio)

local highRadio = widget.newSwitch({
        left = 50,
        top = 250,
        style = "radio",
        id = "highRadio",
        onPress = highRadioPress
    }) -- Generate the "High" option for the radio

radioGroup:insert(highRadio)

local punchButton = widget.newButton( {
        left = 200,
        top = 180,
        shape = "roundedRect",
        width = 100,
        height = 30,
        alpha = 0.1,
        id = "punchButton",
        label = "Punch",
        onPress = punchPressed
    } ) -- Create the Punch Button

local kickButton = widget.newButton( {
        left = 350,
        top = 180,
        shape = "roundedRect",
        width = 100,
        height = 30,
        alpha = 0.1,
        id = "kickButton",
        label = "Kick",
        onPress = kickPressed
    } ) -- Create the Kick Button

local function sizeListener(event) --Function to alter the size of the sprite
    print (anim.xScale)
    anim.xScale = (event.value * (29/100))+1 --[[The formula for scale is the (slider value *29/100) +1,
     so a slider value of 0 gives (0*29/100) +1 which is 1, and a slider value of 100 gives (100*29/100) +1 which is 30.]] 
    anim.yScale = (event.value * (29/100))+1
    print (anim.xScale)
end

local sizeText = display.newText("Size", 180, 230, 'New Times Roman', 15 )
local sizeSlider = widget.newSlider({
    top = 210,
    left = 210,
    orientation = "horizontal",
    width = 300,
    value = 0,
    listener = sizeListener

    }) --Size slider generation

local function hMoveListener(event) --Function to alter the horizontal positioning of the sprite
    if (event.phase == "began") then
        anim:setSequence("Walking")
        anim:play()
    end 
    anim.x = (event.value*4.9)-30 -- This formula was gotten due to the bounds of the screen being -30 for leftmost bound and 460 for rightmost bound (0-490)
    if (event.phase == "ended") then 
        anim:setSequence("Idle")
        anim:play()
    end 
end


local hMoveText = display.newText("H. Move", 180, 260, 'New Times Roman', 15 )
local hMoveSlider = widget.newSlider({
    top = 240,
    left = 210,
    orientation = "horizontal",
    width = 300,
    listener = hMoveListener

    }) --H. Move Slider generation

local function rotateListener(event) -- Function to rotate sprite
    local spin = event.value*3.6 --This sets the value from 0-360
    spin = spin-anim.rotation --To ensure the sprite can rotate in both directions
    anim:rotate(spin)
end
local rotateText = display.newText("Rotate", 180, 290, 'New Times Roman', 15 )
local rotateSlider = widget.newSlider({
    top = 270,
    left = 210,
    orientation = "horizontal",
    width = 300,
    value = 0,
    listener = rotateListener

    }) -- Rotate Slider Generation