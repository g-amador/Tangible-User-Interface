* Available options:

Images/Videos/SWFs/Google Maps:
Drag: Mouse left button pressed and drag, or pan gesture movement
Scale: Mouse left button pressed and scrool up or down, or two fingers zomm gesture
Zoom in/out: Mouse double click, or double tap gesture
Rotate: Mouse scrool up or down, or rotate gesture with two fingers  
Print: Mouse right button click
Sort: Mouse double, or touch double tap on stage background
File browser: Mouse right button click on stage background 

Fiducials 
(only for the fiducial with id 0):
add: adds virtual keyboard (buttons either using mouse or touch gestures work but no command recognition) and display
remove: deletes virtual keyboard and display 
move: virtual keyboard and display follows the fiducial object  

Fiducials (only for the fiducial with id 1):
add: adds pong game (works using mouse or touch gestures)
remove: deletes pong game
move: pong game follows the fiducial object  

Fiducials (only for the fiducial with id 2):
add: adds virtual piano (works using mouse or touch gestures)
remove: deletes virtual piano
move: virtual piano follows the fiducial object  

Network Packets Log: 'F1' key


* TO ADD:

TouchAll.as
1 - Support file open browse/print through touch/gesture events 

CustomKeyboard.as
1 - Support mouse touch move multi keys selection

Render.as
1 - bigger dimmensions resolution
2 - 3D
3 - surface tracking rendering 

Draw2Dmodel3D.as
1 - 3D rotation
2 - port to touch 


* Install and Setup

Download the following required resources:
- Adobe’s AIR, and Flash and Shockwave Players 
http://www.adobe.com/downloads/
- flashdevelop 3.3.4
http://www.flashdevelop.org/wikidocs/index.php?title=Main_Page
- tuio as3 lib 0.7.1
http://code.google.com/p/tuio-as3/downloads/list
- Flex Hero 4.5.0.17689 SDK
http://opensource.adobe.com/wiki/display/flexsdk/Download+Flex+Hero
- TouchAll API
(e-mail the authors)

After the download of all the required resources, follow these steps:
1 Install Adobe’s AIR 2.x, and Flash and Shockwave Players
2 Install flashdevelop
3 Run flashdevelop, click on Project->New Project and create a new AIR AS3 projector
4 Open the file application.xml and change the lines <application xmlns="http://ns.adobe.com/air/application/2.0"> to <application xmlns="http://ns.adobe.com/air/application/2.5">, and <version>1.0</version> to <versionNumber>1.0</versionNumber>
5 Click on Project->New Project->Output, set up the Platform->Target as Flash Player 10.1, and Edit... the Test movie->Run custom command... to $(FlexSDK)\bin\adl.exe;application.xml bin
6 On Project->New Project->Classpaths, Edit Global Classpaths add the path to your projects lib folder (e.g., G:\touch\Source Code\TouchProject\lib)
7 Copy the tuio as3 v_0_7_1 and TouchAll framework archives, to your project’s lib folder, and the unzip them
8 To test run demo project (Ctrl+Enter or F5) provided with the TouchAll framework