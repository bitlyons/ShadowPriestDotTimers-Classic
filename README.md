shadow priest dot timer updated to work on cata classic. updated from 1.2b originally by Kressilac with some additional code by Bathral from later versions (mop 1.7g  and wod 1.8c) as well as my own changes

# preview without dot timers coloured #
![Preview1]([./AddOnInAction.jpg]

# preview with dot timers coloured #
![Preview2]([./AddOnInActionWithBuffColours.jpg]

# options #
![Preview3]([./OptionsScreen.PNG]
-------------

# ShadowPriestDotTimers


What The Addon Accomplishes 
I've used Danina's Shadow Timer addon for a while and liked it enough to tweak it for my own raiding use. Here's the gist of what I tried to solve. Credit has to go to Danina for the initial inspiration. https://legacy-wow.com/cata-addons/shadow-timers/

When should I refresh my DoTs. With all the proccs I never quite knew when the right time was to refresh a DoT, namely SW:P and VT. That's where this addon comes into play.

Most procs give you an amount of a stat for a duration. For instance, Volcanic Potion grants a buff called Volcanic Power which gives 1200 Int for 25 seconds. Moonwell Chalice gives an amount of Mastery for 12 seconds. You get the idea. So SPDT tells you to refresh your dots with procs. 20 seconds into a fight, procs feel random with no real way to discern if a proc is a DPS upgrade. What I've done is use HowToPriest.com BiS scaling numbers to convert a buff to it's Int equivalency and created what I refer to as a "buff score". As of 1.0c all of this data is configurable in the options panel under Blizzard's Interface-AddOns tab.

There are two bufftables. One that the user has to fill depending on his trinkets and upgraded versions, which can be managed via the ingame menu. The other bufftable is hidden and i call it class/standard buff table.

The class/standard buff table contains of the following buffs:
Heroism
Bloodlust
Time Warp
Primal Rage
Tricks of the Trade (via rogue)
Berserking 
--Professions--
Synapse Spring
Lifeblood
Lightweave Embroidery
--Consumables--
Volcanic Potion
--Enchants--
Power Torrent
Hurricane
--priest abilities--
Power Infusion
Dark Evangelism
Empowered Shadow

The key is that when you cast Devouring Plague or Vampiric Touch, the current buff score is copied to the top of the icon showing its cooldown. You can then use that number to figure out if refreshing a DoT would be a DPS increase or decrease. Of course, refreshing seconds before a proc wears off is always beneficial and therefore the icon will turn green. The buff score is not intended to be an accurate reflection of actual damage numbers. It's there so that you can judge the relative difference between when you first cast a DoT and your current buff level. Higher numbers recast. Lower numbers wait until you have to refresh it.

Slash Commands
/spdt (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)
/spdt (show | hide | reset | move | lock | options | clear)
Options:

show: Show the addon.
hide: Prevents the addon from displaying on the screen. Useful when you switch to Disc/Holy
reset: Used to recycle the display of the addon. Can help if there's a glitch in the display.
move: Enables a frame around the addon's visible elements so that the entire frame can be positioned. 
Lock: Legacy command : Enables the addon for play and removes the frame created during configmode. seeing as move adds a lock button this is more of a backup.
scale1 - 6: Resizes the visible elements of the addon.
options: Displays the option panel in the Blizzard Interface Option screen.
clear: Clears the internal mob list that tracks DoTs on multiple targets.

Ruled out Enhancements:
Adding a timer for buff score - In practice I didn't find the information to be useful because when you added up the buffs, the score might change 5 times in less than a second making the velocity of the information useless in an already fast moving UI addon.
