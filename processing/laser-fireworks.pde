// Fireworks Animation in Processing
// Converted from JavaScript canvas animation

ArrayList<Firework> fireworks;
ArrayList<Particle> particles;

float hue = 120;
int limiterTotal = 5;
int limiterTick = 0;
int timerTotal = 40;
int timerTick = 0;
boolean mousedown = false;
float mx, my;

void setup() {
  size(290, 290);
  colorMode(RGB, 255);
  background(158, 173, 161); // RGB for #9eada1
  colorMode(HSB, 360, 100, 100, 1);
  fireworks = new ArrayList<Firework>();
  particles = new ArrayList<Particle>();
}

void draw() {
  // Increase hue for color cycling
  hue += 2.0; // Increase for faster color cycling
  if (hue > 360) hue = 0;
  
  // Create trailing effect with semi-transparent #9eada1 background
  colorMode(RGB, 255);
  fill(158, 173, 161, 80); // #9eada1 with higher alpha for faster fading
  noStroke();
  rect(0, 0, width, height);
  colorMode(HSB, 360, 100, 100, 1);
  
  // Update and draw fireworks (iterate backwards for safe removal)
  for (int i = fireworks.size() - 1; i >= 0; i--) {
    Firework f = fireworks.get(i);
    f.update();
    f.display();
    
    // Check if firework reached target
    if (f.distanceTraveled >= f.distanceToTarget) {
      createParticles(f.tx, f.ty);
      fireworks.remove(i);
    }
  }
  
  // Update and draw particles (iterate backwards for safe removal)
  for (int i = particles.size() - 1; i >= 0; i--) {
    Particle p = particles.get(i);
    p.update();
    p.display();
    
    // Remove faded particles
    if (p.alpha <= p.decay) {
      particles.remove(i);
    }
  }
  
  // Auto-launch fireworks
  if (timerTick >= timerTotal) {
    if (!mousedown) {
      fireworks.add(new Firework(width/2, height, random(width), random(height/2)));
      timerTick = 0;
      // Add randomness to timerTotal: ±50%
      float base = 40;
      float factor = random(0.5, 1.5); // 50% down to 50% up
      timerTotal = int(base * factor);
    }
  } else {
    timerTick++;
  }
  
  // Launch fireworks when mouse is pressed
  if (limiterTick >= limiterTotal) {
    if (mousedown) {
      fireworks.add(new Firework(width/2, height, mx, my));
      limiterTick = 0;
    }
  } else {
    limiterTick++;
  }
}

void mouseMoved() {
  mx = mouseX;
  my = mouseY;
}

void mouseDragged() {
  mx = mouseX;
  my = mouseY;
}

void mousePressed() {
  mousedown = true;
  mx = mouseX;
  my = mouseY;
}

void mouseReleased() {
  mousedown = false;
}

// Create explosion particles at given position
void createParticles(float x, float y) {
  int particleCount = 30;
  for (int i = 0; i < particleCount; i++) {
    particles.add(new Particle(x, y));
  }
}

// Calculate distance between two points
float calculateDistance(float p1x, float p1y, float p2x, float p2y) {
  float xDistance = p1x - p2x;
  float yDistance = p1y - p2y;
  return sqrt(xDistance * xDistance + yDistance * yDistance);
}

// Firework class
class Firework {
  float x, y;           // Current position
  float sx, sy;         // Starting position
  float tx, ty;         // Target position
  float distanceToTarget;
  float distanceTraveled;
  ArrayList<PVector> coordinates;
  int coordinateCount = 3;
  float angle;
  float speed;
  float acceleration;
  float brightness;
  float targetRadius;
  
  Firework(float sx, float sy, float tx, float ty) {
    this.x = sx;
    this.y = sy;
    this.sx = sx;
    this.sy = sy;
    this.tx = tx;
    this.ty = ty;
    this.distanceToTarget = calculateDistance(sx, sy, tx, ty);
    this.distanceTraveled = 0;
    
    // Initialize trail coordinates
    this.coordinates = new ArrayList<PVector>();
    for (int i = 0; i < coordinateCount; i++) {
      this.coordinates.add(new PVector(this.x, this.y));
    }
    
    this.angle = atan2(ty - sy, tx - sx);
    this.speed = 2;
    this.acceleration = 1.05;
    this.brightness = random(50, 70);
    this.targetRadius = 1;
  }
  
  void update() {
    // Update trail coordinates
    coordinates.remove(coordinates.size() - 1);
    coordinates.add(0, new PVector(x, y));
    
    // Pulse target indicator
    if (targetRadius < 8) {
      targetRadius += 0.3;
    } else {
      targetRadius = 1;
    }
    
    // Accelerate
    speed *= acceleration;
    
    // Calculate velocity
    float vx = cos(angle) * speed;
    float vy = sin(angle) * speed;
    
    // Calculate distance traveled
    distanceTraveled = calculateDistance(sx, sy, x + vx, y + vy);
    
    // Move if not at target
    if (distanceTraveled < distanceToTarget) {
      x += vx;
      y += vy;
    }
  }
  
  void display() {
    // Draw trail
    strokeWeight(1);
    stroke(hue, 100, brightness, 0.8);
    noFill();
    
    PVector lastCoord = coordinates.get(coordinates.size() - 1);
    line(lastCoord.x, lastCoord.y, x, y);
    
    // Draw pulsing target indicator
    stroke(hue, 100, brightness, 0.5);
    ellipse(tx, ty, targetRadius * 2, targetRadius * 2);
  }
}

// Particle class
class Particle {
  float x, y;
  ArrayList<PVector> coordinates;
  int coordinateCount = 5;
  float angle;
  float speed;
  float friction;
  float gravity;
  float particleHue;
  float brightness;
  float alpha;
  float decay;
  
  Particle(float x, float y) {
    this.x = x;
    this.y = y;
    
    // Initialize trail coordinates
    this.coordinates = new ArrayList<PVector>();
    for (int i = 0; i < coordinateCount; i++) {
      this.coordinates.add(new PVector(this.x, this.y));
    }
    
    this.angle = random(TWO_PI);
    this.speed = random(1, 10);
    this.friction = 0.95;
    this.gravity = 1;
    this.particleHue = random(hue - 20, hue + 20);
    if (this.particleHue < 0) this.particleHue += 360;
    if (this.particleHue > 360) this.particleHue -= 360;
    this.brightness = random(50, 80);
    this.alpha = 1;
    this.decay = random(0.015, 0.03);
  }
  
  void update() {
    // Update trail coordinates
    coordinates.remove(coordinates.size() - 1);
    coordinates.add(0, new PVector(x, y));
    
    // Apply friction
    speed *= friction;
    
    // Apply velocity and gravity
    x += cos(angle) * speed;
    y += sin(angle) * speed + gravity;
    
    // Fade out
    alpha -= decay;
  }
  
  void display() {
    strokeWeight(1);
    stroke(particleHue, 100, brightness, alpha);
    noFill();
    
    PVector lastCoord = coordinates.get(coordinates.size() - 1);
    line(lastCoord.x, lastCoord.y, x, y);
  }
}