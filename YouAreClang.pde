// You Are Clang
// A project by Julian Henschel, Martin Ecker and Miroslaw Brodzinski (soundfreak)
// 07/1011

import processing.opengl.*;
import arb.soundcipher.*;
import arb.soundcipher.constants.*;
import SimpleOpenNI.*;
import controlP5.*;
import fullscreen.*;

SimpleOpenNI kinect;
ControlP5 controlP5;
FullScreen fs; 

int         w = 1440;
int         h = 900;

int         projection = 0;
int         sections = 4;
int         bassCnt = 0;
int         middleCnt = 0;
int         highCnt = 0;

boolean     showControls;
ArrayList   lightList;
ArrayList   clangBassList;
ArrayList   clangMiddleList;
ArrayList   clangHighList;

color       bgc = color(0);

// calibration settings
float       kinect_to_front = 1764;
float       kinect_to_back = 3808;
float       kinect_to_left = -1136;
float       kinect_to_right = 1296;

// beats
double[][]  beats = { { 1,1,1,1 }, { 1,0,1,0 }, {1,1,0,0}, {1,0.5,0.5,1.0} };

void setup() {

  size(w,h,OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(60);

  /* ---------------------------------------------------------------------------- */

  lightList = new ArrayList();
  clangBassList = new ArrayList();
  clangMiddleList = new ArrayList();
  clangHighList = new ArrayList();

  initMidiInstruments();
  
  /* ---------------------------------------------------------------------------- */
  
  // init controlP5 setup
  
  controlP5 = new ControlP5(this);
  showControls = false;
  
  Radio r = controlP5.addRadio("projection",40,40);
  r.add("Frontprojection",0);
  r.add("Sideprojection",1);
  
  controlP5.addSlider("kinect_to_front",0,7000,kinect_to_front,40,80,250,20).setLabel("Kinect -> front");
  controlP5.addSlider("kinect_to_back",0,7000,kinect_to_back,40,110,250,20).setLabel("Kinect -> back");
  controlP5.addSlider("kinect_to_left",-2000,2000,kinect_to_left,40,140,250,20).setLabel("Kinect -> left");
  controlP5.addSlider("kinect_to_right",-2000,2000,kinect_to_right,40,170,250,20).setLabel("Kinect -> right");
  
  /* ---------------------------------------------------------------------------- */
  
  // init simpleOpenNI object
  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  /* ---------------------------------------------------------------------------- */
  
  // init fullscreen object
  
  Create the fullscreen object
  fs = new FullScreen(this); 
  fs.enter(); 
  
}

void draw() {
  
  // set background color
  fill(bgc,5);
  noStroke();
  rect(0,0,width,height);

  // update kinect
  kinect.update();

  // total user count from simpleOpenNI
  int userCount = kinect.getNumberOfUsers();
  
  /* ---------------------------------------------------------------------------- */
  
  // push transformation matrix
  
  pushMatrix();

  translate(width/2, height/2, 0);
  rotateX(radians(180));
  
  /* ---------------------------------------------------------------------------- */
  
  // show light and play sound
  
  PVector pos = new PVector();

  for (int i = 0; i < lightList.size(); i++) {
    
    Light light = (Light) lightList.get(i);
    
    kinect.getCoM(light.userId, pos);
    
    if(pos.x != 0 && pos.y != 0 && pos.z != 0) {
      
      float theX = 0;
      float theY = 0;
      
      if(projection == 0) {
        
        theX = map(pos.z, kinect_to_front, kinect_to_back, -width/2, width/2);
        theY = map(pos.x, kinect_to_left, kinect_to_right, -height/2, height/2);
      
      }else if(projection == 1) {
        
        theX = map(pos.x, kinect_to_left, kinect_to_right, -width/2, width/2);
        theY = map(pos.z, kinect_to_front, kinect_to_back, -height/2, height/2);
      }
      
      // TODO
      // check if users go out on left, right and front
      
      if (pos.z < kinect_to_back) {

        light.display(theX, theY);
  
        if(frameCount%10 == 0) {
          light.soundUpdate();
        }
      }
      
    }
    
  }

  /* ---------------------------------------------------------------------------- */
  
  // pop transformation matrix
  
  popMatrix();
  
  /* ---------------------------------------------------------------------------- */
  
  // show beat sections
  
  float section_height = height/sections;
  
  stroke(100);
  strokeWeight(.5);
  
  for(int i = 1; i < sections; i++) {
    line(0,section_height*i,width,section_height*i);
  }
  
  /* ---------------------------------------------------------------------------- */
  
  // show calibration controls
  
  if(dist(20,20,mouseX,mouseY) < 500) {
    showControls = true;
  }else {
    showControls = false;
  }
   
  if(showControls) {
    controlP5.show();
  }else {
    controlP5.hide();
  }
  
  /* ---------------------------------------------------------------------------- */

}

// add object to lightlist
void onNewUser(int userId) {

  lightList.add(new Light(userId));
}

// remove object from lightlist
void onLostUser(int userId) {

  for (int i = lightList.size()-1; i >= 0; i--) {

    Light light = (Light) lightList.get(i);

    if (light.userId == userId) {
 
      switch(light.soundType) {
        
        case 0:
          bassCnt -= 1;
          break;
        case 1:
          middleCnt -= 1;
          break;
        case 2:
          highCnt -= 1;
          break;
        default:
          // do nothing
          break; 
      }
      
      lightList.remove(i);
    }
  }
  
}

void initMidiInstruments() {
  
  // bass instruments A,B,C,D
  clangBassList.add(new Clang(31,"D")); // Guitar Harmonies
  clangBassList.add(new Clang(32,"D")); // Acoustic Bass
  clangBassList.add(new Clang(33,"D")); // Electric Bass (finger)
  clangBassList.add(new Clang(34,"D")); // Electric Bass (pick)
  clangBassList.add(new Clang(38,"D")); // Synth Bass 1
  clangBassList.add(new Clang(39,"D")); // Synth Bass 2
  clangBassList.add(new Clang(58,"D")); // Tuba
  clangBassList.add(new Clang(74,"D")); // Recorder
  clangBassList.add(new Clang(87,"D")); // Lead 8
  clangBassList.add(new Clang(88,"D")); // Pad1
  clangBassList.add(new Clang(89,"D")); // Pad2

  // middle instruments  E,F
  clangMiddleList.add(new Clang(0,"E"));  // Acoustic Grand Piano
  clangMiddleList.add(new Clang(1,"E")); // Bright Acoustic Piano
  clangMiddleList.add(new Clang(2,"E")); // Electric Grand Piano
  clangMiddleList.add(new Clang(3,"E")); // Honky-tonk Piano
  clangMiddleList.add(new Clang(4,"E")); // Electric Piano 1
  clangMiddleList.add(new Clang(5,"E")); // Electric Piano 2
  clangMiddleList.add(new Clang(6,"E")); // Harpsichord
  clangMiddleList.add(new Clang(7,"E")); // Clavinet
  clangMiddleList.add(new Clang(74,"E")); // Recorder
  clangMiddleList.add(new Clang(40,"E")); // Violin
  clangMiddleList.add(new Clang(41,"E")); // Viola
  clangMiddleList.add(new Clang(42,"E")); // Cello
  clangMiddleList.add(new Clang(43,"E")); // Contrabass
  clangMiddleList.add(new Clang(44,"E")); // Tremolo Strings
  clangMiddleList.add(new Clang(45,"E")); // Pizzicato Strings
  clangMiddleList.add(new Clang(46,"E")); // Orchestral Harp
  clangMiddleList.add(new Clang(48,"E")); // String Ensemble 1
  clangMiddleList.add(new Clang(49,"E")); // String Ensemble 2
  clangMiddleList.add(new Clang(50,"E")); // Synth Strings 1
  clangMiddleList.add(new Clang(51,"E")); // Synth Strings 2
  clangMiddleList.add(new Clang(52,"E")); // Choir Aahs
  clangMiddleList.add(new Clang(53,"E")); // Voice Oohs
  clangMiddleList.add(new Clang(55,"E")); // Orchestra Hit
  clangMiddleList.add(new Clang(57,"E")); // Trombone
  clangMiddleList.add(new Clang(65,"E")); // Alto Sax
  clangMiddleList.add(new Clang(66,"E")); // Tenor Sax
  clangMiddleList.add(new Clang(67,"E")); // Baritone Sax
  clangMiddleList.add(new Clang(68,"E")); // Oboe
  clangMiddleList.add(new Clang(80,"E")); // Lead 1 
  clangMiddleList.add(new Clang(87,"E")); // Lead 8
  clangMiddleList.add(new Clang(88,"E")); // Pad1
  clangMiddleList.add(new Clang(89,"E")); // Pad2
  clangMiddleList.add(new Clang(24,"E")); // Acoustic Nylon
  clangMiddleList.add(new Clang(25,"E")); // Acoustic Steel
  clangMiddleList.add(new Clang(29,"E")); // Acoustic Overdrive
  clangMiddleList.add(new Clang(90,"E")); // Pad3
  clangMiddleList.add(new Clang(51,"E")); // Synth Strings 2
  clangMiddleList.add(new Clang(52,"E")); // Choir Aahs
  clangMiddleList.add(new Clang(53,"E")); // Voice Oohs
  clangMiddleList.add(new Clang(84,"E")); // Lead 5
  clangMiddleList.add(new Clang(85,"E")); // Lead 6
  
  clangMiddleList.add(new Clang(30,"F")); // Disortion Guitar
  clangMiddleList.add(new Clang(56,"F")); // Trumpet
  clangMiddleList.add(new Clang(73,"F")); // Flute
  clangMiddleList.add(new Clang(74,"F")); // Recorder       
  clangMiddleList.add(new Clang(80,"F")); // Lead 1  
  clangMiddleList.add(new Clang(0,"F"));  // Acoustic Grand Piano
  clangMiddleList.add(new Clang(1,"F")); // Bright Acoustic Piano
  clangMiddleList.add(new Clang(2,"F")); // Electric Grand Piano
  clangMiddleList.add(new Clang(3,"F")); // Honky-tonk Piano
  clangMiddleList.add(new Clang(4,"F")); // Electric Piano 1
  clangMiddleList.add(new Clang(5,"F")); // Electric Piano 2
  clangMiddleList.add(new Clang(6,"F")); // Harpsichord
  clangMiddleList.add(new Clang(7,"F")); // Clavinet
  clangMiddleList.add(new Clang(8,"F")); // Celesta
  clangMiddleList.add(new Clang(9,"F")); // Glockenspiel
  clangMiddleList.add(new Clang(10,"F")); // Music Box
  clangMiddleList.add(new Clang(11,"F")); // Vibraphone
  clangMiddleList.add(new Clang(12,"F")); // Marimba
  clangMiddleList.add(new Clang(13,"F")); // Xylophone
  clangMiddleList.add(new Clang(24,"F")); // Acoustic Nylon
  clangMiddleList.add(new Clang(25,"F")); // Acoustic Steel
  clangMiddleList.add(new Clang(56,"F")); // Trumpet
  clangMiddleList.add(new Clang(60,"F")); // French Horn
  clangMiddleList.add(new Clang(64,"F")); // Soprano Sax
  clangMiddleList.add(new Clang(65,"F")); // Alto Sax
  clangMiddleList.add(new Clang(66,"F")); // Tenor Sax
  clangMiddleList.add(new Clang(67,"F")); // Baritone Sax
  clangMiddleList.add(new Clang(68,"F")); // Oboe
  clangMiddleList.add(new Clang(69,"F")); // English Horn
  clangMiddleList.add(new Clang(70,"F")); // Basson
  clangMiddleList.add(new Clang(71,"F")); // Clarinet
  clangMiddleList.add(new Clang(72,"F")); // Piccolo
  clangMiddleList.add(new Clang(74,"F")); // Recorder
  clangMiddleList.add(new Clang(75,"F")); // Pan Flute
  clangMiddleList.add(new Clang(78,"F")); // Whistle
  clangMiddleList.add(new Clang(79,"F")); // Ocarina
  clangMiddleList.add(new Clang(86,"F")); // Lead 6
  clangMiddleList.add(new Clang(87,"F")); // Lead 8
  clangMiddleList.add(new Clang(88,"F")); // Pad1
  clangMiddleList.add(new Clang(89,"F")); // Pad2
  clangMiddleList.add(new Clang(90,"F")); // Pad4
  
  // high instrument G,H,I
  clangHighList.add(new Clang(0,"G"));  // Acoustic Grand Piano
  clangHighList.add(new Clang(1,"G")); // Bright Acoustic Piano
  clangHighList.add(new Clang(2,"G")); // Electric Grand Piano
  clangHighList.add(new Clang(3,"G")); // Honky-tonk Piano
  clangHighList.add(new Clang(4,"G")); // Electric Piano 1
  clangHighList.add(new Clang(5,"G")); // Electric Piano 2
  clangHighList.add(new Clang(6,"G")); // Harpsichord
  clangHighList.add(new Clang(7,"G")); // Clavinet
  clangHighList.add(new Clang(9,"G")); // Glockenspiel
  clangHighList.add(new Clang(10,"G")); // Music Box
  clangHighList.add(new Clang(11,"G")); // Vibraphone
  clangHighList.add(new Clang(12,"G")); // Marimba
  clangHighList.add(new Clang(13,"G")); // Xylophone
  clangHighList.add(new Clang(59,"G")); // muted Trompet
  clangHighList.add(new Clang(75,"G")); // Pan Flute
  clangHighList.add(new Clang(78,"G")); // Whistle
  clangHighList.add(new Clang(79,"G")); // Ocarina
  clangHighList.add(new Clang(80,"G")); // Lead 1   
  clangHighList.add(new Clang(83,"G")); // Lead 4
  clangHighList.add(new Clang(86,"G")); // Lead 6
  clangHighList.add(new Clang(89,"G")); // Pad2

  clangHighList.add(new Clang(83,"H")); // Lead 4
  
}
