local Games = loadstring(game:HttpGet("https://raw.githubusercontent.com/overlord66-6/Overlord-Hub/refs/heads/main/gamelister.lua"))()

for PlaceID, Execute in pairs(Games) do
    if PlaceID == game.PlaceId then
        loadstring(game:HttpGet(Execute))()
    end
end
