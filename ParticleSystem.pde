class ParticleSystem {
  
  int particles = 500;
  int[] dest = new int[particles];
  
  Node[] nodeList;

  ParticleSystem() {
    
    // init particles
    nodeList = new Node[particles];
    
    // init positions
    for(int i = 0; i < particles; i++) {
      
      nodeList[i] = new Node(); 
     
      this.nodeList[i].maxVelocity = random(3,8);
      this.nodeList[i].setBoundary(0,0,width,height);
      this.nodeList[i].damping = 0.004;
     
      // reset destination 
      dest[i] = -1;
    }
    
  }
  
  void update() {
    
    if(lightList.size() > 0) {
      
      println("test");
      
      for(int i = 0; i < particles; i++) {
        
        if(dest[i] == -1) {
          getRandomDestination(i);
        }
        
        PVector destination = getLightPositionFromUserId(dest[i]);
        
        if(destination.x == 0 && destination.y == 0) {
          dest[i] = -1;
          break;
        }
        
        PVector position = new PVector(nodeList[i].x,nodeList[i].y);
        PVector acceleration;
        
        PVector dir = PVector.sub(destination,position);
                dir.normalize();
                dir.mult(random(0.1,0.5));
                
        acceleration = dir;
    
        nodeList[i].velocity.add(acceleration);
        nodeList[i].velocity.limit(10);
        
        position.add(nodeList[i].velocity);
        
        nodeList[i].x = position.x;
        nodeList[i].y = position.y;

        float distance = PVector.dist(destination,position);
        
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
      
      //point(nodeList[i].x,nodeList[i].y);
      displayVector(nodeList[i].velocity,nodeList[i].x,nodeList[i].y,0.5);
    }
    
  } 
  
  void displayVector(PVector v, float x, float y, float scayl) {
    
    pushMatrix();
    translate(x,y);
    rotate(v.heading2D());
    
      float len = v.mag()*scayl;
      line(0,0,-len,0);
    
    popMatrix();
  }
  
  color getColor(int i) {
    
    PVector position = new PVector(nodeList[i].x,nodeList[i].y);
  
    float centerX = width/2;
    
    int r = 63 + Math.round( ( 1 - Math.min( position.x / centerX, 1 ) ) * 189 );
    int g = 63 + Math.round( Math.abs( (position.x > centerX ? position.x-(centerX*2) : position.x) / centerX ) * 189 );
    int b = 63 + Math.round( Math.max(( ( position.x - centerX ) / centerX ), 0 ) * 189 );

    return color(r,g,b);
  }
  
}
