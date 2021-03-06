class Light {
 
  PVector     position, direction;
  ArrayList   lightWay;
    
  float       startDeg = 0.0;
  float       endDeg = 180.0;
  float       startDeg2 = 180.0;
  float       endDeg2 = 360.0;
  float       spinRotationAngle = 2.5;
  
  color       c;
  
  int         userId;
  int         currentBeatIndex = 0;
  int         posSlider = 0;
  int         sliderSpeed = 10;
  
  float       currentBeatSection = 0;
  float       currentBeatSection_w = 0;

  boolean     drawLightWay = false;
  boolean     playSound = true;
  boolean     isCalibrated = false;
  
  String      randomSound;
      
  // light constructor   
  Light(int id) {
     
    position = new PVector();
    direction = new PVector();
    
    userId = id;
        
    lightWay = new ArrayList();
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
  
  void update() {
    
    // check if user is calibrated 
    isCalibrated = kinect.isCalibratedSkeleton(this.userId);
    
    // update slider position
    if(sliderSpeed > 0) {
      posSlider += sliderSpeed;
    }
    
    if(posSlider > width) {
      playSound = true;
      posSlider = 0;
    }

    if(isCalibrated) {
      
      PVector rightHandPos = new PVector();
      float quality = kinect.getJointPositionSkeleton(userId, SimpleOpenNI.SKEL_RIGHT_HAND, rightHandPos);      
            
      if(quality > 0.5) {
        
        float newSliderSpeed = map(rightHandPos.y,-height/2,height/2,30,200);
        sliderSpeed = (int)newSliderSpeed;
      } 
    }
    
  }
  
  // play sound
  void soundUpdate() {
        
    // check if user is on the scene
    if(isLightOnScene()) {
      
      if(playSound) {
        
        if(touchSlider()) {
      
          if(debug) {
            println("*");
            println("verticle section: "+currentBeatSection);
            println("horizontal section: "+currentBeatSection_w);
          }
                
          if(debug) {
            println("*");
            println("play sound for user id: "+userId);
          }
          
          foregroundSounds[(int)currentBeatSection][(int)currentBeatSection_w].trigger();
                    
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
  // update color and beat section
  void display(float x, float y) {

    position.x = x;
    position.y = y;
    
    setColor();
    setBeatSection();
    drawLightWay();
        
    int arc_radius = 120;
    
    noStroke();
    fill(c,95);
    
    arc(position.x, position.y, arc_radius, arc_radius, radians(startDeg2), radians(endDeg2) );
    arc(position.x, position.y, arc_radius, arc_radius, radians(startDeg), radians(endDeg) );
    
    if(isCalibrated) {
      
      noFill();
      stroke(c,95);
      ellipse(position.x, position.y,arc_radius+20,arc_radius+20);
    }
        
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
  
  // check if user is on scene
  boolean isLightOnScene() {
    
    if(currentBeatSection >= 0 && currentBeatSection_w >= 0) {
      return true;
    }else {
      return false;
    }
    
  }
  
  // check distance to slider
  boolean touchSlider() {
         
    float distanceToSlider = dist(position.x, position.y, posSlider-width/2, position.y);
    
    if(distanceToSlider <= (sliderSpeed/2) ) {
      return true;
    }else {
      return false;  
    }
  }
  
}
