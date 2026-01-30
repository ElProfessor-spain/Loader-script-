-- LIVE RUSSIA MOD MENU LOADER
-- FIXED VERSION - Loader Compatible
-- With Custom GG Verification

-- =============================================
-- CUSTOM GG VERIFICATION CHECK USING gg.BUILD
-- =============================================
local function verifyCustomGG()
    if not gg.BUILD then
        return false, "❌ INVALID GAMEGUARDIAN!\n\n⚠️ Cannot detect GG version\n\n📥 Download RGPH Custom GG"
    end
    
    local buildValue = tostring(gg.BUILD)
    
    if buildValue ~= "RGPH_GG28" then
        return false, "❌ INVALID GAMEGUARDIAN!\n\n⚠️ Wrong GG version\n\n🔑 Expected: RGPH_GG28\n❌ Got: " .. buildValue .. "\n\n📥 Download RGPH Custom GG"
    end
    
    return true, "✅ Verified!"
end

-- Verify immediately
local isValid, message = verifyCustomGG()

if not isValid then
    gg.alert(message)
    return
end

gg.toast(message)
-- =============================================

-- ENCRYPTED SCRIPT PASSWORD (stored internally)
local DECRYPT_PASSWORD = "ryve34567876543"

-- Your GitHub Gist RAW URL - FIXED: Added cache-busting timestamp
local function getCodesURL()
    -- Add current timestamp to bypass GitHub's cache
    return "https://gist.githubusercontent.com/ElProfessor-spain/9b1a9148b3a4eecd2c9e990197d60bc1/raw/ACCESS%20CODES?t=" .. tostring(os.time())
end

-- Social Media Links
local SOCIAL_MEDIA = {
    youtube = "https://youtube.com/@ryvegamingph",
    facebook = "https://facebook.com/ryvegamingph",
    tiktok = "to be added soon"
}

-- Contact info
local VERIFICATION_CONTACT = {
    email = "ryveph28@gmail.com",
    telegram = "comingsoon",
    discord = "comingsoon",
    facebook = "m.me/ryvegamingph"
}

-- Script URLs
local SCRIPT_URLS = {
    {name = "🌀🌀Teleport Mod Menu🌀🌀", url = "https://pastebin.com/raw/GqDPzQMX", available = true, encrypted = false},
    {name = "🔒 Mod Menu 2 - Coming Soon 🔒", url = "", available = false, encrypted = false},
    {name = "🔒 Mod Menu 3 - Coming Soon 🔒", url = "", available = false, encrypted = false}
}

-- Show permission request
gg.setVisible(false) -- Hide GG interface
gg.alert("🔴🔵 LIVE RUSSIA MOD MENU 🔵🔴\n\n📡 Internet access required\n✅ Safe to use\n\nAllow permission next")
gg.makeRequest("https://gist.githubusercontent.com")
gg.toast("✅ Ready to load scripts!")

-- Get device unique ID
local function getDeviceID()
    local id = gg.getFile():gsub("/", ""):gsub("\\", ""):gsub("%.", "")
    if #id < 8 then
        id = tostring(os.time()) .. id
    end
    local hash = 0
    for i = 1, #id do
        hash = (hash * 31 + id:byte(i)) % 1000000000
    end
    return tostring(hash)
end

-- Download codes database from GitHub Gist
local function downloadCodesDatabase()
    gg.toast("📥 Checking access...")
    
    local response = gg.makeRequest(getCodesURL())
    
    if response and response.code == 200 then
        return true, response.content
    else
        return false, "Cannot connect to server. Error: " .. tostring(response and response.code or "No response")
    end
end

-- Parse codes database
local function parseCodesDatabase(content)
    local codes = {}
    local lineCount = 0
    
    content = content:gsub("^%s*", ""):gsub("%s*$", "")
    
    gg.toast("DB Preview: " .. content:sub(1, 200))
    
    for line in (content .. "\n"):gmatch("(.-)\r?\n") do
        lineCount = lineCount + 1
        
        line = line:match("^%s*(.-)%s*$")
        
        if line ~= "" and not line:match("^#") then
            local parts = {}
            for part in (line .. "|"):gmatch("(.-)|") do
                table.insert(parts, part:match("^%s*(.-)%s*$"))
            end
            
            if #parts > 0 and parts[#parts] == "" then
                table.remove(parts)
            end
            
            if #parts >= 2 then
                local deviceId = parts[1]
                local code = parts[2]
                local expires = parts[3] or "2099-12-31"
                local username = parts[4] or "User"
                
                if deviceId:match("^%d+$") then
                    if expires == "undefined" or expires == "" or expires == "null" then
                        expires = "2099-12-31"
                    end
                    
                    codes[deviceId] = {
                        code = code:upper(),
                        expires = expires,
                        username = username
                    }
                    
                    gg.toast("Loaded: " .. deviceId .. " = " .. code)
                end
            end
        end
    end
    
    return codes, lineCount
end

-- FIXED: Fallback date function that works without internet
local function getCurrentDate()
    -- Try worldtimeapi.org first
    local response = gg.makeRequest("http://worldtimeapi.org/api/timezone/Etc/UTC")
    
    if response and response.code == 200 then
        local datetime = response.content:match('"datetime":"([^"]+)"')
        if datetime then
            local date = datetime:match("^(%d%d%d%d%-%d%d%-%d%d)")
            if date then
                return date
            end
        end
    end
    
    -- Try worldclockapi.com
    response = gg.makeRequest("http://worldclockapi.com/api/json/utc/now")
    
    if response and response.code == 200 then
        local datetime = response.content:match('"currentDateTime":"([^"]+)"')
        if datetime then
            local date = datetime:match("^(%d%d%d%d%-%d%d%-%d%d)")
            if date then
                return date
            end
        end
    end
    
    -- FIXED: Better fallback using os.date (will work with loader's override)
    if os and os.date then
        local success, result = pcall(os.date, "%Y-%m-%d")
        if success and result then
            return result
        end
    end
    
    -- Ultimate fallback - return a date far in the past so codes don't expire
    return "2020-01-01"
end

-- Check if date is expired
local function isExpired(expiryDate)
    if not expiryDate or expiryDate == "" or expiryDate == "undefined" or expiryDate == "2099-12-31" or expiryDate == "null" then
        return false
    end
    
    local expYear, expMonth, expDay = expiryDate:match("^(%d+)-(%d+)-(%d+)$")
    
    if not expYear or not expMonth or not expDay then
        return true
    end
    
    local currentDate = getCurrentDate()
    local curYear, curMonth, curDay = currentDate:match("^(%d+)-(%d+)-(%d+)$")
    
    if not curYear then
        return true
    end
    
    local expiryNum = tonumber(expYear) * 10000 + tonumber(expMonth) * 100 + tonumber(expDay)
    local currentNum = tonumber(curYear) * 10000 + tonumber(curMonth) * 100 + tonumber(curDay)
    
    return currentNum > expiryNum
end

-- Verify code
local function verifyCode(deviceID, enteredCode)
    local success, content = downloadCodesDatabase()
    
    if not success then
        return false, "❌ Cannot connect to verification server\n\n" .. content
    end
    
    if not content or content == "" then
        return false, "❌ Database is empty"
    end
    
    local codes, lineCount = parseCodesDatabase(content)
    
    local codeCount = 0
    for _ in pairs(codes) do 
        codeCount = codeCount + 1 
    end
    
    if codeCount == 0 then
        return false, "❌ No valid entries\n\nLines: " .. lineCount .. "\nContent: " .. #content .. " chars\n\nContact admin"
    end
    
    enteredCode = enteredCode:match("^%s*(.-)%s*$"):upper()
    
    gg.toast("Checking: Device=" .. deviceID .. " Code=" .. enteredCode)
    
    if not codes[deviceID] then
        for devId, data in pairs(codes) do
            if data.code == enteredCode then
                return false, "❌ Code Already Used!\n\n🔑 This code is registered to another device\n📱 Your Device:\n" .. deviceID .. "\n\n⚠️ Each code works for ONE device only!\n\nContact admin for your own code."
            end
        end
        
        return false, "❌ Device Not Registered\n\n📱 Your Device ID:\n" .. deviceID .. "\n\n⚠️ Not in database.\nFound " .. codeCount .. " entries.\n\nComplete verification first!"
    end
    
    local userData = codes[deviceID]
    
    if userData.code ~= enteredCode then
        return false, "❌ Wrong Code!\n\n📱 Device ID:\n" .. deviceID .. "\n\n⚠️ The code you entered is incorrect.\n\nContact admin if you forgot your code."
    end
    
    if isExpired(userData.expires) then
        return false, "❌ Code Expired!\n\n👤 User: " .. userData.username .. "\n📅 Expired:\n" .. userData.expires .. "\n\nContact admin for renewal"
    end
    
    return true, "👐👐 Welcome " .. userData.username .. "!👐👐\n\n🔑 Code: " .. userData.code .. "\n📅 Expires: " .. userData.expires .. "\n📱 Device: " .. deviceID
end

-- Show verification instructions
local function showVerificationInstructions()
    local deviceID = getDeviceID()
    
    gg.alert([[
🔐 ACCESS CODE VERIFICATION

To get your unique access code:

1️⃣ Subscribe/Follow all platforms:
   ▶️ YouTube - Subscribe
   📘 Facebook - Like & Follow  
   🎵 TikTok - Follow

2️⃣ Take SCREENSHOTS showing:
   ✅ YouTube subscribed
   ✅ Facebook liked/followed
   ✅ TikTok followed

3️⃣ Send screenshots + Device ID

━━━━━━━━━━━━━━━━━━━
📱 YOUR DEVICE ID:
]] .. deviceID .. [[

━━━━━━━━━━━━━━━━━━━

Press OK to continue...]])
    
    local choice = gg.choice({
        "📋 Copy Device ID",
        "▶️ Open YouTube",
        "📘 Open Facebook",
        "🎵 Open TikTok",
        "📧 View Contact Info",
        "🔐 I have my code",
        "❌ Exit"
    }, nil, "What would you like to do?")
    
    if choice == 1 then
        gg.copyText(deviceID)
        gg.alert("✅ Device ID copied!\n\n" .. deviceID .. "\n\nSend this along with your screenshots!")
        return showVerificationInstructions()
        
    elseif choice == 2 then
        gg.copyText(SOCIAL_MEDIA.youtube)
        gg.alert("📺 YouTube link copied!\n\n" .. SOCIAL_MEDIA.youtube .. "\n\nPaste it in your browser, then take a screenshot after subscribing!")
        return showVerificationInstructions()
        
    elseif choice == 3 then
        gg.copyText(SOCIAL_MEDIA.facebook)
        gg.alert("📘 Facebook link copied!\n\n" .. SOCIAL_MEDIA.facebook .. "\n\nPaste it in your browser, then take a screenshot after following!")
        return showVerificationInstructions()
        
    elseif choice == 4 then
        gg.alert("🎵 TikTok Comingsoon!\n\n")
        return showVerificationInstructions()
        
    elseif choice == 5 then
        gg.alert([[
📧 SEND YOUR VERIFICATION TO:

📧 Email: ]] .. VERIFICATION_CONTACT.email .. [[


💬 Telegram: ]] .. (VERIFICATION_CONTACT.telegram or "N/A") .. [[


🎮 Discord: ]] .. VERIFICATION_CONTACT.discord .. [[


📱 Messenger: ]] .. VERIFICATION_CONTACT.facebook .. [[


━━━━━━━━━━━━━━━━━━━
📸 Include in your message:
1. Screenshots (YT, FB, TikTok)
2. Device ID: ]] .. deviceID .. [[


⏱️ You'll receive your code within 24-48 hours!

Press OK to continue...]])
        
        local contactChoice = gg.choice({
            "📋 Copy Device ID",
            "📧 Copy Email",
            "🔙 Back"
        }, nil, "Copy information:")
        
        if contactChoice == 1 then
            gg.copyText(deviceID)
            gg.toast("✅ Device ID copied!")
        elseif contactChoice == 2 and VERIFICATION_CONTACT.email then
            gg.copyText(VERIFICATION_CONTACT.email)
            gg.toast("✅ Email copied!")
        end
        
        return showVerificationInstructions()
        
    elseif choice == 6 then
        return true
        
    elseif choice == 7 or choice == nil then
        return false
    end
end

-- Check access code
local function checkAccessCode()
    local deviceID = getDeviceID()
    
    local choice = gg.choice({
        "🔐 Enter Access Code",
        "🔙 Back to Instructions"
    }, nil, "📱 Device ID: " .. deviceID)
    
    if choice == 1 then
        local input = gg.prompt(
            {"🔐 Enter your access code:"},
            {""},
            {"text"}
        )
        
        if not input or not input[1] or input[1] == "" then
            gg.alert("⚠️ No code entered")
            return "retry"
        end
        
        local enteredCode = input[1]
        
        gg.toast("🔍 Verifying code...")
        
        local isValid, message = verifyCode(deviceID, enteredCode)
        
        gg.alert(message)
        
        if isValid then
            return "success"
        else
            return "retry"
        end
        
    elseif choice == 2 then
        return "back"
    else
        return "cancel"
    end
end

-- Download script from URL
local function downloadScript(url)
    gg.toast("📥 Loading script...")
    
    local response = gg.makeRequest(url)
    
    if response then
        if response.code == 200 then
            local content = response.content
            
            if content:match("<!DOCTYPE") or content:match("<html") then
                return false, "URL returned HTML instead of script"
            end
            
            return true, content
        else
            return false, "HTTP Error: " .. tostring(response.code)
        end
    else
        return false, "Failed to connect"
    end
end

-- Execute downloaded script with auto-password injection
local function executeScript(scriptCode)
    gg.toast("⚙️ Loading script...")
    
    local originalPrompt = gg.prompt
    gg.prompt = function(prompts, defaults, types)
        if prompts and prompts[1] and prompts[1]:match("[Pp]assword") then
            return {DECRYPT_PASSWORD}
        else
            return originalPrompt(prompts, defaults, types)
        end
    end
    
    local func, err = load(scriptCode)
    
    if func then
        local success, result = pcall(func)
        
        gg.prompt = originalPrompt
        
        if success then
            return true, "Script executed successfully!"
        else
            local errorMsg = tostring(result)
            if errorMsg:match("exit") then
                return true, "Script exited normally"
            else
                return false, "Execution error: " .. errorMsg
            end
        end
    else
        gg.prompt = originalPrompt
        return false, "Failed to load: " .. tostring(err)
    end
end

-- Main menu
local function showMenu()
    local menuItems = {}
    
    for i, script in ipairs(SCRIPT_URLS) do
        table.insert(menuItems, script.name)
    end
    
    table.insert(menuItems, "❌ Exit")
    
    local choice = gg.choice(menuItems, nil, "🔴🔵 LIVE RUSSIA MOD MENU 🔵🔴")
    
    return choice
end

-- Main program
local function main()
    local verified = false
    local attempts = 0
    local maxAttempts = 3
    
    while not verified do
        local showInstructions = showVerificationInstructions()
        
        if not showInstructions then
            gg.alert("❌ Verification cancelled!")
            -- FIXED: Use return instead of os.exit()
            return
        end
        
        while attempts < maxAttempts and not verified do
            local result = checkAccessCode()
            
            if result == "success" then
                verified = true
                break
            elseif result == "back" then
                break
            elseif result == "cancel" then
                gg.alert("❌ Cancelled!")
                -- FIXED: Use return instead of os.exit()
                return
            elseif result == "retry" then
                attempts = attempts + 1
                if attempts < maxAttempts then
                    gg.alert("❌ Failed\n\nAttempts left: " .. (maxAttempts - attempts))
                end
            end
        end
        
        if attempts >= maxAttempts and not verified then
            gg.alert("❌ Max attempts reached\n\nReturning to instructions...")
            attempts = 0
        end
    end
    
    -- Main loop
    while true do
        gg.clearResults()
        
        local choice = showMenu()
        
        if not choice or choice > #SCRIPT_URLS then
            gg.alert("👋 Thank you for using LIVE RUSSIA MOD MENU!\n\n🔴🔵 Don't forget to like and share! 🔵🔴")
            break
        end
        
        local selectedScript = SCRIPT_URLS[choice]
        
        if not selectedScript.available then
            gg.alert("🔒 Coming soon!\n\n📺 Subscribe for updates!")
        else
            local success, scriptCode = downloadScript(selectedScript.url)
            
            if success then
                gg.alert("🎉🎉CONGRATULATIONS🎉🎉\n\n\n ✅ Mod loaded!\n\nPress ok to Execute...")
                
                local execSuccess, message = executeScript(scriptCode)
                
                if execSuccess then
                    gg.toast("✅ " .. message)
                else
                    gg.alert("❌ Error:\n" .. message)
                end
            else
                gg.alert("❌ Failed:\n" .. scriptCode)
            end
        end
    end
end

-- Run the loader
main()

-- FIXED: Removed os.exit() - script will end naturally when main() returns
