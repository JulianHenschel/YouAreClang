class Light {
 
  PVector     position, direction;
  ArrayList   lightWay;
    
  float       startDeg = 0.0;
  float       endDeg = 180.0;
  float       startDeg2 = 180.0;
  float       endDeg2 = 360.0;
  float       spinRotationAngle = 2.5;
  
  color       c;
  
  int         instrument,userId;
  
  float       currentBeatSection = 0;
  float       currentBeatSection_w = 0;
  
  int         currentBeatIndex = 0;
    
  boolean     drawLightWay = false;
  boolean     playSound = true;
  
  String      randomSound;
  
  Minim       minimBs, minimFs;
  AudioPlayer backgroundPlayer;
  AudioSample foregroundPlayer;
  
  particleSystem ps;
  
  // light constructor   
  Light(int id, Minim bs, Minim fs) {
     
    position = new PVector();
    direction = new PVector();
    
    userId = id;
    
    ps = new particleSystem(position.x,position.y,c);
    
    lightWay = new ArrayList();
    
    // init background player
    
    minimBs = bs;
    minimFs = fs;
       
    randomSound = backgroundSounds[(int)random(0, backgroundSounds.length-1)];
    
    if(debug) {
      println("*");
      println("background sound for user id "+userId+": "+randomSound); 
    }
    
    backgroundPlayer = minimBs.loadFile("data/sounds/background/"+randomSound, bufferSize);
    backgroundPlayer.play();

  }
  
  // set color of ellipse and particles
  // code snippet from hakim.se
  void setColor() {
  
    float centerX = width/2;
    
    int r = 63 + Math.round( ( 1 - Math.min( position.x / centerX, 1 ) ) * 189 );
    int g = 63 + Math.round( Math.abs( (position.x > centerX ? position.x-(centerX*2) : position.x) / centerX ) * 189 );
    int b = 63 + Math.round( Math.max(( ( position.x - centerX ) / centerX ), 0 ) * 189 );

    c = color(r,g,b);
  }
  
  // play sound
  void soundUpdate() {
    
    // background sound
    if(!backgroundPlayer.isPlaying()) {
      
      if(debug) {
        println("*");
        println("replaying background sound for user id: "+userId);
      }
      
      backgroundPlayer = minimBs.loadFile("data/sounds/background/"+randomSound);
      backgroundPlayer.play();
    }
    
    // check if user is on the scene
    if(currentBeatSection >= 0 && currentBeatSection_w >= 0) {
      
      if(touchSlider()) {
        
        if(playSound) {
      
          if(debug) {
            println("*");
            println("verticle section: "+currentBeatSection);
            println("horizontal section: "+currentBeatSection_w);
          }

          String randomFgSound = foregroundSounds[(int)random(0, foregroundSounds.length-1)];
          foregroundPlayer = minimFs.loadSample("data/sounds/samples/"+randomFgSound);
      
          if(debug) {
            println("*");
            println("play sound for user id: "+userId);
          }

          foregroundPlayer.trigger();
          
          ps.reset();
          
          playSound = false;
          
        }
      }
    }
  }
  
  // set beat section (1-4)
  void setBeatSection() {
    
    // set beat section height
    float beat_h = map(position.y,height/2,-height/2,0,sections);
    
    if(beat_h < 0 || beat_h > sections) {
      beat_h = -1;
    }
    
    currentBeatSection = (int)beat_h;
    
    // set beat section width
    float beat_w = map(position.x,-width/2,width/2,0,sections_w);
    
    if(beat_w < 0 || beat_w > sections_w) {
      beat_w = -1;
    }
    
    currentBeatSection_w = (int)beat_w;
    
  }
  
  // display the light on current position
  void display(float x, float y) {

    position.x = x;
    position.y = y;
    
    setColor();
    setBeatSection();
    drawLightWay();
    
    ps.update(position.x, position.y, c);
    
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
  void drawLightWay() {
    
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
  
  boolean touchSlider() {
         
    float distanceToSlider = dist(position.x, position.y, posSlider-width/2, position.y);
    
    if(distanceToSlider < 5) {
      return true;
    }else {
      return false;  
    }
    
  }
  
}
