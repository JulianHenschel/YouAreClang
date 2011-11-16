

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

String[] backgroundSounds = { "galaxy0.mp3", "galaxy1.mp3", "galaxy2.mp3", "galaxy3.mp3", "galaxy4.mp3" };
String[] foregroundSounds = { "bumpers.wav", "ripple.wav" };

int         w = 1340;
int         h = 800;

int         projection = 0;
int         sections = 4;
int         sections_w = 6;

boolean     showControls;
boolean     debug = true;

ArrayList   lightList;

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
  
    posSlider += 4;
  
    if(posSlider > width) {
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
      
      // TODO
      // check if users go out on left, right and front
      
      if (pos.z < kinect_to_back) {
        
        light.display(theX, theY);
        
        light.soundUpdate();
        
      }
      
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

// add object to lightlist
void onNewUser(int userId) {
  
  if(debug) {
    println("*");
    println("add userid: "+userId);
  }
  
  Minim minim_bs = new Minim(this);
  Minim minim_fs = new Minim(this);
  
  lightList.add(new Light(userId, minim_bs, minim_fs));
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
      
      lightList.remove(i);
      
      break;
    }
  }
  
}
