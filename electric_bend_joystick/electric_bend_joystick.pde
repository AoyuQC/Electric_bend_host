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
boolean inBox = false;
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
int i = 1;
char[] inBytes = {'1', '2'};
char[] tempBytes = {'1', '2', '3',  '4'};
char headByte = '+';
int M1S_dif = 0;
int M2S_dif = 0;
int M1S_dif_mod = 0;
int M2S_dif_mod = 0;
boolean M1_brake = true;
boolean M2_brake = true;
//nunchuck postition
int J1_base = 134;
int J2_base = 126;
//draw dotted line of move range
int[] dot_line_base = {132, 132, 132, 388, 388, 388, 388, 133};

void setup() 
{
  //List all the available serial ports:
  println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[0], 115200, 'N', 8, 1);
  // Send initial command(brake) out the serial port
  //myPort.write(M1_C);
  //myPort.write(M2_C);
  //size(2000, 1000);
  size(1000, 700);
  bx = 260;
  by = 260;
  background(0);
}

void draw()
{ 
  
  //only used to show control function !!!!! not PID adjust
  background(0);
  
  
  ellipseMode(RADIUS);  // Set ellipseMode to RADIUS
  fill(255);  // Set fill turn round to white
  rect(250, 510, 20, 20);
  ellipse(260, 570, 50, 50);
  
//  ellipse(260, 260, 228, 228);  // Draw white ellipse using RADIUS mode
  //ellipse(330, 260, 281, 281);
  line(28, 260, 88, 88);
  line(88, 88, 260, 28);
  line(260, 28, 432, 88);
  line(432, 88, 492, 260);
  line(492, 260, 432, 432);
  line(432, 432, 260, 492);
  line(260, 492, 88, 432);
  line(88, 432, 28, 260);
  fill(255);
  int dot_count = 0;
  int dot_step = 0;
  for (; dot_count < 33; dot_count++)
  {
    dot_step = dot_count * 8;
    //draw direction : clockwise
    ellipse(dot_line_base[0], dot_line_base[1] + dot_step, 1, 1);
    ellipse(dot_line_base[2] + dot_step, dot_line_base[3], 1, 1);
    ellipse(dot_line_base[4], dot_line_base[5] - dot_step, 1, 1);
    ellipse(dot_line_base[6] - dot_step, dot_line_base[7], 1, 1);
  }
  fill(255);
  
  //used for trigger function
//  fill(100);
//  rect(800, 800, 100, 100);
//  rect(1000, 800, 100, 100);
//  fill(0);
  //textSize(25);
  //text("REV", 820, 840);
  //text("FWD", 1020, 840);
  
//  if(REV_flag == 0)
//    text("OFF", 820, 870);
//  else
//    text("ON", 825, 870);
//  
//  if(FWD_flag == 0)
//    text("OFF", 1020, 870);
//  else
//    text("ON", 1025, 870);
  
  // Test if the cursor is over the box 
  if (mouseX > bx-boxSize && mouseX < bx+boxSize && 
      mouseY > by-boxSize && mouseY < by+boxSize) {
    inBox = true;  
    if(!locked) { 
      stroke(255); 
      fill(153);
    } 
  } else {
    stroke(153);
    fill(153);
    inBox = false;
  }

  //show speed of motor
  //manual select speed
//  M1S_dif = int(bx - 260);
//  M2S_dif = int(by - 260);
//  
//  M1S_dif_mod = abs(M1S_dif) % 6;
//  M1S = (abs(M1S_dif) - M1S_dif_mod) / 6 ;
//  if (M1S > 0)
//  {
//    M1S = 19 + M1S;
//    M1_brake = false;
//  }
//  else
//    M1_brake = true;
//
//  
//  M2S_dif_mod = abs(M2S_dif) % 6;
//  M2S = (abs(M2S_dif) - M2S_dif_mod) / 6 ;
//  if (M2S > 0)
//  {
//    M2S = 19 + M2S;
//    M2_brake = false;
//  }
//  else
//    M2_brake = true;
  //controlled by nunchuck  
  
  int J1 = inBytes[0];
  int J2 = inBytes[1];
  
  bx = J1 - J1_base;
  bx = constrain(bx, -128, 128);
  bx = bx + 260;
  
  by = J2 - J2_base;
  by = constrain(by, -128, 128);
  by = -by + 260;
  
  if (bx > 260)
  {
    M1_C[3] = 'F';
  } else if(bx < 260)
  {
    M1_C[3] = 'R';
  }
 
  if (by > 260)
  {
    M2_C[3] = 'F';
  } else if(by < 260)
  {
    M2_C[3] = 'R';
  }
  
  
  M1S_dif = int(J1 - J1_base);
  M2S_dif = int(J2 - J2_base);
  
  M1S_dif_mod = abs(M1S_dif) % 6;
  M1S = (abs(M1S_dif) - M1S_dif_mod) / 6 ;
  if (M1S > 0)
  {
    M1S = 19 + M1S;
    M1_brake = false;
  }
  else
    M1_brake = true;
  
  //force to get to the range
  if (J1 == 255 || J1 == 0 || abs(M1S_dif) > 128)
  {
    M1S = 40;
    M1_brake = false;
  }

  
  M2S_dif_mod = abs(M2S_dif) % 6;
  M2S = (abs(M2S_dif) - M2S_dif_mod) / 6 ;
  if (M2S > 0)
  {
    M2S = 19 + M2S;
    M2_brake = false;
  }
  else
    M2_brake = true;
   
  //force to get to the range
  if (J2 == 255 || J2 == 0 || abs(M2S_dif) >128)
  {
    M2S = 40;
    M2_brake = false;
  }
  
  fill(255);  // Set fill to white
  ellipse(bx, by, 100, 100);  // Draw gray ellipse using CENTER mode
  
  fill(255);
  textSize(15);
  text("M1 " + char(M1_C[3]) + " :" + byte(M1S),700,50);
  text("M2 " + char(M2_C[3]) + " :" + byte(M2S),700,100);
  //debug signal
  text("J1 : " + J1, 700, 200);
  text("J2 : " + J2, 700, 250); 
  
  //parse speed value
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
  
//  if(update == 1)
//  {  
//    myPort.write(M1_C);
//    myPort.write(M2_C);
//    update = 0;
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

//
//  println("J1 is :" + J1);
//  println("J2 is :" + J2);
    
  while(myPort.available() > 0)
  {
//    println("port available");
    if(start_read == 0)
    {
      headByte = myPort.readChar();
//      println("headByte is "+headByte);
    }
      
    
    if(headByte == 'S')
    {
      start_read = 1;
      tempBytes[0] = headByte;
      headByte = '?';
      tempBytes[i] = myPort.readChar();
      i++;
//      println("temp 1  is "+tempBytes[1]);
    } else if(start_read == 1)
    {
      tempBytes[i] = myPort.readChar();

      if(i == 3)
      {
        i = 1;
        start_read = 0;
        myPort.clear();
        if(tempBytes[3] == '*')
        {
//          println("one data receive!");
          for (int num = 0; num < 2; num = num+1)
          {
            inBytes[num] = tempBytes[num+1];
          }
        }
      }else
      {
        i++;
      }
    }
  } 
}




void mousePressed() {
  if(inBox) { 
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
    //M1_C[3] = 'R';
  } else if(trig_FWD)
  {
    FWD_flag = 1;
    //M1_C[3] = 'F';
  }
  
  update = 1;
  M1_C[7] = '1';
}

void mouseDragged() {
  if(locked){
       bx = mouseX-xOffset; 
       by = mouseY-yOffset; 
       
       temp_diameter = (bx - 260)*(bx - 260) + (by  - 260)*(by  - 260);
       temp_radius = sqrt(temp_diameter);
       if( temp_radius > 128)
       {
         bx = 260 + 128 * (bx - 260) / temp_radius;
         by = 260 + 128 * (by - 260) / temp_radius;
       }
       
       //parse instruction
       if(bx > 260)
       {
         M1_C[3] = 'F';
       }else if(bx < 260)
       {
         M1_C[3] = 'R';
       }
       
       if(by > 260)
       {
         M2_C[3] = 'F';
       }else if(by < 260)
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
  bx = 260;
  by = 260;
  update = 1;
  M1_C[3] = 'B';
  M2_C[3] = 'B';
}

void keyReleased() {
  PID_flag = 0;
}



