// Example by Tom Igoe
import processing.serial.*;
// STRING of COMMAND
byte[] M1_C = { '$', 'M', '1', 'B', '0', '0', '0', '0', '3', '*'};
byte[] M2_C = { '$', 'M', '2', 'B', '0', '0', '0', '0', '3', '*'};
byte[] num_value = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
int update = 0;
int status = 1;
float bx;
float by;
float M1S;
float M2S;
float temp_radius;
float temp_diameter;
int boxSize = 100;
boolean overBox = false;
boolean trig_REV = false;
boolean trig_FWD = false;
boolean locked = false;
float xOffset = 0.0; 
float yOffset = 0.0; 
String inString = "00000000000000";  // Input string from serial port
// The serial port:
Serial myPort;
char lf = '*';      // ASCII linefeed 
int x_old = 900;
int y_old = 0;
int y = 0;
float setspeed = 6;
float setspeed_old = 6;
int m = 0;
int command_flag = 0;
int PID_flag = 0;
int REV_flag = 0;
int FWD_flag = 0;
int start_read = 0;
float P=1,I=1,D=1;
int i = 0;
char[] inBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E'};
char[] tempBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
char headByte = '+';

void setup() 
{
  //List all the available serial ports:
  println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[2], 9600);
  // Send initial command(brake) out the serial port
  myPort.write(M1_C);
  myPort.write(M2_C);
  command_flag = 1;
  size(2000, 1000);
  bx = 500;
  by = 500;
  background(0);
}

void draw()
{ 
  
  //only used to show control function !!!!! not PID adjust
  background(0);
  
  
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  fill(255);  // Set fill to white
  ellipse(500, 500, 350, 350);  // Draw white ellipse using RADIUS mode
  
  //used for trigger function
  fill(100);
  rect(800, 800, 100, 100);
  rect(1000, 800, 100, 100);
  fill(0);
  textSize(25);
  text("REV", 820, 840);
  text("FWD", 1020, 840);
  
  if(REV_flag == 0)
    text("OFF", 820, 870);
  else
    text("ON", 825, 870);
  
  if(FWD_flag == 0)
    text("OFF", 1020, 870);
  else
    text("ON", 1025, 870);
  
  // Test if the cursor is over the box 
  if (mouseX > bx-boxSize && mouseX < bx+boxSize && 
      mouseY > by-boxSize && mouseY < by+boxSize) {
    overBox = true;  
    if(!locked) { 
      stroke(255); 
      fill(153);
    } 
  } else {
    stroke(153);
    fill(153);
    overBox = false;
  }
  
  // Test if the cursor is over the trigger box 
  if (mouseX > 800 && mouseX < 900 && 
      mouseY > 800 && mouseY < 900) 
 {
    trig_REV = true;   
  } else 
  {
    trig_REV = false;
  }
  
  if (mouseX > 1000 && mouseX < 1100 && 
      mouseY > 800 && mouseY < 900) 
  {
    trig_FWD = true;   
  } else 
  {
    trig_FWD = false;
  }
 
  text("round count is " +  inBytes[0] +  inBytes[1] +  inBytes[2] + inBytes[3] + inBytes[4], 1500, 850);
  
  
  fill(100);  // Set fill to gray
  ellipse(bx, by, 100, 100);  // Draw gray ellipse using CENTER mode
  
  //show speed of motor
//  M1S = bx - 500;
//  M2S = by - 500;
//  M1S = map(M1S,-200,200,-40,40);
//  M2S = map(M2S,-200,200,-40,40);
//  M1S = abs(int(M1S));
//  M2S = abs(int(M2S));
//  fill(255);
//  textSize(15);
//  text("M1 " + char(M1_C[3]) + " :" + byte(M1S),700,50);
//  text("M2 " + char(M2_C[3]) + " :" + byte(M2S),700,100);
//  
//  //parse speed value
//  int M1_speed_bit2 = int(M1S/10);
//  int M1_speed_bit1 = int(M1S - M1_speed_bit2*10);
//  
//  int M2_speed_bit2 = int(M2S/10);
//  int M2_speed_bit1 = int(M2S - M2_speed_bit2*10);
//  
//  M1_C[7] = num_value[M1_speed_bit2];
//  M1_C[8] = num_value[M1_speed_bit1];
//  
//  M2_C[7] = num_value[M2_speed_bit2];
//  M2_C[8] = num_value[M2_speed_bit1];
  
  if(update == 1)
  {  
    myPort.write(M1_C);
    myPort.write(M2_C);
    update = 0;
  }

  //adjust PID value
//  if(keyPressed && PID_flag == 0)
//  {
//    if(key == 'a' || key == 's')
//    {
//      if(key == 'a')
//        P = P+1;
//      else if(key == 's')
//        P = P-1;
//
//      if(P<=0)
//        P = 0;
//      else if(P>=999)
//        P = 999;
//
//      command[1] = 'P';
//      int PID_bit3 = int(P/100);
//      int PID_bit2 = int((P - PID_bit3*100)/10);
//      int PID_bit1 = int(P - PID_bit2*10 - PID_bit3*100);
//      command[2] = num_value[PID_bit3];
//      command[3] = num_value[PID_bit2];
//      command[4] = num_value[PID_bit1];
//    }
//    
//    if(key == 'd' || key == 'f')
//    {
//      if(key == 'd')
//        I = I+1;
//      else if(key == 'f')
//        I = I-1;
//      
//      if(I<=0)
//        I = 0;
//      else if(I>=999)
//        I = 999;  
//      
//      command[1] = 'I';
//      int PID_bit3 = int(I/100);
//      int PID_bit2 = int((I - PID_bit3*100)/10);
//      int PID_bit1 = int(I - PID_bit2*10 - PID_bit3*100);
//      command[2] = num_value[PID_bit3];
//      command[3] = num_value[PID_bit2];
//      command[4] = num_value[PID_bit1];
//    }
//
//    if(key == 'g' || key == 'h' || key == 'j' || key == 'k')
//    {
//      if(key == 'g')
//        D = D+10;
//      else if(key == 'h')
//        D = D-10;
//      else if(key == 'j')
//        D = D+100;
//      else if(key == 'k')
//        D = D-100;
//      
//      if(D<=0)
//        D = 0;
//      else if(D>=9999)
//        D = 9999;
//      
//      command[1] = 'D';
//      int PID_bit4 = int(D/1000);
//      int PID_bit3 = int(D - PID_bit4*1000)/100;
//      int PID_bit2 = int(D - PID_bit4*1000 - PID_bit3*100)/10;
//      int PID_bit1 = int(D - PID_bit4*1000 - PID_bit3*100 - PID_bit2*10);
//      command[2] = num_value[PID_bit4];
//      command[3] = num_value[PID_bit3];
//      command[4] = num_value[PID_bit2];
//      command[5] = num_value[PID_bit1];
//    }
//    
//    if(command[1] == 'D')
//      command[6] = '*';
//    else
//      command[5] = '*';
//    
//    //lock
//    PID_flag = 1;
//    myPort.write(command);
//  }
     
//  // show speed value
//  m = m + 1;
//  if(m % 60 == 0)
//  {
//   setspeed = 45 - setspeed_old;
//  //parse speed value
//  int speed_bit2 = int(setspeed/10);
//  int speed_bit1 = int(setspeed - speed_bit2*10);
//  
//  command[1] = 'M';
//  command[2] = '1';
//  command[3] = 'F';
//  command[4] = '0';
//  command[5] = '0';
//  command[6] = '0';
//  command[7] = num_value[speed_bit2];
//  command[8] = num_value[speed_bit1];
//  command[9] = '*';
//  
//  myPort.write(command);
//  command_flag = 1;
//  }
   
//  if(x_old == 1900)
//    {
//     x_old = 900; 
//     background(0);
//    } 
//    //text("received: " + inString, 10,50);
//    //y = int(inString.charAt(0)-'0')*100 + int(inString.charAt(1)-'0')*10 + int(inString.charAt(2)-'0');
//    int PID_bit1 = int(inBytes[3]-'0'); 
//    int PID_bit2 = int(inBytes[4]-'0');
//    int PID_bit3 = int(inBytes[5]-'0'); 
//    int PID_bit4 = int(inBytes[6]-'0'); 
//    int PID_bit5 = int(inBytes[7]-'0');
//    int PID_bit6 = int(inBytes[8]-'0'); 
//    int PID_bit7 = int(inBytes[9]-'0'); 
//    int PID_bit8 = int(inBytes[10]-'0');
//    int PID_bit9 = int(inBytes[11]-'0');
//    int PID_bit10 = int(inBytes[12]-'0');
//    if(PID_bit1>=0 && PID_bit1<=9 && PID_bit2>=0 && PID_bit2<=9 && PID_bit3>=0 && PID_bit3<=9 && PID_bit4>=0 && PID_bit4<=9 && PID_bit5>=0 && PID_bit5<=9 && PID_bit6>=0 && PID_bit6<=9 && PID_bit7>=0 && PID_bit7<=9 && PID_bit8>=0 && PID_bit8<=9 && PID_bit9>=0 && PID_bit9<=9 && PID_bit10>=0 && PID_bit10<=9)
//      println("P is : "+ inBytes[3] + inBytes[4] + inBytes[5] + " I is : " + inBytes[6] + inBytes[7] + inBytes[8] + " D is : " + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12]);
//    
//    int bit1 = int(inBytes[1]-'0'); 
//    int bit0 = int(inBytes[2]-'0');
//    if(bit0>=0 && bit0<=9 && bit1>=0 && bit1<=9)
//      y = bit1*10 + bit0;
////    if(y>100)
////      println(" one time Byte value " + inBytes[0] + inBytes[1] + inBytes[2] + inBytes[3] + inBytes[4] + inBytes[5] + inBytes[6] + inBytes[7] + inBytes[8] + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12] + " temp Bytes :" + tempBytes[0] + tempBytes[1] + tempBytes[2] + tempBytes[3] + tempBytes[4] + tempBytes[5] + tempBytes[6] + tempBytes[7] + tempBytes[8] + tempBytes[9] + tempBytes[10] + tempBytes[11] + tempBytes[12] + tempBytes[13]);
//    fill(255);
//    textSize(10);
//    text("measure speed value : " + y, 1200,550);
//    text("set speed value : " + setspeed, 1200,600);
//    line(x_old,500-y_old*10,x_old+1,500-y*10);
//    fill(125);
//    line(x_old,500-setspeed_old*10,x_old+1,500-setspeed*10);
//    x_old = x_old + 1;
//    y_old = y;
//    setspeed_old = setspeed;
    
  while(myPort.available() > 0)
  {
    if(start_read == 0)
      headByte = myPort.readChar();
    
    if(headByte == 'S')
    {
      start_read = 1;
      tempBytes[0] = headByte;
      headByte = '?';
      tempBytes[i] = myPort.readChar();
      i++;
    } else if(start_read == 1)
    {
      tempBytes[i] = myPort.readChar();
      //println(i + " " + inBytes[i]); 
      if(i == 14)
      {
        i = 1;
        start_read = 0;
        myPort.clear();
        if(tempBytes[14] == '*')
          for (int num = 0; num <13; num = num+1)
          {
            inBytes[num] = tempBytes[num+1];
          }
      }else
      {
        i++;
      }
    }
  } 
}




void mousePressed() {
  if(overBox) { 
    locked = true; 
    fill(255, 255, 255);
  } else {
    locked = false;
  }
  xOffset = mouseX-bx; 
  yOffset = mouseY-by;
 
 //trigger funciton
 if(trig_REV) {
    REV_flag = 1; 
    M1_C[3] = 'R';
  } else if(trig_FWD)
  {
    FWD_flag = 1;
    M1_C[3] = 'F';
  }
  
  update = 1;
  M1_C[7] = '1';
}

void mouseDragged() {
  if(locked){
       bx = mouseX-xOffset; 
       by = mouseY-yOffset; 
       
       bx = constrain( bx, 500-200,500+200);
       by = constrain( by, 500-200,500+200);
       
       temp_diameter = (bx - 500)*(bx - 500) + (by  - 500)*(by  - 500);
       temp_radius = sqrt(temp_diameter);
       if( temp_radius > 200)
       {
         bx = 500 + 200 * (bx - 500) / temp_radius;
         by = 500 + 200 * (by - 500) / temp_radius;
       }
       
       //parse instruction
       if(bx > 500)
       {
         M1_C[3] = 'F';
       }else if(bx < 500)
       {
         M1_C[3] = 'R';
       }
       
       if(by > 500)
       {
         M2_C[3] = 'F';
       }else if(by < 500)
       {
         M2_C[3] = 'R';
       }
       
       //flag indicate to transfer instr
       update = 1;
  }
}

void mouseReleased() {
  REV_flag = 0;
  FWD_flag = 0;
  locked = false;
  bx = 500;
  by = 500;
  update = 1;
  M1_C[3] = 'B';
  M2_C[3] = 'B';
}

void keyReleased() {
  PID_flag = 0;
}



