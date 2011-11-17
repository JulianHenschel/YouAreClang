
// You Are Clang
// A project by Julian Henschel and Martin Ecker
// 07/2011

import processing.opengl.*;
import SimpleOpenNI.*;
import controlP5.*;
import fullscreen.*;
import ddf.minim.*;

SimpleOpenNI kinect;

ControlP5 controlP5;
FullScreen fs;

int bufferSize = 2048;
int buffer2 = 512;

Minim minim;

String[] backgroundSounds =       { "sounds/background/galaxy0.mp3", 
                                    "sounds/background/galaxy1.mp3", 
                                    "sounds/background/galaxy2.mp3", 
                                    "sounds/background/galaxy3.mp3", 
                                    "sounds/background/galaxy4.mp3",
                                    "sounds/background/galaxy5.mp3"
                                  };
               
AudioSample[][] foregroundSounds;

int         w = 1340;
int         h = 800;

int         projection = 0;
int         sections = 4;
int         sections_w = 6;

boolean     showControls;
boolean     debug = true;

ArrayList   lightList;
ArrayList   sounds;

color       bgc = color(0);

// calibration settings
float       kinect_to_front = 250;
float       kinect_to_back = 1500;
float       kinect_to_left = -1136;
float       kinect_to_right = 1296;

float posSlider = 0;

void setup() {

  size(w,h,OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(60);
  
  lightList = new ArrayList();
  
  minim = new Minim(this);
      
  /* ---------------------------------------------------------------------------- */
  
  // init controlP5 setup
  
  controlP5 = new ControlP5(this);
  showControls = false;
  
  Radio r = controlP5.addRadio("projection",40,40);
  r.add("Frontprojection",1);
  r.add("Sideprojection",0);
  
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
  
  //fs = new FullScreen(this); 
  //fs.enter();
  
  /* ---------------------------------------------------------------------------- */
  
  foregroundSounds = new AudioSample[4][6];
  
  foregroundSounds[0][0] = minim.loadSample("data/sounds/samples/bass/beat_1.mp3", buffer2);
  foregroundSounds[0][1] = minim.loadSample("data/sounds/samples/bass/beat_2.mp3", buffer2);
  foregroundSounds[0][2] = minim.loadSample("data/sounds/samples/bass/beat_3.mp3", buffer2);
  foregroundSounds[0][3] = minim.loadSample("data/sounds/samples/bass/beat_4.mp3", buffer2);
  foregroundSounds[0][4] = minim.loadSample("data/sounds/samples/bass/beat_5.mp3", buffer2);
  foregroundSounds[0][5] = minim.loadSample("data/sounds/samples/bass/beat_6.mp3", buffer2);
  
  foregroundSounds[1][0] = minim.loadSample("data/sounds/samples/bells/bells_1.mp3", buffer2);
  foregroundSounds[1][1] = minim.loadSample("data/sounds/samples/bells/bells_2.mp3", buffer2);
  foregroundSounds[1][2] = minim.loadSample("data/sounds/samples/bells/bells_3.mp3", buffer2);
  foregroundSounds[1][3] = minim.loadSample("data/sounds/samples/bells/bells_4.mp3", buffer2);
  foregroundSounds[1][4] = minim.loadSample("data/sounds/samples/bells/bells_5.mp3", buffer2);
  foregroundSounds[1][5] = minim.loadSample("data/sounds/samples/bells/bells_6.mp3", buffer2);
  
  foregroundSounds[2][0] = minim.loadSample("data/sounds/samples/strings/strings_1.mp3", buffer2);
  foregroundSounds[2][1] = minim.loadSample("data/sounds/samples/strings/strings_2.mp3", buffer2);
  foregroundSounds[2][2] = minim.loadSample("data/sounds/samples/strings/strings_3.mp3", buffer2);
  foregroundSounds[2][3] = minim.loadSample("data/sounds/samples/strings/strings_4.mp3", buffer2);
  foregroundSounds[2][4] = minim.loadSample("data/sounds/samples/strings/strings_5.mp3", buffer2);
  foregroundSounds[2][5] = minim.loadSample("data/sounds/samples/strings/strings_6.mp3", buffer2);
  
  foregroundSounds[3][0] = minim.loadSample("data/sounds/samples/strings/strings_1.mp3", buffer2);
  foregroundSounds[3][1] = minim.loadSample("data/sounds/samples/strings/strings_2.mp3", buffer2);
  foregroundSounds[3][2] = minim.loadSample("data/sounds/samples/strings/strings_3.mp3", buffer2);
  foregroundSounds[3][3] = minim.loadSample("data/sounds/samples/strings/strings_4.mp3", buffer2);
  foregroundSounds[3][4] = minim.loadSample("data/sounds/samples/strings/strings_5.mp3", buffer2);
  foregroundSounds[3][5] = minim.loadSample("data/sounds/samples/strings/strings_6.mp3", buffer2);
    
}

void draw() {
  
  // set background color
  fill(bgc,10);
  noStroke();
  rect(0,0,width,height);

  // update kinect
  kinect.update();

  // total user count from simpleOpenNI
  int userCount = kinect.getNumberOfUsers();
  
    
  /* ---------------------------------------------------------------------------- */
  
  // show slider
  
  if(userCount > 0) {
  
    stroke(100);
  
    line(posSlider,0,posSlider,height);
  
    posSlider += 12;
  
    if(posSlider > width) {
      
      // reset light sounds lock
      for (int i = 0; i < lightList.size(); i++) {
        Light light = (Light) lightList.get(i);
        light.playSound = true;
      }
      
      posSlider = 0;
    }
  }
  
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
      
      light.display(theX, theY);
      light.soundUpdate();
            
    }
    
  }

  /* ---------------------------------------------------------------------------- */
  
  // pop transformation matrix
  
  popMatrix();
  
  /* ---------------------------------------------------------------------------- */
  
  // show beat sections
  
  float section_height = height/sections;
  float section_width = width/sections_w;
  
  stroke(100);
  strokeWeight(.5);
  
  for(int i = 1; i < sections; i++) {
    line(0,section_height*i,width,section_height*i);
  }
  
  for(int i = 1; i < sections_w; i++) {
    line(section_width*i,0,section_width*i,height);
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

// return the number of user on scene
int userOnScene() {
  
  int user = 0;
 
  for (int i = 0; i < lightList.size(); i++) {
    
    Light light = (Light) lightList.get(i);
    
    if(light.currentBeatSection >= 0 && light.currentBeatSection_w >= 0) {
      user++;
    }
  }
  
  return user;
  
}

// add object to lightlist
void onNewUser(int userId) {
  
  if(debug) {
    println("*");
    println("add userid: "+userId);
  }

  lightList.add(new Light(userId));
}

// remove object from lightlist
void onLostUser(int userId) {

  for (int i = 0; i < lightList.size(); i++) {

    Light light = (Light) lightList.get(i);

    if (light.userId == userId) {
      
      if(debug) {
        println("*");
        println("remove userid: "+userId);
      }
      
      light.backgroundPlayer.close();
      //light.foregroundPlayer.close();      
            
      lightList.remove(i);
      
      break;
    }
  }
  
}

void stop() {
  
  if(debug) {
    println("*");
    println("stop");
  }
  
  minim.stop();
  super.stop();
}
