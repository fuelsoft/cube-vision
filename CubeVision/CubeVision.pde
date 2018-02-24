import g4p_controls.*; //file import

/* TODO:   "plane" type blocks?
           animated blocks?
*/

String separator = System.getProperty("file.separator");
String txImgName = "data"+separator+"textures"+separator+"def_cube.png"; //default texture to load
String bgImgName = "data"+separator+"textures"+separator+"gradient.png"; //background image
float mouseMSensitivity = 0.8; //movement with mouse
float mouseRSensitivity = 0.9; //rotation with mouse

float lx, ly, rx, ry;
float xpos, ypos, lrrot, udrot, zoom, cameraY; //cam data
boolean updatedM = false; //movement requires update?
boolean updatedR = false; //rotation requires update?
boolean rclk = false; //reset button
boolean inputReq = false;

PImage img, bg; //texture, background
String filename; //texture filename
int txSize, txMode, aFrame; //texture width, per face / texture mode (2x2, 3x2, 1x2)
boolean showTitle = true; //texture filename display toggle
PFont font;

void setup() {
  println("Thanks for using CubeVision!");
  font = createFont("PixelSplitter-Bold.ttf", 22, false);
  textFont(font);
  textSize(26);
  textAlign(CENTER);
  //graphics setup
  bg = loadImage(bgImgName); //load background
  txSetup(txImgName);
  size(800, 800, P3D);
  ((PGraphicsOpenGL)g).textureSampling(3); //sampling will blur textures without this line
  noStroke();
  
  //control initialization
  lx = 0.0;
  ly = 0.0;
  rx = 0.0;
  ry = 0.0;
  xpos = width/2;
  ypos = height/2;
  lrrot = PI/6;
  udrot = -PI/6;
  zoom = 1;
  cameraY = height/2; //rear render distance
}

void txSetup(String path){
  //println(path);
  img = loadImage(path); //load image from texture path
  
  String [] tmp = split(path, separator);
  filename = tmp[tmp.length-1];
  
  try {
    txSize = img.height/2; //texture scale
    if (img.height * 3 == img.width * 2) { //texture is 3x2, so loading is different
      txMode = 1; //6 different sides
    }
    else {
      txMode = 0;
    }
  } catch(Exception e) {
    println("INVALID FILE FORMAT");
    txSetup("data/textures/bad_texture.png");
    filename = "BAD TEXTURE";
  }
}

void keyPressed() { //keyboard trigger for press
  if (key == ' ') {
    rclk = true;
  }
  else if (key == 'o'){
    txImgName = G4P.selectInput("Select texture file...", "png,gif,jpg,jpeg", "Image files", sketchPath()+separator+"data"+separator+"textures");  
    if (txImgName != null) {
      txSetup(txImgName);
    }
  }
  else if (key == 'r') {
    txSetup(txImgName);
  }
  else if (key == 't') {
    if (showTitle){
      showTitle = false;
    }
    else {
      showTitle = true;
    }
  }
}

void mouseWheel(MouseEvent e) { //zoom
  zoom += float(e.getCount())/8;
}

void mouseDragged() { //move/rotate
  if (mouseButton == LEFT) {
    updatedM = true;
    ly = (mouseY - pmouseY) * zoom * mouseMSensitivity;
    lx = (mouseX - pmouseX) * zoom * mouseMSensitivity;
  }
  else if(mouseButton == RIGHT) {
    updatedR = true;
    ry = float(mouseY - pmouseY) * (zoom * zoom + 0.33) * (mouseRSensitivity/4);
    rx = float(mouseX - pmouseX) * (zoom * zoom + 0.33) * (mouseRSensitivity/4);
  }
}

void mouseReleased() {
  ly = 0;
  lx = 0;
  ry = 0;
  rx = 0;
}

void drawBox() {
  //modified from demo by Dave Bollinger (https://processing.org/examples/texturecube.html)
  beginShape(QUADS);
  texture(img);

  // +Y "bottom" face
  vertex(-30,  30,  30, 2 * txSize, txSize);
  vertex( 30,  30,  30, 2 * txSize, 2 * txSize);
  vertex( 30,  30, -30, txSize, 2 * txSize);
  vertex(-30,  30, -30, txSize, txSize);
  // -Y "top" face
  vertex(-30, -30, -30, 0, 2 * txSize);
  vertex( 30, -30, -30, 0, txSize);
  vertex( 30, -30,  30, txSize, txSize);
  vertex(-30, -30,  30, txSize, 2 * txSize);  
  // +Z "front" face
  vertex(-30, -30,  30, 0, 0);
  vertex( 30, -30,  30, txSize, 0);
  vertex( 30,  30,  30, txSize, txSize);
  vertex(-30,  30,  30, 0, txSize);
  // -X "left" face
  vertex(-30, -30, -30, txSize, 0);
  vertex(-30, -30,  30, 2 * txSize, 0);
  vertex(-30,  30,  30, 2 * txSize, txSize);
  vertex(-30,  30, -30, txSize, txSize);

  if (txMode == 1) { //texture is 3x2
    // -Z "back" face
    vertex( 30, -30, -30, 2 * txSize, txSize);
    vertex(-30, -30, -30, 3 * txSize, txSize);
    vertex(-30,  30, -30, 3 * txSize, 2 * txSize);
    vertex( 30,  30, -30, 2 * txSize, 2 * txSize);
    // +X "right" face
    vertex( 30, -30,  30, 2 * txSize, 0);
    vertex( 30, -30, -30, 3 * txSize, 0);
    vertex( 30,  30, -30, 3 * txSize, txSize);
    vertex( 30,  30,  30, 2 * txSize, txSize);
  }
  else { //texture is 2x2 or something else
    // -Z "back" face
    vertex( 30, -30, -30, 0, 0);
    vertex(-30, -30, -30, txSize, 0);
    vertex(-30,  30, -30, txSize, txSize);
    vertex( 30,  30, -30, 0, txSize);
    // +X "right" face
    vertex( 30, -30,  30, txSize, 0);
    vertex( 30, -30, -30, 2 * txSize, 0);
    vertex( 30,  30, -30, 2 * txSize, txSize);
    vertex( 30,  30,  30, txSize, txSize);
  }
  
  endShape();
}

void draw() {
  //modified from example sketch "Basics > Camera > Perspective"
  lights();
  background(bg);
  if (rclk) { //reset requested, restore defaults
    xpos = width/2;
    ypos = height/2;
    lrrot = PI/6;
    udrot = -PI/6;
    rclk = false; //disable reset flag
  }
  if (zoom > 1.2) { //min zoom
    zoom = 1.2;
  }
  else if (zoom < 0.2) { //max zoom
    zoom = 0.2;
  }

  float cameraZ = cameraY / tan(zoom / 1.5); //front clipping distance
  float aspect = float(width)/float(height);
  perspective(zoom, aspect, cameraZ/10.0, cameraZ*10.0);
  if (updatedM) {
    xpos += 2*lx; //adjust X position based on user input
    ypos += 2*ly; //adjust Y position based on user input
  }
  translate(xpos, ypos, 0); //left/right, up/down
  if (updatedR) {
    udrot -= ry/10; //adjust Y rotation based on user input
    lrrot += (rx * PI/60); //adjust X rotation based on user input
  }
  rotateX(udrot); //I think I named these two variables wrong lmao
  rotateY(lrrot);
  
  PGL pgl = beginPGL(); //enable some advanced openGL or something, I don't know
  pgl.enable(PGL.CULL_FACE); //backface culling
  drawBox(); //cube
 
  if(showTitle) {
    text(filename, 0, -60);
  }
  
  updatedM = false;
  updatedR = false;
}