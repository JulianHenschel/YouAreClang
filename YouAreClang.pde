// You Are Clang
// A project by Julian Henschel and Martin Ecker
// 11/2011

import processing.opengl.*;
import SimpleOpenNI.*;
import controlP5.*;
import fullscreen.*;
import ddf.minim.*;

SimpleOpenNI    kinect;
ControlP5       controlP5;
FullScreen      fs;
Minim           minim;

AudioSample[][] foregroundSounds;

int         w = 1440;
int         h = 900;

int         bufferSize = 1024;
int         projection = 1;
int         sections = 4;
int         sections_w = 6;

boolean     showControls;
boolean     debug = false;
boolean     autoCalib = true;

ArrayList   lightList;

color       bgc = color(0);

// calibration settings
float       kinect_to_front = 1596;
float       kinect_to_back = 3808;
float       kinect_to_left = 624;
float       kinect_to_right = -512;

void setup() {

  size(w,h,OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(60);
    
  lightList = new ArrayList();
      
  /* ---------------------------------------------------------------------------- */
  
  // init controlP5 setup
  
  controlP5 = new ControlP5(this);
  showControls = false;
  
  Radio r = controlP5.addRadio("projection",40,40);
  r.add("Frontprojection", 1);
  r.add("Sideprojection", 0);
  
  controlP5.addSlider("kinect_to_front",0,7000,kinect_to_front,40,80,250,20).setLabel("Kinect -> front");
  controlP5.addSlider("kinect_to_back",0,7000,kinect_to_back,40,110,250,20).setLabel("Kinect -> back");
  controlP5.addSlider("kinect_to_left",-2000,2000,kinect_to_left,40,140,250,20).setLabel("Kinect -> left");
  controlP5.addSlider("kinect_to_right",-2000,2000,kinect_to_right,40,170,250,20).setLabel("Kinect -> right");
  
  /* ---------------------------------------------------------------------------- */
  
  // init simpleOpenNI object
  
  kinect = new SimpleOpenNI(this,SimpleOpenNI.RUN_MODE_MULTI_THREADED);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  /* ---------------------------------------------------------------------------- */
  
  // init fullscreen object
  
  //fs = new FullScreen(this); 
  //fs.enter();
  
  /* ---------------------------------------------------------------------------- */
  
  minim = new Minim(this);
  
  // load foreground samples 
  
  foregroundSounds = new AudioSample[4][6];
  
  foregroundSounds[0][0] = minim.loadSample("data/sounds/samples/bass/bass_1.mp3", bufferSize);
  foregroundSounds[0][1] = minim.loadSample("data/sounds/samples/bass/bass_2.mp3", bufferSize);
  foregroundSounds[0][2] = minim.loadSample("data/sounds/samples/bass/bass_3.mp3", bufferSize);
  foregroundSounds[0][3] = minim.loadSample("data/sounds/samples/bass/bass_4.mp3", bufferSize);
  foregroundSounds[0][4] = minim.loadSample("data/sounds/samples/bass/bass_5.mp3", bufferSize);
  foregroundSounds[0][5] = minim.loadSample("data/sounds/samples/bass/bass_6.mp3", bufferSize);
  
  foregroundSounds[1][0] = minim.loadSample("data/sounds/samples/space/space_1.mp3", bufferSize);
  foregroundSounds[1][1] = minim.loadSample("data/sounds/samples/space/space_2.mp3", bufferSize);
  foregroundSounds[1][2] = minim.loadSample("data/sounds/samples/space/space_3.mp3", bufferSize);
  foregroundSounds[1][3] = minim.loadSample("data/sounds/samples/space/space_4.mp3", bufferSize);
  foregroundSounds[1][4] = minim.loadSample("data/sounds/samples/space/space_5.mp3", bufferSize);
  foregroundSounds[1][5] = minim.loadSample("data/sounds/samples/space/space_6.mp3", bufferSize);
  
  foregroundSounds[2][0] = minim.loadSample("data/sounds/samples/keys/keys_1.mp3", bufferSize);
  foregroundSounds[2][1] = minim.loadSample("data/sounds/samples/keys/keys_2.mp3", bufferSize);
  foregroundSounds[2][2] = minim.loadSample("data/sounds/samples/keys/keys_3.mp3", bufferSize);
  foregroundSounds[2][3] = minim.loadSample("data/sounds/samples/keys/keys_4.mp3", bufferSize);
  foregroundSounds[2][4] = minim.loadSample("data/sounds/samples/keys/keys_5.mp3", bufferSize);
  foregroundSounds[2][5] = minim.loadSample("data/sounds/samples/keys/keys_6.mp3", bufferSize);
  
  foregroundSounds[3][0] = minim.loadSample("data/sounds/samples/lead/lead_1.mp3", bufferSize);
  foregroundSounds[3][1] = minim.loadSample("data/sounds/samples/lead/lead_2.mp3", bufferSize);
  foregroundSounds[3][2] = minim.loadSample("data/sounds/samples/lead/lead_3.mp3", bufferSize);
  foregroundSounds[3][3] = minim.loadSample("data/sounds/samples/lead/lead_4.mp3", bufferSize);
  foregroundSounds[3][4] = minim.loadSample("data/sounds/samples/lead/lead_5.mp3", bufferSize);
  foregroundSounds[3][5] = minim.loadSample("data/sounds/samples/lead/lead_6.mp3", bufferSize);
    
}

void draw() {
  
  // set background
  fill(bgc,10);
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
    
    // get light object
    Light light = (Light) lightList.get(i);
    
    // run update function
    light.update();
    
    // get center of mass
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

// return the number of users on scene
int usersOnScene() {
  
  int user = 0;
 
  for (int i = 0; i < lightList.size(); i++) {
    
    Light light = (Light) lightList.get(i);
    
    if(light.isLightOnScene()) {
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
    println("  start pose detection");
  }
  
  if(autoCalib) {
    kinect.requestCalibrationSkeleton(userId,true);
  }else {    
    kinect.startPoseDetection("Psi",userId);
  }

  lightList.add(new Light(userId));
}

// remove object from lightlist
void onLostUser(int userId) {
  
  for (int i = lightList.size()-1; i >= 0; i--) {

    Light light = (Light) lightList.get(i);

    if (light.userId == userId) {
      
      if(debug) {
        println("*");
        println("remove userid: "+userId);
      }
            
      lightList.remove(i);
      
      break;
    }
  }
  
}

// activate skeleton tracking 
void onEndCalibration(int userId, boolean successfull) {
  
  println("onEndCalibration - userId: " + userId + ", successfull: " + successfull);
  
  if(successfull)
  {
    println("User calibrated");
    kinect.startTrackingSkeleton(userId); 
  }
  else 
  { 
    println("Failed to calibrate user");
    println("  Start pose detection");
    
    kinect.startPoseDetection("Psi",userId);
  }
}

// stop application
void stop() {
  
  if(debug) {
    println("*");
    println("stop");
  }
  
  minim.stop();
  super.stop();
}
