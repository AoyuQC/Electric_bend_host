// Example by Tom Igoe
import processing.serial.*;
// STRING of COMMAND
byte[] M1_C = { '$', 'M', '1', 'F', '0', '0', '0', '1', '0', '*'};
byte[] M2_C = { '$', 'M', '2', 'F', '0', '0', '0', '1', '0', '*'};
byte[] num_value = { '0', '1', '2', '3', '4', '5', '6', '7', '8', '9'};
byte dir = 'F';
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
int x_old = 0;
int y_old = 3;
int m1_pwm = 0;
int m1_pwm_old = 0;
int y = 3;
float maxspeed = 5;
float minspeed = -5;
float setspeed = 3;
float setspeed_old = 3;
float speed_send_old = 3;
float speed_send = 3;
float const_speed = 10;
float const_speed_old = 10;
int speedchange = 0;
int m = 0;
int command_flag = 0;
int square_en = 1;
int const_en = 0;
int square_go = 1;
int const_go = 0;
int PID_flag = 0;
int Mode_flag = 0;
int REV_flag = 0;
int FWD_flag = 0;
int Speed_flag = 0;
int start_read = 0;
int Brake_flag = 0;
int Maxmin_flag = 0;
int AD_value = 0;
int AD_value_old = 0;
int Instr_flag = 0;
float P=600,I=5,D=1;
float error_history_old = 0;
float error_history = 0;
float M1_pwm = 0;
float M1_pwm_old = 0;
int i = 0;
char[] inBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E'};
char[] tempBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
char headByte = '+';
int debug_y_pos = 0;
int debug_x_pos = 0;
int neg_lock = 0;
int pos_lock = 0;
int start_error = 0;

void setup() 
{
  //List all the available serial ports:
  println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200, 'N', 8, 1);

  size(1500, 1000);
  bx = 500;
  by = 500;
  background(0);
  textSize(25);
  text("MAXSPEED "+maxspeed, 820, 900);
  text("MINSPEED "+minspeed, 1020, 900);
  text("P "+P, 100, 900);
  text("I "+I, 300, 900);
  text("D "+D, 500, 900);  
  //value of baseline
//  text(" 30RPS ", 1400, 100);
//  text("  3RPS ", 1400, 370);
//  text(" -3RPS ", 1400, 430);
//  text(" -30RPS ", 1400, 700);
}

void draw()
{
   
  if(x_old == 1400)
  {
    x_old = 0; 
    background(0);
    fill(0);
    noStroke();
    rect(100, 800, 1400, 100);
    fill(255); 
    stroke(255);
    textSize(25);
    text("MAXSPEED "+maxspeed, 820, 900);
    text("MINSPEED "+minspeed, 1020, 900);
    //value of baseline
//    text(" 30RPS ", 1400, 100);
//    text("  3RPS ", 1400, 370);
//    text(" -3RPS ", 1400, 430);
//    text(" -30RPS ", 1400, 700);
    //value of PID
    text("P "+P, 100, 900);
    text("I "+I, 300, 900);
    text("D "+D, 500, 900);
  }
   
  int PID_bit1 = int(inBytes[3]-'0'); 
  int PID_bit2 = int(inBytes[4]-'0');
  int PID_bit3 = int(inBytes[5]-'0'); 
  int PID_bit4 = int(inBytes[6]-'0'); 
  int PID_bit5 = int(inBytes[7]-'0');
  int PID_bit6 = int(inBytes[8]-'0'); 
  int PID_bit7 = int(inBytes[9]-'0'); 
  int PID_bit8 = int(inBytes[10]-'0');
  int PID_bit9 = int(inBytes[11]-'0');
  int PID_bit10 = int(inBytes[12]-'0');
  if(PID_bit1>=0 && PID_bit1<=9 && PID_bit2>=0 && PID_bit2<=9 && PID_bit3>=0 && PID_bit3<=9 && PID_bit4>=0 && PID_bit4<=9 && PID_bit5>=0 && PID_bit5<=9 && PID_bit7>=0 && PID_bit7<=9 && PID_bit8>=0 && PID_bit8<=9 && PID_bit9>=0 && PID_bit9<=9 && PID_bit10>=0 && PID_bit10<=9)
  {
   //println("P is : "+ inBytes[3] + inBytes[4] + inBytes[5] + " I is : " + inBytes[6] + inBytes[7] + inBytes[8] + " D is : " + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12] +" set speed is: "+const_speed);
   AD_value = PID_bit7*1000 + PID_bit8*100 + PID_bit9*10 + PID_bit10;
   M1_pwm = PID_bit1*10000 + PID_bit2*1000 + PID_bit3*100 + PID_bit4*10 + PID_bit5;
  }
  //measure speed
  int bit1 = int(inBytes[1]-'0'); 
  int bit0 = int(inBytes[2]-'0');
  int real_dir = int(inBytes[0]-'0');
  if(bit0>=0 && bit0<=9 && bit1>=0 && bit1<=9 && (real_dir==0 || real_dir==1))
    y = bit1*10 + bit0;
//    if(AD_value - AD_value_old > 8 || AD_value - AD_value_old < -8)
//    {
//      int temp_x = x_old + 1;
//      println("wrong pair AD is : " + AD_value + " and old is : " + AD_value_old + "  x is : " + temp_x);
//    }

  stroke(255);
    
  int temp_AD = int(AD_value/6);
  int temp_AD_old = int(AD_value_old/6);

  line(x_old,700-temp_AD_old,x_old+1,700-temp_AD);
    
  if(square_go == 1)
  {
   line(x_old,800-setspeed_old,x_old+1,800-setspeed); 
  }

  x_old = x_old + 1;
  y_old = y;
  speed_send_old = speed_send;
  setspeed_old = setspeed;
  AD_value_old = AD_value;
    
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
//            if(inBytes[num] == '#')
//              inBytes[num] = '0';
          }
      }else
      {
        i++;
      }
    }
  } 
}

void keyReleased() {
  //clear keyboard flag
  Mode_flag = 0;
  Speed_flag = 0;
  PID_flag = 0;
  Maxmin_flag = 0;
}



