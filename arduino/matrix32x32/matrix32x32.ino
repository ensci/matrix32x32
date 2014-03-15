#include <Adafruit_GFX.h>   // Core graphics library
#include <RGBmatrixPanel.h> // Hardware-specific library

// If your 32x32 matrix has the SINGLE HEADER input,
// use this pinout:
#define CLK 8  // MUST be on PORTB! (Use pin 11 on Mega)
#define OE  9
#define LAT 10
#define A   A0
#define B   A1
#define C   A2
#define D   A3
// If your matrix has the DOUBLE HEADER input, use:
//#define CLK 8  // MUST be on PORTB! (Use pin 11 on Mega)
//#define LAT 9
//#define OE  10
//#define A   A3
//#define B   A2
//#define C   A1
//#define D   A0
RGBmatrixPanel matrix(A, B, C, D, CLK, LAT, OE, false);

int cnt = 0;
int buff = 0;

int pix = 0;

int red,green,blue;


void setup() {

  Serial.begin(115200);
  matrix.begin();
  int count = 0;
  
  for (int i=0; i<32; i++) {
    for (int j=0; j<32; j++) {
  
      matrix.drawPixel(i, j, matrix.Color333(7, 7, 7));

    }
  }
  //matrix.fillRect(0, 0, 32, 16, matrix.Color333(7, 7, 7));
 
}


void loop() {
  if (Serial.available()>0) {
    int data = Serial.read();

    if (data==255) {
      //Serial.println(cnt);
      cnt = 0;
      //Serial.println("got");
    } 
    else { 
      if (pix == 0) { // first byte
        green = (data >> 3) & 0x7;
        blue = data & 0x7;
      } 
      else { // second byte
        red = data & 0x7;
        
        int x,y;
        x = cnt % 32;
        y = (cnt - x) / 32;

        matrix.drawPixel(x,y, matrix.Color333(red, green, blue));
      }

      if (pix==0) cnt++;
      pix = 1-pix;
    }
  }
  
  
}









