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
  int         soundType;
    
  boolean     drawLightWay = true;
  
  SoundCipher sc;
  particleSystem ps;
  Clang myClang;
  
  // light constructor   
  Light(int id) {
     
    position = new PVector();
    direction = new PVector();
    
    userId = id;
    
    ps = new particleSystem(position.x,position.y,c);

    if(bassCnt == 0 ) {
      
      myClang = (Clang) clangBassList.get(int(random(clangBassList.size()-1)));
      bassCnt += 1;
      soundType = 0;
    
    }else if(bassCnt > 0 && middleCnt == 0) {
      
      myClang = (Clang) clangMiddleList.get(int(random(clangMiddleList.size()-1)));
      middleCnt += 1;
      soundType = 1;
    
    }else if(bassCnt > 0 && middleCnt > 0 && highCnt == 0) {
      
      myClang = (Clang) clangHighList.get(int(random(clangHighList.size()-1)));
      highCnt += 1;
      soundType = 2;
      
    }else {
            
      int soundId = int(random(0,2));
      
      switch(soundId) {
        case 0:
          myClang = (Clang) clangBassList.get(int(random(clangBassList.size()-1)));
          bassCnt += 1;
          soundType = 0;
          break;
        case 1:
          myClang = (Clang) clangMiddleList.get(int(random(clangMiddleList.size()-1)));
          middleCnt += 1;
          soundType = 1;
          break;
        case 2:
          myClang = (Clang) clangHighList.get(int(random(clangHighList.size()-1)));
          highCnt += 1;
          soundType = 2;
          break;
        default:
          // do nothing
          break;
      }
    }
    
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
    
    float pitchmin = 0;
    float pitchmax = 0;
    float pitch = 0 ;
    
    if(currentBeatSection > 0) {
      
      if (myClang.pitchRange=="A") {
          pitchmin = 0;
          pitchmax = 11;
      }
          
      if (myClang.pitchRange=="B") {
          pitchmin = 12;
          pitchmax = 23;
      }
  
      if (myClang.pitchRange=="C") {
          pitchmin = 24;
          pitchmax = 35;
      }
        
      if (myClang.pitchRange=="D") {
          pitchmin = 36;
          pitchmax = 47;
      }
          
      if (myClang.pitchRange=="E") {
          pitchmin = 48;
          pitchmax = 59;
      }
          
      if (myClang.pitchRange=="F") { 
          pitchmin = 60;
          pitchmax = 71;
      }       
       
      if (myClang.pitchRange=="G") {
          pitchmin = 72;
          pitchmax = 83;
      }
        
      if (myClang.pitchRange=="H") {
          pitchmin = 84;
          pitchmax = 95;
      }
      
      // TODO
      // insert calibration data to pitch (kinect_to_front, etc...)
      
      pitch = map(position.x, -800, 800, pitchmin,  pitchmax);
      //pitch = map(position.x, -800, 800, 0, 127);
      
      if(beats[currentBeatSection-1][currentBeatIndex] >= 0.0) {
        
        sc = new SoundCipher();
        
        sc.instrument(myClang.midiInstrument);
        sc.playNote(pitch,100,0.5);
        
        //sc.playNote(0,0,myClang.midiInstrument,pitch, 100, beats[currentBeatSection-1][currentBeatIndex], 0.8, 64);
        
        ps.reset();
        
      }
    }

    currentBeatIndex++;
    
    if(currentBeatIndex > 3) {
      currentBeatIndex = 0;
    }
    
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
