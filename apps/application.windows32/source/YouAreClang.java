import processing.core.*; 
import processing.xml.*; 

import processing.opengl.*; 
import arb.soundcipher.*; 
import arb.soundcipher.constants.*; 
import SimpleOpenNI.*; 
import controlP5.*; 

import java.applet.*; 
import java.awt.Dimension; 
import java.awt.Frame; 
import java.awt.event.MouseEvent; 
import java.awt.event.KeyEvent; 
import java.awt.event.FocusEvent; 
import java.awt.Image; 
import java.io.*; 
import java.net.*; 
import java.text.*; 
import java.util.*; 
import java.util.zip.*; 
import java.util.regex.*; 

public class YouAreClang extends PApplet {

// You Are Clang
// A project by Martin Ecker and Julian Henschel
// 06/1011







SimpleOpenNI kinect;
ControlP5 controlP5;

int         w = 1440;
int         h = 900;

int         projection = 0;
int         sections = 4;
boolean     showControls;
ArrayList   lightList;
int       bgc = color(0);

// calibration settings
float       kinnect_to_front = 1000;
float       kinnect_to_back = 4000;
float       kinnect_to_left = -800;
float       kinnect_to_right = 800;

// beats
int[][]     beats = { { 1,1,1,1 }, { 1,0,1,0 }, {1,1,0,0}, {0,0,1,1} };

// load font
PFont font;

public void setup() {

  size(w,h,OPENGL);
  hint(ENABLE_OPENGL_4X_SMOOTH);
  
  frameRate(60);
  
  font = loadFont("ArialMT-48.vlw"); 
  
  /* ---------------------------------------------------------------------------- */

  lightList = new ArrayList();
  
  /* ---------------------------------------------------------------------------- */
  
  // controlP5 setup
  
  controlP5 = new ControlP5(this);
  showControls = false;
  
  Radio r = controlP5.addRadio("projection",40,40);
  r.add("Frontprojection",0);
  r.add("Sideprojection",1);
  
  controlP5.addSlider("kinnect_to_front",0,7000,kinnect_to_front,40,80,250,20).setLabel("Kinect -> front");
  controlP5.addSlider("kinnect_to_back",0,7000,kinnect_to_back,40,110,250,20).setLabel("Kinect -> back");
  controlP5.addSlider("kinnect_to_left",-2000,2000,kinnect_to_left,40,140,250,20).setLabel("Kinect -> left");
  controlP5.addSlider("kinnect_to_right",-2000,2000,kinnect_to_right,40,170,250,20).setLabel("Kinect -> right");
  
  /* ---------------------------------------------------------------------------- */
  
  // simpleOpenNI object
  
  kinect = new SimpleOpenNI(this);
  kinect.setMirror(true);
  kinect.enableDepth();
  kinect.enableUser(SimpleOpenNI.SKEL_PROFILE_ALL);
  
  /* ---------------------------------------------------------------------------- */
    
}

public void draw() {
  
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
        
        theX = map(pos.z, kinnect_to_front, kinnect_to_back, -width/2, width/2);
        theY = map(pos.x, kinnect_to_left, kinnect_to_right, -height/2, height/2);
      
      }else if(projection == 1) {
        
        theX = map(pos.x, kinnect_to_left, kinnect_to_right, -width/2, width/2);
        theY = map(pos.z, kinnect_to_front, kinnect_to_back, -height/2, height/2);
      }
      
      if (pos.z < kinnect_to_back) {
  
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
  strokeWeight(.5f);
  
  for(int i = 1; i < sections; i++) {
    line(0,section_height*i,width,section_height*i);
  }
    
  /*
  fill(255);
  smooth();
  
  for(int i = 1; i < sections*2; i+=2) {
    text("Bereich"+i, width-100, (section_height/2)*i); 
  }
  */
    
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
public void onNewUser(int userId) {

  lightList.add(new Light(userId));
}

// remove object from lightlist
public void onLostUser(int userId) {

  for (int i = lightList.size()-1; i >= 0; i--) {

    Light light = (Light) lightList.get(i);

    if (light.userId == userId) {
      lightList.remove(i);
    }
  }
  
}
class Light {
 
  PVector     position, direction;
  ArrayList   lightWay;
    
  float       startDeg = 0.0f;
  float       endDeg = 180.0f;
  float       startDeg2 = 180.0f;
  float       endDeg2 = 360.0f;
  float       spinRotationAngle = 2.5f;
  
  int       c;
  
  int         instrument,userId;
  int         currentBeatSection = 0;
  int         currentBeatIndex = 0;
    
  boolean     drawLightWay = true;
  
  SoundCipher sc;
  particleSystem ps;
  
  // light constructor   
  Light(int id) {
     
    position = new PVector();
    direction = new PVector();
    
    userId = id;
    
    ps = new particleSystem(position.x,position.y,c);
    
    sc = new SoundCipher();
    sc.instrument(random(127));
    
    lightWay = new ArrayList();
  }
  
  // set color of ellipse and particles
  // code snippet from hakim.se
  public void setColor() {
  
    float centerX = width/2;
    
    int r = 63 + Math.round( ( 1 - Math.min( position.x / centerX, 1 ) ) * 189 );
    int g = 63 + Math.round( Math.abs( (position.x > centerX ? position.x-(centerX*2) : position.x) / centerX ) * 189 );
    int b = 63 + Math.round( Math.max(( ( position.x - centerX ) / centerX ), 0 ) * 189 );

    c = color(r,g,b);
  }
  
  // play sound
  public void soundUpdate() {
    
    if(currentBeatSection > 0) {
    
      if(beats[currentBeatSection-1][currentBeatIndex] == 1) {
        
        float pitch = map(position.x, kinnect_to_left, kinnect_to_right, 10, 117);
        
        sc.playNote(pitch, 100, 0.5f);
        ps.reset();
      }
    }

    currentBeatIndex++;
    
    if(currentBeatIndex > 3) {
      currentBeatIndex = 0;
    }
    
  }
  
  // set beat section (1-4)
  public void setBeatSection() {
    
    if(position.y < -height/sections && position.y > -height) {
      currentBeatSection = 1;
    }else if(position.y < 0 && position.y > -height/sections) {
      currentBeatSection = 2;
    }else if(position.y > 0 && position.y < height/sections) {
      currentBeatSection = 3;
    }else if(position.y > height/sections && position.y < height) {
      currentBeatSection = 4;
    }else {
      currentBeatSection = 0;
    }
    
  }
  
  // display the light on current position
  public void display(float x, float y) {

    position.x = x;
    position.y = y;
    
    setColor();
    setBeatSection();
    drawLightWay();
    
    ps.update(position.x,position.y,c);
    
    int arc_radius = 120;
    
    noStroke();
    fill(c,95);
    
    arc(position.x, position.y, arc_radius, arc_radius, radians(startDeg2), radians(endDeg2) );
    arc(position.x, position.y, arc_radius, arc_radius, radians(startDeg), radians(endDeg) );
        
    startDeg += spinRotationAngle;
    endDeg += spinRotationAngle;

    startDeg2 -= spinRotationAngle;
    endDeg2 -= spinRotationAngle;
    
  }
  
  // draw way of light
  public void drawLightWay() {
    
    if(drawLightWay) {
      
      int lightWaySteps = 10;
             
      for (int i = lightWay.size() -1; i >= 0; i -= lightWaySteps) {
        
        PVector waypoint = (PVector) lightWay.get(i);
        
        stroke(c);
        strokeWeight(2);
        point(waypoint.x,waypoint.y);
      }
      
      lightWay.add(new PVector(position.x, position.y, position.z));
    }
  }
  
}
// particles by Claudio Gonzales
// http://www.openprocessing.org/visuals/?visualID=2357

public class particle {
   
  float x;
  float y;
  float px;
  float py;
  float magnitude;
  float angle;
  float mass;
   
  particle( float dx, float dy, float V, float A, float M ) {
    x = dx;
    y = dy;
    px = dx;
    py = dy;
    magnitude = V;
    angle = A;
    mass = M;
  }
   
  public void reset( float dx, float dy, float V, float A, float M ) {
    x = dx;
    y = dy;
    px = dx;
    py = dy;
    magnitude = V;
    angle = A;
    mass = M;
  }
   
  public void gravitate( particle Z ) {
    float F, mX, mY, A;
    if( sq( x - Z.x ) + sq( y - Z.y ) != 0 ) {
      F = mass * Z.mass;
      //if( sq( x - Z.x ) + sq( y - Z.y ) > 1 ) {
        F /= sq( x - Z.x ) + sq( y - Z.y );
      //}
      mX = ( mass * x + Z.mass * Z.x ) / ( mass + Z.mass );
      mY = ( mass * y + Z.mass * Z.y ) / ( mass + Z.mass );
      A = findAngle( mX - x, mY - y );
       
      mX = F * cos(A);
      mY = F * sin(A);
       
      mX += magnitude * cos(angle);
      mY += magnitude * sin(angle);
       
      magnitude = sqrt( sq(mX) + sq(mY) );
      angle = findAngle( mX, mY );
    }
  }
   
  public void deteriorate() {
    magnitude *= 0.999f;
  }
   
  public void update() {
     
    x += magnitude * cos(angle);
    y += magnitude * sin(angle);
  }
   
  public void display() {
    line(px,py,x,y);
    px = x;
    py = y;
  }
}
 
public float findAngle( float x, float y ) {
  float theta;
  if(x == 0) {
    if(y > 0) {
      theta = HALF_PI;
    }
    else if(y < 0) {
      theta = 3*HALF_PI;
    }
    else {
      theta = 0;
    }
  }
  else {
    theta = atan( y / x );
    if(( x < 0 ) && ( y >= 0 )) { theta += PI; }
    if(( x < 0 ) && ( y < 0 )) { theta -= PI; }
  }
  return theta;
}

public class particleSystem {
  
  PVector position;
  ArrayList particles;
  
  int particleCount = 100;
  int time = 1;
  int c;
  
  // particleSystem constructor
  particleSystem(float theX, float theY, int c) {
       
    position = new PVector(theX,theY);
    particles = new ArrayList();
    
    c = c;
        
    for(int i = 0; i < particleCount; i++) {
      
      float r, phi, x, y, xx, yy;
      r = random(8)+10;

      phi = random(TWO_PI);
      
      x = position.x+r*cos(phi);
      y = position.y+r*sin(phi);
      
      xx = position.x+r*cos(phi+0.1f);
      yy = position.y+r*sin(phi+0.1f);
      
      particles.add(new particle( x, y, 10, findAngle(x-xx,y-yy), 1 ));
    }
    
  }
  
  // update particles
  public void update(float x, float y, int cl) {
    
    c = cl;
    
    position.x = x;
    position.y = y;
    
    float r;

    for (int i = particles.size()-1; i >= 0; i--) { 
      
      particle p = (particle) particles.get(i);
      
      p.gravitate( new particle( position.x, position.y, 0, 0, 1000 ) );
      p.deteriorate();
      p.update();
      
      r = PApplet.parseFloat(i) / particleCount;
           
      stroke( c, 200 );
            
      p.display();
    }
    
  }
  
  // reset particles
  public void reset() {
    
    for (int i = particles.size()-1; i >= 0; i--) {
      
      particle p = (particle) particles.get(i);
      
      float r, phi, x, y, xx, yy;
      r = random(8)+10;

      phi = random(TWO_PI);
      
      x = position.x + r*cos(phi);
      y = position.y + r*sin(phi);

      xx = position.x + r*cos(phi+0.01f);
      yy = position.y + r*sin(phi+0.01f);

      p.reset(x, y, 10, findAngle(x-xx,y-yy), 1);
    }
    
  }
}
  static public void main(String args[]) {
    PApplet.main(new String[] { "--present", "--bgcolor=#666666", "--hide-stop", "YouAreClang" });
  }
}
