### Disclaimer ###
I DO NOT PLAY WOW ANY LONGER AND HAVE NOT LOOKED AT THIS CODE IN ALMOST A DECADE.  However, it was popular at the time and I offer it here for anyone to take over assuming you cannot get the code for it from CurseForge or WoWInterface.  This code may also not be the latest version because I vaguely remember handing the reigns off to someone that wanted to continue maintaining it until the game update that scaled dot damage came out.

Kressilac

# ShadowPriestDotTimers
Public upload of the Classic WoW addon I created during Wrath of the Lich King and Cataclysm

What The Addon Accomplishes
I've used Danina's Shadow Timer addon for a while and liked it enough to tweak it for my own raiding use. Here's the gist of what I tried to solve. Credit has to go to Danina for the initial inspiration. http://wow.curse.com/downloads/wow-addons/details/shadowtimers.aspx

When should I refresh my DoTs. With all the proccs I never quite knew when the right time was to refresh a DoT, namely SW:P and VT. That's where this addon comes into play.

Most procs give you an amount of a stat for a duration. For instance, Volcanic Potion grants a buff called Volcanic Power which gives 1200 Int for 25 seconds. Moonwell Chalice gives an amount of Mastery for 12 seconds. You get the idea. So SPDT tells you to refresh your dots with procs. 20 seconds into a fight, procs feel random with no real way to discern if a proc is a DPS upgrade. What I've done is use HowToPriest.com BiS scaling numbers to convert a buff to it's Int equivalency and created what I refer to as a "buff score". As of 1.0c all of this data is configurable in the options panel under Blizzard's Interface-AddOns tab.

There are two bufftables. One that the user has to fill depending on his trinkets and upgraded versions, which can be managed via the ingame menu. The other bufftable is hidden and i call it class/standard buff table.

The class/standard buff table contains of the following buffs:
Heroism
Bloodlust
Time Warp
Ancient Hysteria
Potion of the Jade Serpent
Lifeblood
Synapse Spring
Power Infusion
Berserking
Windsong
Jade Spirit
Tempus Repit (Legendary Meta Gem Proc)
Twist of Fate
Fluidity in ToT 1.Boss
Primal Nutriment in ToT 6.Boss
Tricks of the Trade (Rogue)
Fearless in ToeS 4. Boss(Sha)
Lightweave Embroidery
An example list for ingame bufflist could look like this:
Volcanic Potion is worth 1200
Volcanic Destruction 1600
Power Torrent 500
Moonwell Chalice (1700 * .48) or 816
Necromantic Focus (39 * .51) * stacks or 20 to 200
Combat Mind 88 Int stacks 10 times.
Velocity 3278 Haste
The key is that when you cast SW:P or VT, the current buff score is copied to the top of the icon showing its cooldown. You can then use that number to figure out if refreshing a DoT would be a DPS increase or decrease. Of course, refreshing seconds before a proc wears off is always beneficial and therefore the icon will turn green. The buff score is not intended to be an accurate reflection of actual damage numbers. It's there so that you can judge the relative difference between when you first cast a DoT and your current buff level. Higher numbers recast. Lower numbers wait until you have to refresh it. I added some more options in the latest version, so that you can define your own buffscore offset to turn green, when your current buffscore is higher than the buffscore when you applied the DoT. You can now also set if the whole icon will turn green or only the numbers above. Also everything can be hidden.

Slash Commands
/spdt (scale1 | scale2 | scale3 | scale4 | scale5 | scale6)
/spdt (show | hide | reset | configmode | noconfigmode | options | clear)
Options:
show: Show the addon.
hide: Prevents the addon from displaying on the screen. Useful when you switch to Disc/Holy
reset: Used to recycle the display of the addon. Can help if there's a glitch in the display.
configmode: Enables a frame around the addon's visible elements so that the entire frame can be positioned.
noconfigmode: Enables the addon for play and removes the frame created during configmode.
scale1 - 6: Resizes the visible elements of the addon.
options: Displays the option panel in the Blizzard Interface Option screen.
clear: Clears the internal mob list that tracks DoTs on multiple targets.
Recent Enhancements from comments:
Add an icon for Mind Blast Cooldown
Add display of PowerInfusion and Vampiric Embrace and all talent of Tier 3 and 5
Add a check for the actual class is a Priest with Shadow specialization
Add a coloring option to color the buff score of SW:P above an icon when recasting is a DPS increase or decrease.
Add SW:D, when the target is applicable for it
Swapped order of SW:P and DP displaying
Increased size of counters for SW:P, DP, VT and MB
Changed color or SW:P Counter
Changed behaviour of icon coloring
Added sorting of the bufflist after adding of one entry
Added support for UVLS
Added display, which buff has been deleted in the bufflist
Added option to hide DP
Added options to hide the icons seperatly
Added options to hide the numbers above the icons seperatly
Added options to hide the timer of the icons seperatly
Added option to hide the buffscore
Added option to show UVLS icon on proc on buffscore position
Added options to show everything out of combat
Future enhancements:
User changeable order of the DoTs.
Ruled out Enhancements:
Adding a timer for buff score - In practice I didn't find the information to be useful because when you added up the buffs, the score might change 5 times in less than a second making the velocity of the information useless in an already fast moving UI addon.
