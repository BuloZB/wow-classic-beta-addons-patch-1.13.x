local MIN_ALPHA = .4

-- we dont care about cvar mapFade and mousehovering over the worldmapframe
PlayerMovementFrameFader.AddDeferredFrame(WorldMapFrame, MIN_ALPHA, 1.0, .5)
