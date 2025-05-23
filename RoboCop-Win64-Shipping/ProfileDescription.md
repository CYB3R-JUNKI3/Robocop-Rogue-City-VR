6DOF Motion Controller UEVR Profile + VR Fix Mod


## IMPORTANT
### The following UEVR settings are controlled by the Mod
- Rendering Method
- Aim Method
- GhostingFix
- D-Pad Shifting Method
- DecoupledPitchUIAdjust
- UI Distance
- UI Size
----

## Customizations
#### Custom UEVR D-Pad Activation Method

<details>

<summary>How to configure custom UEVR D-Pad activation </summary>

1)  Open the file "RoboCop-Win64-Shipping\scripts\RoboCop_VR_CJ117.lua" with any text editor
2)  Go to line 13 ("local D_Pad_Method = 0")
3)  Change "0" to reflect the UEVR D-Pad activation method you wish to use.
```
-- 0 = Right Thumbrest + Left Joystick
-- 1 = Left Thumbrest + Right Joystick
-- 4 = Gesture (Head) + Left Joystick
-- 5 = Gesture (Head) + Right Joystick
```
4)  Save the file.
</details>

#### Enable/Disable "Scan Fix"

<details>

<summary>How to Enable/Disable Scan Fix </summary>

1)  Open the file "RoboCop-Win64-Shipping\scripts\RoboCop_VR_CJ117.lua" with any text editor
2)  Go to line 14 ("local Enable_Scan_Fix = true")
3)  Change "true" to "false" (case sensitive) to DIS-able the Scan Fix.
4)  Save the file.
</details>

----


### Controls
- No change to game controls
- Optional plugin for Index Controllers by Markmon

#####    (Below is for folks who don't want to click their Thumb-Sticks) 

- Sprint mapped to Right Thumb-Stick ↑
- Night Vision mapped to Right Thumb-Stick ↓
#####  (In game Sprint (L3) and Night Vision (R3) still work as intended)
----


### Punch / Throw Gesture
- Perform a punching action
- Robo punch will trigger
#####  (In game Punch (Right Grip) still works as intended)
- Perform a throwing action when holding an item or enemy
- The item or enemy will be thrown
#####  (In game Throw (Right Grip/Right Trigger) still works as intended)
----


### Recenter/Re-calibrate (standing or sitting)
- Quickly press Left+Right Trigger during menus/cut-scenes/interactions
- Also resets standing height and position
- If Inventory/cut-scene/Pause screen is not centered, press Left+Right Trigger
----


### Other Features
- Fixed Shooting Gallery aiming
- Free head/controller movement in main menu/pause menu/inventory/cut-scenes/Interactions
- All dialogues have free head/controller movement
- All mid-game mini-cut cams detached from controller
- Character arms hidden
- Character arms visible during montages
- Weapon Scale/Angle fixes
- Ingame crosshair reduced to dot
- Weapon recoil/spread removed
- Most camera shake removed
- Investigation Scanner left eye glitch fixed when NOT holding a weapon
- Attached weapons to Right Controller
- Adjusted weapon positions for better feel
- Bullet spread reduced when not aiming
- Movement orientation set to Left Controller (feel free to change)
- Some cvar tweaks
- _Much more, .. Too many to list_
----


### Important Notes / FAQ's
:question: _Game crashes when Left Trigger is pressed when NOT holding a weapon_

:bulb: Disable the "Scan Fix" (see Customizations)

---
:question: _Sometimes the camera snaps when firing a weapon_

:bulb: Although most shake and recoil has been removed, some still remain, will update when fixed

---
:question: _The HUD is stuck to my head during the "Shady Meetup" mission_

:bulb: This is a work-a-round I had to settle for, you can still Aim and Shoot with your Right Motion Controller

---
:question: _How can I remove the Crosshair COMPLETELY_

:bulb: The Crosshair can be removed via the in-game settings

---

:question: _Some cut-scenes have no subtitles_

:bulb: The UI has been removed to remove black bars from cut-scenes, this means that the subtitles for those parts are also invisible

---


