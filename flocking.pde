import java.util.BitSet;

int N = 2000;
int GROUPS = 4;
int MAX_GROUPS = 16;
int WIDTH = 1200;
int HEIGHT = 600;


float kS = 5;
float kA = 0.4;
float kC = 0.3;
float kD = 0.1;
float kO = 60;

float NEIGHBOUR_THRESHOLD = 40;
float AVOID_THRESHOLD = 20;
float OTHERS_THRESHOLD = 60;
float VISUALISATION_THRESHOLD = 80;

int FENCE_SIZE = 20;
int GRID_WIDTH = (int) (WIDTH/FENCE_SIZE);
int GRID_HEIGHT = (int) (HEIGHT/FENCE_SIZE);

boolean VISUALISATION = false;
boolean INTERACTIVE = false;

int frame = 0;

float MAX_SEPARATION_EFFECT = 1;
float MAX_COHERENCE_EFFECT = 0.1;

float MAX_VELOCITY = 3;

float SPLIT_PROBABILITY = 0.01;
float LEAD_PROBABILITY = 0.001;

color COLORS[] = new color[MAX_GROUPS+1];

ArrayList<PVector> objects = new ArrayList<PVector>();
int leaders[] = new int[MAX_GROUPS+1];

ArrayList<Boid> flock = new ArrayList<Boid>();
BitSet grid[][] = new BitSet[GRID_WIDTH][GRID_HEIGHT];
boolean memoized[][][] = new boolean[GRID_WIDTH][GRID_HEIGHT][6];
BitSet memo[][][] = new BitSet[GRID_WIDTH][GRID_HEIGHT][6];

PFont Ubuntu;

void setup(){
  size(1200,600);
  for(int i = 0; i < N ; i++) flock.add(new Boid(i));
  for(int i = 1; i<=MAX_GROUPS; i++) {
    COLORS[i] = 100/MAX_GROUPS*i;
    leaders[i] = (int) (random(1)*N);
  }
  objects.add(new PVector(WIDTH*2/3,HEIGHT/2)); 
  Ubuntu = createFont("Ubuntu-C.ttf",80);
}

void draw(){
  colorMode(RGB,255);
  background(245);
  
  for(int i = 0; i< GRID_WIDTH; i++){
    for(int j = 0; j< GRID_HEIGHT; j++){
      grid[i][j] = new BitSet(N);
      for(int k = 0; k <6;k++){
        memo[i][j][k] = new BitSet(N);  
        memoized[i][j][k] = false;
      }
    }
  }
  
  for(int i = 0; i < N ; i++) flock.get(i).fence();
  for(int i = 0; i < N ; i++) flock.get(i).split();
  for(int i = 0; i < N ; i++) flock.get(i).look();
  for(int i = 0; i < N ; i++) flock.get(i).advance();
  
  frame++;
  frame%=100;
  
  if(VISUALISATION){
    if(!INTERACTIVE){
    for(int i = 0; i < N ; i+=50) flock.get(i).visualise();
    }else{
      if(mousePressed){
        BitSet interactive = within(mouseX, mouseY, VISUALISATION_THRESHOLD);
        for(int i = interactive.nextSetBit(0); i>=0; i=interactive.nextSetBit(i+1)) flock.get(i).visualise(); 
      }
    }
    stroke(0,0,0,20);
    for(int i = 0; i < WIDTH/FENCE_SIZE; i++) line(i*FENCE_SIZE,0, i*FENCE_SIZE, HEIGHT);
    for(int i = 0;i < HEIGHT/FENCE_SIZE; i++) line(0, i*FENCE_SIZE, WIDTH, i*FENCE_SIZE); 
    noStroke();
  }
  
  for(int i = 0; i < N ; i++) flock.get(i).paint();
  
  colorMode(RGB);
  textAlign(CENTER);
  textFont(Ubuntu);
  fill(25,25,25,90);
  text("Flocking",WIDTH*2/3,HEIGHT/2-20);
  fill(25,25,25,35);
  textFont(Ubuntu,40);
  text("#codeisbeauty",WIDTH*2/3,HEIGHT/2+30);
  
}

class Boid {
  PVector position, velocity, acceleration;
  PVector separation, alignment, cohesion, direction, avoidance;
   
  int id;
  int group;
  
  PVector fence[] = new PVector[4]; 
  int step = floor(random(0,4));
  
  
  BitSet neighbours, too_close, others;
  
  Boid(int id){
    position = new PVector(random(1)*WIDTH, random(1)*HEIGHT);
    //position = new PVector(WIDTH/2+random(-5,5),HEIGHT/2+random(-5,5));
    velocity = new PVector(0,0);
    acceleration = new PVector(random(-1,1),random(-1,1));
    
    group = floor(random(1,GROUPS+1));
    this.id = id;
    
    for(int i = 0; i<4;i++){
      fence[i] = new PVector(position.x/FENCE_SIZE, position.y/FENCE_SIZE);
    }
    
  }
  
  void look(){
    neighbours = within(position.x, position.y, NEIGHBOUR_THRESHOLD);
    too_close = within(position.x, position.y, AVOID_THRESHOLD);
    others = within(position.x, position.y, OTHERS_THRESHOLD);
    separate();
    cohere();
    align();
    avoid();
    seek();
  }
  
  void advance(){
    acceleration.add(separation.mult(kS));
    acceleration.add(cohesion.mult(kC));
    acceleration.add(alignment.mult(kA));
    acceleration.add(direction.mult(kD));
    acceleration.add(avoidance.mult(kO));
    
    velocity.add(acceleration);
    
    float v_mag = velocity.mag();
    velocity.normalize().mult(min(v_mag, MAX_VELOCITY));
    position.add(velocity);
    position.x = (position.x+WIDTH)%WIDTH;
    position.y = (position.y+HEIGHT)%HEIGHT;
    acceleration = new PVector(0,0);
  }
  
  void paint(){
    noStroke();
    if(id!=leaders[group]){
      noStroke();
    }else{
      //stroke(0);
    }
    colorMode(HSB,100);
    fill(COLORS[group], 75, 75,75);
    translate(position.x, position.y);
    rotate(velocity.heading() - PI/2);
    
    //boids
    //triangles
      //triangle(0,6,-3,-6,3,-6);
      triangle(0,10,-5,-10,5,-10);
      //triangle(0,12,-6,-12,6,-12);
    
    //minions
      //if(frame%5==0){
      //  step++;
      //  step%=4;
      //}
      //ellipse(-3,-2+step+2,6,6);
      //ellipse(3,2-step+2,6,6);
      //fill(COLORS[group], 25, 90);
      //ellipse(0,-1,10,10);
      //fill(COLORS[group], 65, 70);
      //ellipse(0,-2,8,5);
    
    //squares
      //rect(0,0,5,5);
      
    //circles
      //ellipse(0,0,6,6);
    
    rotate(-velocity.heading() + PI/2);
    translate(-position.x, -position.y);
  }
  
  void separate(){
    separation = new PVector(0,0);
    int count = 0;
    
    for(int i = too_close.nextSetBit(0); i>=0; i = too_close.nextSetBit(i+1)){
      Boid b = flock.get(i);
      PVector v = b.position.copy().sub(position);
      float m = v.mag();
      v.normalize().mult(min(1/m, MAX_SEPARATION_EFFECT));
      separation.sub(v);
      count++;
    }
   
    if(count > 0) separation.div(count);
  }
  
  void cohere(){
    PVector mean = new PVector(0,0);
    cohesion = new PVector(0,0);
    int count = 0;
    for(int  i = neighbours.nextSetBit(0); i>= 0; i = neighbours.nextSetBit(i+1)){
      Boid b = flock.get(i);
      if(b.group != group) continue;
      mean.add(b.position);
      count++;
    }
    if(count > 0){
      mean.div(count);
      cohesion = mean.sub(position);
      float m = cohesion.mag();
      cohesion.normalize().mult(min(m,MAX_COHERENCE_EFFECT));
    }
  }
  
  void align(){
    alignment = new PVector(0,0);
    int count = 0;
    for(int  i = neighbours.nextSetBit(0); i>= 0; i = neighbours.nextSetBit(i+1)){
      Boid b = flock.get(i);
      if(b.group == group){
        alignment.add(b.velocity);
      }else{
        alignment.sub(b.velocity);
      }
        count++;
    }
    if(count > 0){
      alignment.div(count);
      alignment.normalize();
    }
  }
  
  void seek(){
    PVector center = new PVector(mouseX, mouseY);
    direction = flock.get(leaders[group]).position.copy().sub(position).normalize();
  }
  
  void avoid(){
    avoidance = new PVector(0,0);
    for(int i = 0; i < objects.size(); i++) avoidance = objects.get(0).copy().sub(position);
    if(objects.size() >= 0) avoidance.div(objects.size());
    float m = avoidance.mag();
    avoidance.mult(-1).normalize().div(m);
  }
  
  void visualise(){
    colorMode(RGB,255);
    noStroke();
    fill(0,255,0,20);
    ellipse(position.x, position.y, NEIGHBOUR_THRESHOLD*2, NEIGHBOUR_THRESHOLD*2);
    fill(255,0,0,20);
    ellipse(position.x, position.y, AVOID_THRESHOLD*2, AVOID_THRESHOLD*2); 
    
    PVector v_alignment = alignment.copy().normalize().mult(20);
    PVector v_cohesion = cohesion.copy().normalize().mult(20);
    PVector v_separation = separation.copy().normalize().mult(20);
    
    stroke(255,255,0);
    line(position.x, position.y, position.x+v_alignment.x, position.y+v_alignment.y);
    
    stroke(0,255,255);
    line(position.x, position.y, position.x+v_cohesion.x, position.y+v_cohesion.y);
    
    stroke(255,0,255);
    line(position.x, position.y, position.x+v_separation.x, position.y+v_separation.y);
    noStroke();
    
   int left = (int) (position.x/FENCE_SIZE) - (int) (AVOID_THRESHOLD/FENCE_SIZE);
   int right = left + (int) (AVOID_THRESHOLD/FENCE_SIZE)*2 + 1;
   int up = (int) (position.y/FENCE_SIZE) - (int) (AVOID_THRESHOLD/FENCE_SIZE);
   int down = up + (int) (AVOID_THRESHOLD/FENCE_SIZE)*2 + 1;
   noFill();
   stroke(0,0,0,50);
   rect(left * FENCE_SIZE,up * FENCE_SIZE, (right - left) * FENCE_SIZE, (down - up) * FENCE_SIZE);
  }
  
  void split(){
    if(random(0,1) < SPLIT_PROBABILITY){
      switch (floor(random(0,3))){
        case 0:
          if(group/2 >= 0) group/=2;
          break;
        case 1:
          if(group*2 <= MAX_GROUPS) group*=2;
          break;
        case 2:
          if(group*2+1 <= MAX_GROUPS) group= group*2+1;
          break;
      }
      if(random(0,1) < LEAD_PROBABILITY) leaders[group] = id;
    }
  }
  
  void fence(){
    grid[(int) position.x/FENCE_SIZE][(int) position.y/FENCE_SIZE].set(id);
  }
}

BitSet within(float x, float y, float r){
  
    int tc1, tc2;
    tc1 = tc2 = 0;
  
   BitSet result = new BitSet();
   
   int g = (int) (r/FENCE_SIZE);
   int gx = (int) (x/FENCE_SIZE);
   int gy = (int) (y/FENCE_SIZE);
   int left = gx - g;
   int right = left + g*2 + 1;
   int up = gy - g;
   int down = up + g*2 + 1;
   left = max(0,left);
   right = min(GRID_WIDTH-1,right);
   up = max(0,up);
   down = min(GRID_HEIGHT-1,down);
   
   BitSet candidates;
   
   if(memoized[gx][gy][g]){
     candidates = (BitSet) (memo[gx][gy][g]).clone();
   }else{
   candidates = new BitSet(N);
   for(int i = left; i <= right; i++){
     for(int j = up; j <= down; j++){
        candidates.or(grid[i][j]);
     }
   }
   memoized[gx][gy][g] = true;
   memo[gx][gy][g] = (BitSet) (candidates).clone();
   }
   
   for(int i = candidates.nextSetBit(0); i>=0; i = candidates.nextSetBit(i+1)){
   Boid b = flock.get(i);
   if(b.position.x == x && b.position.y == y) continue;
   if(sq_distance(b.position.x, b.position.y, x, y) < r*r) result.set(i);
   }
   
   //for(int i = 0; i<N; i++){
   //Boid b = flock.get(i);
   //if(b.position.x == x && b.position.y == y) continue;
   //if(sq_distance(b.position.x, b.position.y, x, y) < r*r) result.set(i);
   //}
   
   //if(tc1!=tc2) println("bf ", tc2, "memo ", tc1); 
   
  return result;
}

float sq_distance(float ax, float ay, float bx, float by){ return (ax-bx)*(ax-bx) + (ay-by)*(ay-by); }
float distance(float ax, float ay, float bx, float by){ return sqrt(sq_distance(ax,ay,bx,by)); }
