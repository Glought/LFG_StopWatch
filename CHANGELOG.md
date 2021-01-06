=== V2.1.1
* Fixed issue with Twisting Corridors

=== V2.1.0
* Added Torghast Support  
The StopWatch will start when you enter a Torghast Wing.
* The Timelog now has a "Torghast" Tab where all the Torghast Timelogs are saved
  The "Torghast Layers:" Dropdown menu lists all the layers.
  So when you finish a layer it will be listed under its layer aka Skoldus Hall (Layer 2) will be under "Layer 2"
* Fixed issue with updating the "Old time".
* Added Slash command "lfgsw_reset"  it will reset LFGSW incase of any issue (it stops the stopwatch, and sets Inprogress to false, and hides the stopwatch)

=== V2.0.0
* Its been a long time since I worked on LFG_StopWatch but I have reworked how the timelogs are saved
* Timelogs are now saved Dynamicly instead of being Hardcoded once you finish an LFG Dungeon or Raid it will be  
added to the TimeLog.

* Updated TOC to Patch 9.0.2
* Added Locale Support
* Added support for Legion,Battle for Azeroth,Shadowlands, and Timewalking Dungeons
* Added support for Timewalking and Shadowlands Raids
* TimeWalking Dungeons are listed under the Expansion its from.
* Timewalking Raids are listed under Timewalking under the Raid Tab

* Timewalking and Heroic Supported
* (Heroic) at the end of the names for heroic dungeons
* (Timewalking) at the end of TimeWalking Dungeons 

=== V1.1.3
* Fixed issue where Time Log was being updated when the LFG_Stopwatch was disabled(not addon disabled).
* Fixed the "Enable the 'Time it took complete this dungeon"Message" width.  

=== V1.1.2 Release
* Fixed a issue where Cata dungeons Timecomplete wasn't being updated.

=== V1.1.1 Beta
* Fixed a issue where the times from the classic versions of  "Scarlet Halls,Scarlet Monastery, and Scholomance" times
where being updated under the "MoP"  heroic versions.
* Fixed a issue where times like "0h:10m:20s" was considered leaser then "0h:10:7s" .
* The TimeLog is updated upon leaving the instance.
* Lowered the default delay to 15 seconds 
* Added a option to enable/disable the "Time it took to complete" message. Its enabled by default.

=== V1.1 Beta
* Added Time Log that keeps track of how long it takes to complete a dungeon and how many times you completed  the dungeon
* You can open the Time Log by clicking on the minimap button or by /lfgswtime chat command.
* Raids Time Log Will be released in a future update.    
* Changed "Enable LFG Stopwatch" to a character setting instead of global so now you can enable or disable it on any toon.

=== V1.0
     * first release
