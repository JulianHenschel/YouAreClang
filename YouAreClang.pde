// You Are Clang
// A project by Julian Henschel and Martin Ecker
// 07/2011

import processing.opengl.*;
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

boolean     showControls;
boolean     debug = true;

ArrayList   lightList;

color       bgc = color(0);

// calibration settings
float       kinect_to_front = 1764;
float       kinect_to_back = 3808;
float       kinect_to_left = -1136;
float       kinect_to_right = 1296;

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
  
  //fs = new FullScreen(this); 
  //fs.enter(); 
  
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
          
          // CREATE SOUND HERE
          
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
  
  if(debug) {
    println("*");
    println("add userid: "+userId);
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
