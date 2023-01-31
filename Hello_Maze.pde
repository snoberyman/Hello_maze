/**
 **********************************************************************************************************************
 * @file       sketch_2_Hello_Wall.pde
 * @author     Steve Ding, Colin Gallacher
 * @version    V3.0.0
 * @date       08-January-2021
 * @brief      Wall haptic example with programmed physics for a haptic wall 
 **********************************************************************************************************************
 * @attention
 *
 *
 **********************************************************************************************************************
 */
 
  /* library imports *****************************************************************************************************/ 
import processing.serial.*;
import static java.util.concurrent.TimeUnit.*;
import java.util.concurrent.*;
/* end library imports *************************************************************************************************/  


/* scheduler definition ************************************************************************************************/ 
private final ScheduledExecutorService scheduler      = Executors.newScheduledThreadPool(1);
/* end scheduler definition ********************************************************************************************/ 

import processing.sound.*;




/* device block definitions ********************************************************************************************/
Board             haplyBoard;
Device            widgetOne;
Mechanisms        pantograph;

byte              widgetOneID                         = 5;
int               CW                                  = 0;
int               CCW                                 = 1;
boolean           renderingForce                     = false;
/* end device block definition *****************************************************************************************/



/* framerate definition ************************************************************************************************/
long              baseFrameRate                       = 120;
/* end framerate definition ********************************************************************************************/ 



/* elements definition *************************************************************************************************/

/* Screen and world setup parameters */
float             pixelsPerMeter                      = 4000.0;
float             radsPerDegree                       = 0.01745;

/* pantagraph link parameters in meters */
float             l                                   = 0.07;
float             L                                   = 0.09;


/* end effector radius in meters */
float             rEE                                 = 0.006;

/* virtual wall parameter  */
float             kWall                               = 450;
PVector           fWall                               = new PVector(0, 0);
PVector           penWallh1                          = new PVector(0, 0);
PVector           penWallh2                          = new PVector(0, 0);
PVector           penWallh3                          = new PVector(0, 0);
PVector           penWallh4                          = new PVector(0, 0);
PVector           penWallh5                          = new PVector(0, 0);
PVector           penWallh6                          = new PVector(0, 0);
PVector           penWallh7                          = new PVector(0, 0);
PVector           penWallh8                          = new PVector(0, 0);
PVector           penWallh9                          = new PVector(0, 0);
PVector           penWallh10                          = new PVector(0, 0);


PVector           penWallv1                          = new PVector(0, 0);
PVector           penWallv2                         = new PVector(0, 0);
PVector           penWallv3                         = new PVector(0, 0);
PVector           penWallv4                         = new PVector(0, 0);
PVector           penWallv5                         = new PVector(0, 0);
PVector           penWallv6                         = new PVector(0, 0);
PVector           penWallv7                         = new PVector(0, 0);
PVector           penWallv8                         = new PVector(0, 0);
PVector           penWallv9                         = new PVector(0, 0);
PVector           penWallv10                         = new PVector(0, 0);

PVector           posWall                             = new PVector(0.01, 0.10);



/* generic data for a 2DOF device */
/* joint space */
PVector           angles                              = new PVector(0, 0);
PVector           torques                             = new PVector(0, 0);

/* task space */
PVector           posEE                               = new PVector(0, 0);
PVector           fEE                                 = new PVector(0, 0); 

/* device graphical position */
PVector           deviceOrigin                        = new PVector(0, 0);

/* World boundaries reference */
final int         worldPixelWidth                     = 1000;
final int         worldPixelHeight                    = 650;


/* graphical elements */
PShape pGraph, joint;
PShape vertical1, vertical2, vertical3, vertical4, vertical5, vertical6, vertical7, vertical8, vertical9, vertical10, vertical11, vertical12, vertical13;
PShape horizontal1, horizontal2, horizontal3, horizontal4, horizontal5, horizontal6, horizontal7, horizontal8, horizontal9, horizontal10, horizontal11, horizontal12, horizontal13,horizontal14 ;
PImage endEffector, bg;
/* end elements definition *********************************************************************************************/ 

SoundFile hitSound;

/* setup section *******************************************************************************************************/
void setup(){
  /* put setup code here, run once: */
  
  /* screen size definition */
  size(1000, 650);
  
  /* device setup */
  
  /**  
   * The board declaration needs to be changed depending on which USB serial port the Haply board is connected.
   * In the base example, a connection is setup to the first detected serial device, this parameter can be changed
   * to explicitly state the serial port will look like the following for different OS:
   *
   *      windows:      haplyBoard = new Board(this, "COM10", 0);
   *      linux:        haplyBoard = new Board(this, "/dev/ttyUSB0", 0);
   *      mac:          haplyBoard = new Board(this, "/dev/cu.usbmodem1411", 0);
   */ 
  haplyBoard          = new Board(this, Serial.list()[0], 0);
  widgetOne           = new Device(widgetOneID, haplyBoard);
  pantograph          = new Pantograph();
  
  widgetOne.set_mechanism(pantograph);
  
  widgetOne.add_actuator(1, CCW, 2);
  widgetOne.add_actuator(2, CW, 1);
  
  widgetOne.add_encoder(1, CCW, 241, 10752, 2);
  widgetOne.add_encoder(2, CW, -61, 10752, 1);
  
  widgetOne.device_set_parameters();
  
  
  /* visual elements setup */
  if (posEE.y < 0.04){
    background(0) ;
  } else if (posEE.y > 0.13){
    background(192, 57, 43);
  } 
  else {
    background(34, 139, 34) ;
  }
  bg = loadImage("bg.jpg");
  deviceOrigin.add(worldPixelWidth/2, 0);
  
    hitSound = new SoundFile(this,"Cartoon Boing.mp3");
  
  
  /* create pantagraph graphics */
  create_pantagraph();
  
  /* create wall graphics */
  horizontal1 = create_line(-0.13-rEE, 0.04+rEE, -0.04-rEE, 0.04+rEE);
  horizontal2 = create_line(-0.02-rEE, 0.04+rEE, 0.04+rEE, 0.04+rEE);
  horizontal3 = create_line(0.06+rEE, 0.04+rEE, 0.13+rEE, 0.04+rEE);
  
  horizontal4 = create_line(-0.04-rEE, 0.06+rEE, -0.13+rEE, 0.06+rEE);
  horizontal5 = create_line(-0.02-rEE, 0.07+rEE, 0.04+rEE, 0.07+rEE);
  horizontal6 = create_line(-0.08-rEE, 0.08+rEE, -0.04-rEE, 0.08+rEE);
  
  horizontal7 = create_line(0.06+rEE, 0.08+rEE, 0.09+rEE, 0.08+rEE);
  
  horizontal8 = create_line(-0.08-rEE, 0.09+rEE, 0.02+rEE, 0.09+rEE);
  horizontal9 = create_line(0.06+rEE, 0.09+rEE, 0.19+rEE, 0.09+rEE);
  
  horizontal10 = create_line_medium(-0.14-rEE, 0.11+rEE, -0.02-rEE, 0.11+rEE);
  horizontal11 = create_line(0.04+rEE, 0.11+rEE, 0.09+rEE, 0.11+rEE);
  
  horizontal12 = create_line(-0.13-rEE, 0.13+rEE, -0.09-rEE, 0.13+rEE);
  horizontal13 = create_line(-0.07-rEE, 0.13+rEE, 0.045+rEE, 0.13+rEE);
  horizontal14 = create_line(0.06+rEE, 0.13+rEE, 0.13+rEE, 0.13+rEE);
  
 
  
  vertical1 = create_line(-0.04-rEE, 0.04+rEE, -0.04-rEE, 0.06+rEE);
  vertical2 = create_line(-0.02-rEE, 0.04+rEE, -0.02-rEE, 0.07+rEE);
  
  vertical3 = create_line(0.04+rEE, 0.04+rEE, 0.04+rEE, 0.07+rEE);
  vertical4 = create_line(0.06+rEE, 0.04+rEE, 0.06+rEE, 0.08+rEE);
  
  vertical5 = create_line(-0.08-rEE, 0.08+rEE,-0.08-rEE, 0.09+rEE);
  vertical6 = create_line(-0.04-rEE, 0.08+rEE, -0.04-rEE, 0.09+rEE);
  
  vertical7 = create_line_light(0.04+rEE, 0.09+rEE, 0.04+rEE, 0.11+rEE);
  vertical8 = create_line(0.00+rEE, 0.11+rEE, 0.00+rEE, 0.13+rEE);
  vertical9 = create_line(-0.07-rEE, 0.12+rEE, -0.07-rEE, 0.13+rEE);
  
  
  
  
  /* setup framerate speed */
  frameRate(baseFrameRate);
  
  
  /* setup simulation thread to run at 1kHz */ 
  SimulationThread st = new SimulationThread();
  scheduler.scheduleAtFixedRate(st, 1, 1, MILLISECONDS);
}
/* end setup section ***************************************************************************************************/



/* draw section ********************************************************************************************************/
void draw(){
  /* put graphical code here, runs repeatedly at defined framerate in setup, else default at 60fps: */
  if(renderingForce == false){
    //background(bg); 
    update_animation(angles.x*radsPerDegree, angles.y*radsPerDegree, posEE.x, posEE.y);
  }
}
/* end draw section ****************************************************************************************************/



/* simulation section **************************************************************************************************/
class SimulationThread implements Runnable{
  
  public void run(){
    /* put haptic simulation code here, runs repeatedly at 1kHz as defined in setup */
    
    renderingForce = true;
    
    if(haplyBoard.data_available()){
      /* GET END-EFFECTOR STATE (TASK SPACE) */
      widgetOne.device_read_data();
    
      angles.set(widgetOne.get_device_angles()); 
      posEE.set(widgetOne.get_device_position(angles.array()));
      posEE.set(device_to_graphics(posEE)); 
      
   
      
      /* haptic wall force calculation */
      
      fWall.set(0, 0);
      
      // Virtual walls 
      penWallh1.set(0, (0.041 - (posEE.y + rEE)));
      penWallh2.set(0, (0.063 - (posEE.y + rEE)));
      penWallh3.set(0, (0.073 - (posEE.y + rEE)));
      penWallh4.set(0, (0.082 - (posEE.y + rEE)));
      penWallh5.set(0, (0.092 - (posEE.y + rEE)));
      penWallh6.set(0, (0.112 - (posEE.y + rEE)));
      penWallh7.set(0, (0.132 - (posEE.y + rEE)));
      
      penWallv1.set((-0.045 - (posEE.x+rEE)), 0);
      penWallv2.set((-0.025 - (posEE.x+rEE)), 0);
      penWallv3.set((0.047 - (posEE.x+rEE)), 0);
      penWallv4.set((0.067 - (posEE.x+rEE)), 0);
      penWallv5.set((-0.085 - (posEE.x+rEE)), 0);
      penWallv6.set((0.007 - (posEE.x+rEE)), 0);
      penWallv7.set((-0.077 - (posEE.x+rEE)), 0);
    
            
           // horizontal 1,2,3 
           if((penWallh1.y < 0 && penWallh1.y > -0.01) && (posEE.x < (-0.04-rEE))){
               fWall = fWall.add(penWallh1.mult(-kWall));                  
           }
           if((penWallh1.y < 0 && penWallh1.y > -0.01) && (posEE.x > (-0.02-rEE) && posEE.x <0.04+rEE)){
               fWall = fWall.add(penWallh1.mult(-kWall));
           }
           if((penWallh1.y < 0 && penWallh1.y > -0.01) && (posEE.x > (0.06+rEE) && posEE.x <(rEE+0.13))){
               fWall = fWall.add(penWallh1.mult(-kWall));
           }
           
           // horizontal 4,5,6,7 
           if((penWallh2.y < 0 && penWallh2.y > -0.01) && (posEE.x < (-0.04-rEE))){
               fWall = fWall.add(penWallh2.mult(kWall));
           }
           if((penWallh3.y < 0 && penWallh3.y > -0.01) && (posEE.x > (-0.02-rEE) && posEE.x <0.04+rEE)){
               fWall = fWall.add(penWallh3.mult(kWall));
           }
           if((penWallh4.y < 0 && penWallh4.y > -0.01) && (posEE.x < (-0.04-rEE) && posEE.x > (-0.08-rEE))){
               fWall = fWall.add(penWallh4.mult(-kWall));
           }
           if((penWallh4.y < 0 && penWallh4.y > -0.01) && (posEE.x > (0.06+rEE) && posEE.x <(rEE+0.13))){
               fWall = fWall.add(penWallh4.mult(kWall));
           }
           
           // horizontal 8,9
           if((penWallh5.y < 0 && penWallh5.y > -0.01) && (posEE.x > (-0.08-rEE) && posEE.x < (0.02+rEE))){
               if(posEE.y < 0.09){
               fWall = fWall.add(penWallh5.mult(-kWall));
               } else {
               fWall = fWall.add(penWallh5.mult(kWall));
               }
           }
           if((penWallh5.y < 0 && penWallh5.y > -0.01) && (posEE.x > (0.06+rEE) && posEE.x <(rEE+0.13))){
               fWall = fWall.add(penWallh5.mult(kWall));
   
           }
           
          // horizontal 10,11
           if((penWallh6.y < 0 && penWallh6.y > -0.01) && (posEE.x > (-0.13-rEE) && posEE.x < (-0.02-rEE))){
               if(posEE.y < 0.11){
               fWall = fWall.add(penWallh6.mult(-100));
               } else {
               fWall = fWall.add(penWallh6.mult(100));
               }
           }
           if((penWallh6.y < 0 && penWallh6.y > -0.01) && (posEE.x > (0.04+rEE) && posEE.x < (0.09+rEE))){
               if(posEE.y < 0.11){
               fWall = fWall.add(penWallh6.mult(-kWall));
               } else {
               fWall = fWall.add(penWallh6.mult(kWall));
               }
           }
           
           // horizontal 12,13,14
           if((penWallh7.y < 0 && penWallh7.y > -0.01) && (posEE.x > (-0.13-rEE) && posEE.x < (-0.09-rEE))){
               if(posEE.y < 0.13){
               fWall = fWall.add(penWallh7.mult(-kWall));
               } else {
               fWall = fWall.add(penWallh7.mult(kWall));
               }
           }
           if((penWallh7.y < 0 && penWallh7.y > -0.01) && (posEE.x > (-0.07-rEE) && posEE.x < (0.045+rEE))){
               if(posEE.y < 0.13){
               fWall = fWall.add(penWallh7.mult(-kWall));
               } else {
               fWall = fWall.add(penWallh7.mult(kWall));
               }
           }
           if((penWallh7.y < 0 && penWallh7.y > -0.01) && (posEE.x > (0.06+rEE) && posEE.x < (0.13+rEE))){
               if(posEE.y < 0.13){
               fWall = fWall.add(penWallh7.mult(-kWall));
               } else {
               fWall = fWall.add(penWallh7.mult(kWall));
               }
           }
           
           
           
           // vertical 1,2
           if((posEE.y > 0.04 && posEE.y < 0.06) && (penWallv1.x < 0 && penWallv1.x > -0.01) ){
             fWall = fWall.add(penWallv1.mult(kWall));
           }
          if((posEE.y > 0.04 && posEE.y < 0.07) && (penWallv2.x < 0 && penWallv2.x > -0.01) ){
             fWall = fWall.add(penWallv2.mult(-kWall));
           }
         
          // vertical 3,7,4
           if((posEE.y > 0.04 && posEE.y < 0.07) && (penWallv3.x < 0 && penWallv3.x > -0.01) ){
             fWall = fWall.add(penWallv3.mult(kWall));
           }
         if((posEE.y > 0.09 && posEE.y < 0.11) && (penWallv3.x < 0 && penWallv3.x > -0.01) ){
               if(posEE.x > 0.045){
               fWall = fWall.add(penWallv3.mult(30));
               } else {
               fWall = fWall.add(penWallv3.mult(-30));
               }
           }
          if((posEE.y > 0.04 && posEE.y < 0.08) && (penWallv4.x < 0 && penWallv4.x > -0.01) ){
             fWall = fWall.add(penWallv4.mult(-kWall));
           }
           
          // vertical 5,6
           if((posEE.y > 0.08 && posEE.y < 0.09) && (penWallv5.x < 0 && penWallv5.x > -0.01) ){
             fWall = fWall.add(penWallv5.mult(-kWall));
           }
           if((posEE.y > 0.08 && posEE.y < 0.09) && (penWallv1.x < 0 && penWallv1.x > -0.01) ){
             fWall = fWall.add(penWallv1.mult(kWall));
           }
           
           // v8
           if((posEE.y > 0.11 && posEE.y < 0.13) && (penWallv6.x < 0 && penWallv6.x > -0.01) ){
               if(posEE.x > 0.007){
               fWall = fWall.add(penWallv6.mult(kWall));
               } else {
               fWall = fWall.add(penWallv6.mult(-kWall));
               }
           }
           
           // v9
           if((posEE.y > 0.12 && posEE.y < 0.13) && (penWallv7.x < 0 && penWallv7.x > -0.01) ){
               if(posEE.x > -0.077){
               fWall = fWall.add(penWallv7.mult(kWall));
               } else {
               fWall = fWall.add(penWallv7.mult(-kWall));
               }
           }
           
       
     

      
      fEE = (fWall.copy()).mult(-1);
      fEE.set(graphics_to_device(fEE));
      /* end haptic wall force calculation */
    }
    
    
    torques.set(widgetOne.set_device_torques(fEE.array()));
    widgetOne.device_write_torques();
  
  
    renderingForce = false;
  }
}
/* end simulation section **********************************************************************************************/


/* helper functions section, place helper functions here ***************************************************************/
void create_pantagraph(){
  //float lAni = pixelsPerMeter * l;
  //float LAni = pixelsPerMeter * L;
  //float rEEAni = pixelsPerMeter * rEE;
  
  //pGraph = createShape();
  //pGraph.beginShape();
  //pGraph.fill(255);
  //pGraph.stroke(0);
  //pGraph.strokeWeight(2);
  
  //pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  //pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  //pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  //pGraph.vertex(deviceOrigin.x, deviceOrigin.y);
  //pGraph.endShape(CLOSE);
  

  endEffector =  loadImage("runman.png");
  endEffector.resize(40, 40);
  
}


PShape create_line(float x1, float y1, float x2, float y2){
  x1 = pixelsPerMeter * x1;
  y1 = pixelsPerMeter * y1;
  x2 = pixelsPerMeter * x2;
  y2 = pixelsPerMeter * y2;
  
  strokeWeight(6);
  stroke(255);
  return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
}

PShape create_line_light(float x1, float y1, float x2, float y2){
  x1 = pixelsPerMeter * x1;
  y1 = pixelsPerMeter * y1;
  x2 = pixelsPerMeter * x2;
  y2 = pixelsPerMeter * y2;
  
  strokeWeight(1);
  stroke(240);
  return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
}

PShape create_line_medium(float x1, float y1, float x2, float y2){
  x1 = pixelsPerMeter * x1;
  y1 = pixelsPerMeter * y1;
  x2 = pixelsPerMeter * x2;
  y2 = pixelsPerMeter * y2;
  
  strokeWeight(3);
  stroke(230);
  return createShape(LINE, deviceOrigin.x + x1, deviceOrigin.y + y1, deviceOrigin.x + x2, deviceOrigin.y+y2);
}




void update_animation(float th1, float th2, float xE, float yE){
 if (posEE.y < 0.04){
    background(0) ;
  } else if (posEE.y > 0.13){
    background(192, 57, 43);
  } 
  else {
    background(34, 139, 34) ;
  }
  
  float lAni = pixelsPerMeter * l;
  float LAni = pixelsPerMeter * L;
  
  xE = pixelsPerMeter * xE;
  yE = pixelsPerMeter * yE;
  
  th1 = 3.14 - th1;
  th2 = 3.14 - th2;
  
  //pGraph.setVertex(1, deviceOrigin.x + lAni*cos(th1), deviceOrigin.y + lAni*sin(th1));
  //pGraph.setVertex(3, deviceOrigin.x + lAni*cos(th2), deviceOrigin.y + lAni*sin(th2));
  //pGraph.setVertex(2, deviceOrigin.x + xE, deviceOrigin.y + yE);
  
  //shape(pGraph);
  //shape(joint);
  shape(horizontal1);
  shape(horizontal2);
  shape(horizontal3);
  shape(horizontal4);
  shape(horizontal5);
  shape(horizontal6);
  shape(horizontal7);
  shape(horizontal8);
  shape(horizontal9);
  shape(horizontal10);
  shape(horizontal11);
  shape(horizontal12);
  shape(horizontal13);
  shape(horizontal14);
  
  
  shape(vertical1);
  shape(vertical2);
  shape(vertical3);
  shape(vertical4);
  shape(vertical5);
  shape(vertical6);
  shape(vertical7);
  shape(vertical8);
  shape(vertical9);

  translate(xE, yE);
  image(endEffector, deviceOrigin.x-20, deviceOrigin.y);
  
}


PVector device_to_graphics(PVector deviceFrame){
  return deviceFrame.set(-deviceFrame.x, deviceFrame.y);
}


PVector graphics_to_device(PVector graphicsFrame){
  return graphicsFrame.set(-graphicsFrame.x, graphicsFrame.y);
}



/* end helper functions section ****************************************************************************************/




 
