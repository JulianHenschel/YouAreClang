class ParticleSystem {
  
  int particles = 500;
  
  int[] dest = new int[particles];
  PVector[] pos = new PVector[particles];
  
  ParticleSystem() {
    
    // init positions
    for(int i = 0; i < particles; i++) {
      
      pos[i] = new PVector(random(-width/2,width/2),random(-height/2,height/2));  
      dest[i] = -1;
    }
    
  }
  
  void update() {
    
    if(lightList.size() > 1) {
      
      for(int i = 0; i < particles; i++) {
        
        if(dest[i] == -1) {
          getRandomDestination(i);
        }
        
        PVector destination = getLightPositionFromUserId(dest[i]);
        
        if(destination.x == 0 && destination.y == 0) {
          dest[i] = -1;
          break;
        }
        
        PVector velocity = new PVector(0,0);
        PVector acceleration;
        
        PVector dir = PVector.sub(destination,pos[i]);
                dir.normalize();
                dir.mult(random(5,15));
                
        acceleration = dir;
    
        velocity.add(acceleration);
        velocity.limit(500);
        
        pos[i].add(velocity);

        float distance = PVector.dist(destination,pos[i]);
        
        if(distance < 50) {
          getRandomDestination(i);
        }
               
      }
      
    }
  }
  
  void getRandomDestination(int index) {
    
    int[] ids = new int[lightList.size()];
    
    for(int i = 0; i < lightList.size(); i++) {
      
      Light l = (Light) lightList.get(i);
      ids[i] = l.userId;
    }
    
    int randomId = (int)random(0,lightList.size());
    
    dest[index] = ids[randomId];
    
  }
  
  PVector getLightPositionFromUserId(int id) {
    
    PVector p = new PVector(0,0);
    
    for(int i = 0; i < lightList.size(); i++) {
        
      Light l = (Light) lightList.get(i);
      
      if(l.userId == id) {
        p = l.position;
        break;
      }
    }
    
    return p;
  }
  
  void display() {
    
    update();
    
    for(int i = 0; i < particles; i++) {
      stroke(getColor(i));
      strokeWeight(1);
      point(pos[i].x,pos[i].y);
    }
    
  } 
  
  color getColor(int i) {
    
    PVector position = pos[i];
  
    float centerX = width/2;
    
    int r = 63 + Math.round( ( 1 - Math.min( position.x / centerX, 1 ) ) * 189 );
    int g = 63 + Math.round( Math.abs( (position.x > centerX ? position.x-(centerX*2) : position.x) / centerX ) * 189 );
    int b = 63 + Math.round( Math.max(( ( position.x - centerX ) / centerX ), 0 ) * 189 );

    return color(r,g,b);
  }
  
}
