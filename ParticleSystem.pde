public class particleSystem {
  
  PVector position;
  
  ArrayList particles;
  
  int particleCount = 100;
  int time = 1;
  
  color c;
  
  // particleSystem constructor
  particleSystem(float theX, float theY, color c) {
       
    position = new PVector(theX,theY);
    particles = new ArrayList();
    
    c = c;
        
    for(int i = 0; i < particleCount; i++) {
      
      float r, phi, x, y, xx, yy;
      r = random(8)+10;

      phi = random(TWO_PI);
      
      x = position.x+r*cos(phi);
      y = position.y+r*sin(phi);
      
      xx = position.x+r*cos(phi+0.1);
      yy = position.y+r*sin(phi+0.1);
      
      particles.add(new particle( x, y, 10, findAngle(x-xx,y-yy), 1 ));
    }
    
  }
  
  // update particles
  void update(float x, float y, color cl) {
    
    c = cl;
    
    position.x = x;
    position.y = y;
    
    float r;

    for (int i = particles.size()-1; i >= 0; i--) { 
      
      particle p = (particle) particles.get(i);
      
      p.gravitate( new particle( position.x, position.y, 0, 0, 1000 ) );
      p.deteriorate();
      p.update();
      
      r = float(i) / particleCount;
           
      stroke( c, 200 );
            
      p.display();
    }
    
  }
  
  // reset particles
  void reset() {
    
    for (int i = particles.size()-1; i >= 0; i--) {
      
      particle p = (particle) particles.get(i);
      
      float r, phi, x, y, xx, yy;
      r = random(8)+10;

      phi = random(TWO_PI);
      
      x = position.x + r*cos(phi);
      y = position.y + r*sin(phi);

      xx = position.x + r*cos(phi+0.01);
      yy = position.y + r*sin(phi+0.01);

      p.reset(x, y, 10, findAngle(x-xx,y-yy), 1);
    }
    
  }
}
