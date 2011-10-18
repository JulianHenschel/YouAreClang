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
  int         currentBeatSection = 0;
  int         currentBeatIndex = 0;
    
  boolean     drawLightWay = true;
  
  particleSystem ps;
  Clang myClang;
  
  // light constructor   
  Light(int id) {
     
    position = new PVector();
    direction = new PVector();
    
    userId = id;
    
    ps = new particleSystem(position.x,position.y,c);
    
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
  
  // play sound
  void soundUpdate() {
    
    
    
  }
  
  // set beat section (1-4)
  void setBeatSection() {
    
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
  
}
