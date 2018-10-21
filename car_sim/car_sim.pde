Car test;
Car stationary;
World w;

// button params

int buttonX, buttonY; // position of play button
int buttonSize = 50;
color buttonColor, pausedButtonColor;
color currentColor;
boolean buttonOver = false;
boolean paused = true;

// ego car params

float egoX, egoY, egoZ;
float egoSpeed;
float egoAcceleration;
float egoOrientation;

// world params

float seconds_per_frame = 1/60.0;
float pixels_per_meter = 4.705;

void setup() {
  size(1280, 740, P2D);
  buttonColor = color(255);
  pausedButtonColor = color(100);
  currentColor = pausedButtonColor;
  buttonX = width-100;
  buttonY = height-100;
  paramsX = 200;
  paramsY = height-120;
  paramsW = 340;
  paramsH = 180;

  start();

  // turn off aliasing
  noSmooth();
}

void start() {
  // separating start from setup so that we can
  // restart simulation upon collision
  test = new Car();
  test.set_init_position(new PVector(0, 32))
    .set_init_orientation(-PI/4)
    .set_name("test");

  stationary = new Car();
  stationary.set_init_position(new PVector(0, -8))
    .set_init_speed(0)
    .set_colour(color(0, 0, 255))
    .set_name("stationary");

  w = new World(width, height);
  w.coordinate_offset(width/2, height/2)
    .add_car(stationary)
    .add_car(test);
}

void draw() {
  update(mouseX, mouseY);
  background(250);

  // draw play/pause button
  stroke(0);
  if (buttonOver) {
    currentColor = paused ? buttonColor : pausedButtonColor;
  } else {
    currentColor = paused ? pausedButtonColor : buttonColor;
  }

  fill(currentColor);
  ellipse(buttonX, buttonY, buttonSize, buttonSize);

  fill(color(200));


  // draw parameter window
  rect(paramsX, paramsY, paramsW, paramsH);
  fill(0);

  textSize(32);
  text("Current parameters", paramsX-paramsW/2+10, height - 170);

  float[] paramValues = { egoX, egoY, egoZ, egoSpeed, egoAcceleration, egoOrientation };
  String[] paramNames = { "x-pos", "y-pos", "z-pos", "speed", "acceleration", "orientation" };

  for (int i = 0; i < 6; i = i+1) {
    textSize(16);
    text("Current " + paramNames[i] + " = " + paramValues[i], 
      paramsX-paramsW/2+10, 
      paramsY+20*(i-1));
  }

  // check if the simulation is paused
  if (!paused) {
    w.halt = false;
    triangle(buttonX-buttonSize/4, buttonY+buttonSize/3, 
      buttonX-buttonSize/4, buttonY-buttonSize/3, 
      buttonX+buttonSize/3, buttonY);
  } else {
    w.halt = true;
    rect(buttonX-1, buttonY, buttonSize/2, buttonSize/2);
  }

  // render world model
  w.timestep(seconds_per_frame);
  pushMatrix();
  translate(width/2, height/2);
  w.display_cars(pixels_per_meter);
  popMatrix();
}

void update(int x, int y) {
  // update car parameters
  egoX = test.position.x;
  egoY = test.position.y;
  egoZ = test.position.z;
  egoSpeed = test.speed;
  egoAcceleration = test.acceleration;
  egoOrientation = test.orientation;

  // update button state
  if (overButton(buttonX, buttonY, buttonSize)) {
    buttonOver = true;
  } else {
    buttonOver = false;
  }
}

void mousePressed() {
  if (buttonOver) {
    paused = !paused;
  } else {
    // click on anywhere to restart
    start();
  }
}

void overButton(int x, int y, int d) {
  float disX = x - mouseX;
  float disY = y - mouseY;
  if (sqrt(sq(disX) + sq(disY)) < d/2) {
    return true;
  } else {
    return false;
  }
}

void keyPressed() {
  if (key == 'a') {
    test.keyboard_steering(-0.01);
  }
  if (key == 'd') {
    test.keyboard_steering(0.01);
  }
  if (key == 'w') {
    test.accelerate(8);
  }
  if (key == 's') {
    test.accelerate(-8);
  }
  if (key == '=' || key == '+') {
    pixels_per_meter += 1;
  }
  if (key == '-' || key == '_') {
    pixels_per_meter -= 1;
  }
}

void keyReleased() {
  if (key == 'a' || key == 'd') {
    test.keyboard_steering(0);
  }
  if (key == 'w') {
    test.accelerate(0);
  }
  if (key == 's') {
    test.accelerate(0);
  }
}
