import processing.video.*;
import processing.serial.*;

int lf = 10;    // Linefeed in ASCII
String myString = null;
Serial myPort;  // The serial port

Capture cam;

boolean activateSerial = false;
boolean activateCamera = true;
boolean activateGrayscale = false;
boolean activateVerbose = false;
int bwTreshold = 100;

boolean saveNow = false;
String textOutput = "";

int w = 32;
int h = 32;

float stepW;
float stepH;

void setup() {
  size(640, 640);

  if (activateSerial) {
    // List all the available serial ports
    println(Serial.list());
    // Open the port you are using at the rate you want:
    myPort = new Serial(this, Serial.list()[2], 115200);
  }
  stepW = float(width)/float(w);
  stepH = float(width)/float(h);

  if (activateCamera) {
    String[] cameras = Capture.list();

    if (cameras == null) {
      println("Failed to retrieve the list of available cameras, will try the default...");
      cam = new Capture(this, 640, 360);
    } 
    if (cameras.length == 0) {
      println("There are no cameras available for capture.");
      exit();
    } 
    else {
      println("Available cameras:");
      for (int i = 0; i < cameras.length; i++) {
        println(cameras[i]);
      }

      // The camera can be initialized directly using an element
      // from the array returned by list():
      cam = new Capture(this, cameras[3]);
      // Or, the settings can be defined based on the text in the list
      //cam = new Capture(this, 640, 480, "Built-in iSight", 30);

      // Start capturing the images from the camera
      cam.start();
    }
  }
  frameRate(7);
}

void draw() {

  textOutput = "";
  if (activateCamera) {
    if (cam.available() == true) {
      cam.read();
    }
    image(cam, 0, 0, width, height);
    // The following does the same as the above image() line, but 
    // is faster when just drawing the image without any additional 
    // resizing, transformations, or tint.
    //set(0, 0, cam);
  }

  for (float y=0; y<height;y+=stepH) {
    for (float x=0; x<width;x+=stepW) {

      int centerX = int(x+stepW/2.0);
      int centerY = int(y+stepH/2.0);
      color pix = get(centerX, centerY);

      fill(255, 0, 0);
      noStroke();
      ellipse(centerX, centerY, 2, 2);

      stroke(255);

      if (activateGrayscale) {
        float level = red(pix);
        if (level > bwTreshold) {
          int c333 = convert24Colorto9(color(0));  
          byte[] out = splitToBytes(c333);
          writeOut(out);
          fill(255);
        } 
        else {
          int c333 = convert24Colorto9(color(255));  
          byte[] out = splitToBytes(c333);
          writeOut(out);
          fill(0);
        }
      } 
      else { // full color

        int c333 = convert24Colorto9(pix);  
        byte[] out = splitToBytes(c333);
        writeOut(out);

        fill(pix);
      }


      rect(x, y, stepW, stepH);
    }
  }


  if (activateSerial) 
    myPort.write(byte(255));
  else if (activateVerbose) println("255");
  textOutput+="255\n";


  if (saveNow) {
    String[] s = new String[1];
    s[0] = textOutput;
    saveStrings("lastFrame.txt", s);
    saveFrame("frame####.png");
    saveNow = false;
  }



  if (activateSerial) {
    while (myPort.available () > 0) {
      myString = myPort.readStringUntil(lf);
      if (myString != null) {
        println(myString);
      }
    }
  }
}


byte[] splitToBytes(int c333) {
  byte out1 = byte(c333 >> 6); // red
  byte out2 = byte(c333 & 0x3F); // green, blue
  byte[] out = new byte[2];
  out[0] = out2; // red
  out[1] = out1; // green, blue
  return out;
}

void writeOut(byte[] out) {
  if (activateSerial) {
    myPort.write(out[0]);
    myPort.write(out[1]);
  } 
  else {
    if (activateVerbose) println(int(out[0]) + " " + int(out[1]));
  }
  textOutput+=str(int(out[0])) + " " + str(int(out[1])) + "\n";
}

int convert24Colorto9(int c) {
  // source
  int red = (c >> 16)&0xFF;
  int green = (c >> 8)&0xFF;
  int blue = (c)&0xFF;
  // destination
  int r, g, b;
  r = red >> 5;
  g = green >> 5;
  b = blue >> 5;
  return (r << 6) | (g << 3) | (b);
}

void keyReleased() {
  if (int(key) == 32) {
    saveNow = true;
  }
}

