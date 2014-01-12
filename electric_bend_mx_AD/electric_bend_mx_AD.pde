// Example by Tom Igoe
import processing.serial.*;
// STRING of COMMAND
byte[] M_C = { '$', 'M', '1', 'F', '0', '0', '0', '1', '0', '*'};
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
int x_new = 0;
int x_old = 0;
int y_old = 3;
int m1_pwm = 0;
int m1_pwm_old = 0;
int y = 3;
float maxspeed = -20;
float minspeed = -20;
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
// for frame change
int frame_count = 0;
int[] AD_back = new int[1440];

void setup() 
{
  //List all the available serial ports:
  println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200, 'N', 8, 1);
  
  command_flag = 1;
  size(1500, 1000);
  bx = 500;
  by = 500;
  background(0);
  textSize(25);
  text("MAXSPEED "+maxspeed, 820, 900);
  text("MINSPEED "+minspeed, 1020, 900);
  text("NO TOUCH RECORDING...... ", 100, 900);  
}

void draw()
{
  if (keyPressed && (PID_flag == 0))
  {
    if (key == 'b'|| key == 'B')
    {   
      M_C[1] = 'M';
      M_C[2] = '1';
      M_C[3] = 'B';
      M_C[4] = '0';
      M_C[5] = '0';
      M_C[6] = '0';
      M_C[7] = '0';
      M_C[8] = '3';
      M_C[9] = '*';
      Instr_flag = 1;
      //lock
      PID_flag = 1;
      //lock forward command
      Brake_flag = 1 - Brake_flag;
      //myPort.write(M1_C);
      myPort.write(M_C);
    }
  }

  if (keyPressed && (Frame_flag == 0))  
  {
    if (key == 'n'|| key == 'N')
    {
      // initial status
      if (frame_change % 2 == 0)
      {
        m = 0;
        x_old = 0;
      }        

      Instr_flag = 1;
      //lock
      Frame_flag = 1;
    }
  }
  
  // show speed value
  m = m + 1;
  if(m % 60 == 0)
  {
    // initial status
    if (m % 1440 < 60)
    {
      Instr_flag = 0;
    } else
    {
      Instr_flag = 1;
    }
      
    // trigger foward at 1 s
    if (m % 1440 == 60)
    {
      maxspeed = 15;
      minspeed = 15;
    }
    
    // trigger reverse at 12s
    if (m % 1440 == 720)
    {
      maxspeed = -15;
      minspeed = -15;
    }
    
    if (speedchange%2 == 0)
    {
      setspeed_old = setspeed;
      setspeed = maxspeed;
    } else
    {
      setspeed_old = setspeed;
      setspeed = minspeed;
    }
    speedchange++;
    
    //parse direciton
    if(setspeed >= 0)
      dir = 'F';
    if(setspeed < 0)
      dir = 'R';
    //parse speed value
    speed_send = abs(setspeed);
    int speed_bit2 = int(speed_send/10);
    int speed_bit1 = int(speed_send - speed_bit2*10);
    //println("speedsend is: "+ speed_send);
    if (Brake_flag == 0 && Instr_flag == 1)
    {
      M_C[1] = 'M';
      M_C[2] = '1';
      M_C[3] = dir;
      M_C[4] = '0';
      M_C[5] = '0';
      M_C[6] = '0';
      M_C[7] = num_value[speed_bit2];
      M_C[8] = num_value[speed_bit1];
      M_C[9] = '*';
      myPort.write(M_C);
      command_flag = 1;
    }
  }
   
  if (x_old == 1440)
  {
    frame_count++;
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

    if (frame_count % 2 == 0)
    {
      text("NO TOUCH RECORDING...... ", 100, 900);  
    } else
    {
      text("TOUCHED COMPARING...... ", 100, 900);
    }  
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
  if(PID_bit1>=0 && PID_bit1<=9 && PID_bit2>=0 && PID_bit2<=9 && PID_bit3>=0 && PID_bit3<=9 && PID_bit4>=0 && PID_bit4<=9 && PID_bit5>=0 && PID_bit5<=9 && PID_bit6>=0 && PID_bit6<=9 && PID_bit7>=0 && PID_bit7<=9 && PID_bit8>=0 && PID_bit8<=9 && PID_bit9>=0 && PID_bit9<=9 && PID_bit10>=0 && PID_bit10<=9)
  {
    //println("P is : "+ inBytes[3] + inBytes[4] + inBytes[5] + " I is : " + inBytes[6] + inBytes[7] + inBytes[8] + " D is : " + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12] +" set speed is: "+const_speed);
    AD_value = PID_bit7*1000 + PID_bit8*100 + PID_bit9*10 + PID_bit10;
  }

  stroke(255);
    
  int temp_AD = int(AD_value * 1 / 6);
  int temp_AD_old = int(AD_value_old * 1 / 6);
  line(x_old,700-temp_AD_old,x_old+1,700-temp_AD);   
    
  if (frame_count % 2 == 0)
  {
    AD_back[x_old] = temp_AD; 
  } else
  {
    stroke(204, 102, 0);
    if (x_old == 0)
    {
      x_new = 0;
    } else
    {
      x_new = x_old - 1;
    }
    int dif_old = AD_value - AD_back[x_old] * 6;
    int dif_new = AD_value_old - AD_back[x_new] * 6;
    line(x_old,700 - AD_back[x_new],x_old+1,700-AD_back[x_old]);
    line(x_old,700 - dif_new,x_old + 1,700 - dif_old);
    stroke(255);
  }  

  x_old = x_old + 1;
  y_old = y;
  AD_value_old = AD_value;
  
  // lines to indicate speed change
  line(60,0,60,1000);
  line(720,0,720,1000);
    
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

void keyReleased()
{
  //clear keyboard flag
  PID_flag = 0;
  Frame_lock = 0;
}



