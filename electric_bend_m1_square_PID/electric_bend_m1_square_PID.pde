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
float minspeed = 5;
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
int instr_update = 1;
float P=600,I=5,D=1;
float error_history_old = 0;
float error_history = 0;
float M1_pwm = 0;
float M1_pwm_old = 0;
int i = 0;
char[] inBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E'};
char[] tempBytes = {'1', '2', '3',  '4', '5', '6', '7', '8', '9', 'A', 'B', 'C', 'D', 'E', 'F'};
char headByte = '+';

void setup() 
{
  //List all the available serial ports:
  println(Serial.list());
  // Open the port you are using at the rate you want:
  myPort = new Serial(this, Serial.list()[1], 115200, 'N', 8, 1);
  // Send initial command(brake) out the serial port
  //myPort.write(M1_C);
  //myPort.write(M2_C);
  command_flag = 1;
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
  text(" 30RPS ", 1400, 100);
  text("  3RPS ", 1400, 370);
  text(" -3RPS ", 1400, 430);
  text(" -30RPS ", 1400, 700);
}

void draw()
{ 
  
  if(keyPressed && (Mode_flag == 0))
  {
    //change adjust mode
    if(key == 'c')
    {
      square_en = 1 - square_en; //square adjust 
      const_en = 1 - const_en;   //constant speed
     
      if(square_en == 1 && const_en == 0)
      {
        square_go = 1;
        const_go = 0;
      }else if(square_en == 0 && const_en == 1)
      {
        square_go = 0;
        const_go = 1;
      }
      
      x_old = 0;
      background(0);
      //lock
      Mode_flag = 1;
    }
  }
  
  //change maxspeed minspeed
  if(keyPressed && (Maxmin_flag == 0))
  {
    //change maxspeed or minspeed
    if(key == 'q')
    {
      maxspeed = maxspeed + 1;
      if(maxspeed >= 30)
        maxspeed = 30;
      if(maxspeed <= minspeed)
        maxspeed = minspeed;
      //change direction
      if(maxspeed == -2)
        maxspeed = 3;
      //lock
      Maxmin_flag = 1;
    }
    
    if(key == 'w')
    {
      maxspeed = maxspeed - 1;
      if(maxspeed >= 30)
        maxspeed = 30;
      if(maxspeed <= minspeed)
        maxspeed = minspeed;
      //change direction
      if(maxspeed == 2)
        maxspeed = -3;
      //lock
      Maxmin_flag = 1;
    }
    
    if(key == 'e')
    {
      minspeed = minspeed + 1;
      if(minspeed >= maxspeed )
        minspeed = maxspeed;
      if(minspeed <=-30)
        minspeed = -30;
      //change direction
      if(minspeed == -2)
        minspeed = 3;
      //lock
      Maxmin_flag = 1;
    }
    
    if(key == 'r')
    {
      minspeed = minspeed - 1;
      if(minspeed >= maxspeed )
        minspeed = maxspeed;
      if(minspeed <= -30)
        minspeed  = -30;
      //change direction
      if(minspeed == 2)
        minspeed = -3;
      //lock
      Maxmin_flag = 1;
    }
    fill(0);
    noStroke();
    rect(820, 800, 400, 100);
    fill(255); 
    stroke(255);
    textSize(25);
    text("MAXSPEED "+maxspeed, 820, 900);
    text("MINSPEED "+minspeed, 1020, 900);
  }
  
 //change setspeed of constant speed mode
 if(keyPressed && (Speed_flag == 0))
 {
  if(key == 'z' || key == 'x')
    {
      if(key == 'z')
      {
        const_speed++;
      }
      if(key == 'x')
      {
        const_speed--;
      }    
      
      if(const_speed<=3)
        const_speed = 3;
      else if(const_speed>=30)
        const_speed = 30;
      
      //lock
      Speed_flag = 1;
    }
 }
 
 //adjust PID value
 if(keyPressed && (PID_flag == 0))
 {
  if(key == 'a' || key == 's' || key == 'd' || key == 'f' || key == 'g' || key == 'h' || key == 'j' || key == 'k') 
    {
      if(key == 'a' || key == 's')
      {
        if(key == 'a')
          P = P+10;
        else if(key == 's')
          P = P-10;
  
        if(P<=0)
          P = 0;
        else if(P>=999)
          P = 999;
  
        M1_C[1] = 'P';
        int PID_bit3 = int(P/100);
        int PID_bit2 = int((P - PID_bit3*100)/10);
        int PID_bit1 = int(P - PID_bit2*10 - PID_bit3*100);
        M1_C[2] = num_value[PID_bit3];
        M1_C[3] = num_value[PID_bit2];
        M1_C[4] = num_value[PID_bit1];
      }
      
      if(key == 'd' || key == 'f')
      {
        if(key == 'd')
          I = I+1;
        else if(key == 'f')
          I = I-1;
        
        if(I<=0)
          I = 0;
        else if(I>=999)
          I = 999;  
        
        M1_C[1] = 'I';
        int PID_bit3 = int(I/100);
        int PID_bit2 = int((I - PID_bit3*100)/10);
        int PID_bit1 = int(I - PID_bit2*10 - PID_bit3*100);
        M1_C[2] = num_value[PID_bit3];
        M1_C[3] = num_value[PID_bit2];
        M1_C[4] = num_value[PID_bit1];
      }
  
      if(key == 'g' || key == 'h' || key == 'j' || key == 'k')
      {
        if(key == 'g')
          D = D+10;
        else if(key == 'h')
          D = D-10;
        else if(key == 'j')
          D = D+100;
        else if(key == 'k')
          D = D-100;
        
        if(D<=0)
          D = 0;
        else if(D>=9999)
          D = 9999;
        
        M1_C[1] = 'D';
        int PID_bit4 = int(D/1000);
        int PID_bit3 = int(D - PID_bit4*1000)/100;
        int PID_bit2 = int(D - PID_bit4*1000 - PID_bit3*100)/10;
        int PID_bit1 = int(D - PID_bit4*1000 - PID_bit3*100 - PID_bit2*10);
        M1_C[2] = num_value[PID_bit4];
        M1_C[3] = num_value[PID_bit3];
        M1_C[4] = num_value[PID_bit2];
        M1_C[5] = num_value[PID_bit1];
      }
      
      if(M1_C[1] == 'D')
        M1_C[6] = '*';
      else
        M1_C[5] = '*';
      
      //lock
      PID_flag = 1;
      myPort.write(M1_C);
      

    fill(0);
    noStroke();
    rect(100, 800, 950, 100);
    fill(255); 
    stroke(255);
    textSize(25);    
    text("P "+P, 100, 900);
    text("I "+I, 300, 900);
    text("D "+D, 500, 900);
    }else if(key == 'b')
    {
//      M1_C[1] = 'M';
//      M1_C[2] = '1';
//      M1_C[3] = 'B';
//      M1_C[4] = '0';
//      M1_C[5] = '0';
//      M1_C[6] = '0';
//      M1_C[7] = '0';
//      M1_C[8] = '3';
//      M1_C[9] = '*';
      
      M2_C[1] = 'M';
      M2_C[2] = '1';
      M2_C[3] = 'B';
      M2_C[4] = '0';
      M2_C[5] = '0';
      M2_C[6] = '0';
      M2_C[7] = '0';
      M2_C[8] = '3';
      M2_C[9] = '*';
      //lock
      PID_flag = 1;
      //lock forward command
      Brake_flag = 1 - Brake_flag;
      //myPort.write(M1_C);
      myPort.write(M2_C);
    }
  }
  
  // show speed value
  m = m + 1;
  if(m % 60 == 0)
  {
    if(square_go == 1)
    {
      if(speedchange%2 == 0)
      {
        setspeed_old = setspeed;
        setspeed = maxspeed;
      }
      else
      {
        setspeed_old = setspeed;
        setspeed = minspeed;
      }
      speedchange++;
      
      if(minspeed == maxspeed)
        instr_update = 0;
      else
        instr_update = 1;
     //m1_pwm = 25 - m1_pwm;
    }else if(const_go == 1)
    {
     speed_send = const_speed;
    }
    //parse direciton
    dir = 'F';
    if(setspeed >= 0)
      dir = 'F';
    if(setspeed < 0)
      dir = 'R';
    //dir = 'R';
    //parse speed value
    speed_send = abs(setspeed);
    int speed_bit2 = int(speed_send/10);
    int speed_bit1 = int(speed_send - speed_bit2*10);
    //println("speedsend is: "+ speed_send);
    
    if(Brake_flag == 0 && instr_update == 1)
    {
//      M1_C[1] = 'M';
//      M1_C[2] = '1';
//      M1_C[3] = dir;
//      M1_C[4] = '0';
//      M1_C[5] = '0';
//      M1_C[6] = '0';
//      M1_C[7] = num_value[speed_bit2];
//      M1_C[8] = num_value[speed_bit1];
//      M1_C[9] = '*';
//      myPort.write(M1_C);
//      command_flag = 1;

      M2_C[1] = 'M';
      M2_C[2] = '1';
      M2_C[3] = dir;
      M2_C[4] = '0';
      M2_C[5] = '0';
      M2_C[6] = '0';
      M2_C[7] = num_value[speed_bit2];
      M2_C[8] = num_value[speed_bit1];
      M2_C[9] = '*';
      myPort.write(M2_C);
      command_flag = 1;
    }
  }
   
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
    text(" 30RPS ", 1400, 100);
    text("  3RPS ", 1400, 370);
    text(" -3RPS ", 1400, 430);
    text(" -30RPS ", 1400, 700);
    //value of PID
    text("P "+P, 100, 900);
    text("I "+I, 300, 900);
    text("D "+D, 500, 900);
  }
   
  //println("square_en: "+square_en+" square_go: "+square_go+ " const_en: "+const_en+" const_go: "+const_go);
  //println("y: "+y+" y_old: "+y_old+ " const_speed: "+const_speed+" const_speed_old: "+const_speed_old);
    //text("received: " + inString, 10,50);
    //y = int(inString.charAt(0)-'0')*100 + int(inString.charAt(1)-'0')*10 + int(inString.charAt(2)-'0');
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
      println("P is : "+ inBytes[3] + inBytes[4] + inBytes[5] + " I is : " + inBytes[6] + inBytes[7] + inBytes[8] + " D is : " + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12] +" set speed is: "+const_speed);
      error_history = PID_bit7*1000 + PID_bit8*100 + PID_bit9*10 + PID_bit10;
      M1_pwm = PID_bit1*10000 + PID_bit2*1000 + PID_bit3*100 + PID_bit4*10 + PID_bit5;
    }
    //measure speed
    int bit1 = int(inBytes[1]-'0'); 
    int bit0 = int(inBytes[2]-'0');
    int real_dir = int(inBytes[0]-'0');
    if(bit0>=0 && bit0<=9 && bit1>=0 && bit1<=9 && (real_dir==0 || real_dir==1))
      y = bit1*10 + bit0;
    //int bit2 = int(inBytes[0]-'0');
    //if(bit0>=0 && bit0<=9 && bit1>=0 && bit1<=9 && bit2>=0 && bit2<=9 && PID_bit1>=0 && PID_bit1<=9 && PID_bit2>=0 && PID_bit2<=9)
    //  println("delta error is "+inBytes[0]+inBytes[1]+inBytes[2]+inBytes[3]+inBytes[4]);
    //{
    //  y = bit2*10000 + bit1*1000 + bit0*100 + PID_bit1*10 + PID_bit2;  
    //  y = y/1000;
    //}
//    if(y>100)
//      println(" one time Byte value " + inBytes[0] + inBytes[1] + inBytes[2] + inBytes[3] + inBytes[4] + inBytes[5] + inBytes[6] + inBytes[7] 
//       + inBytes[8] + inBytes[9] + inBytes[10] + inBytes[11] + inBytes[12] + " temp Bytes :" + tempBytes[0] + tempBytes[1] + tempBytes[2] + tempBytes[3] 
//+ tempBytes[4] + tempBytes[5] + tempBytes[6] + tempBytes[7] + tempBytes[8] + tempBytes[9] + tempBytes[10] + tempBytes[11] + tempBytes[12] + tempBytes[13]);
    stroke(255);
    if(real_dir == 1)
    {
      line(x_old,400-y_old*10,x_old+1,400-y*10);
      line(x_old,800-y_old,x_old+1,800-y);
    }
    if(real_dir == 0)
    {
      line(x_old,400+y_old*10,x_old+1,400+y*10);
      line(x_old,800+y_old,x_old+1,800+y);
    }
    
//    stroke(0, 204, 0); 
//    if(PID_bit6 == 1)
//    {
//      line(x_old,800-error_history_old/20,x_old+1,800-error_history/20);
//    }
//    if(PID_bit6 == 0)
//    {
//      line(x_old,800+error_history_old/20,x_old+1,800+error_history/20);
//    }
//    stroke(255);
//      line(1,600,1400,600);
//      line(1,600-24,1400,600-24);
//    stroke(255,1,0);
//      line(x_old,600-M1_pwm_old/50,x_old+1,600-M1_pwm/50);
//    stroke(255);
//    stroke(204, 102, 0);
    if(x_old%5==0)
    {
      point(x_old,400-setspeed*1.1*10);
      point(x_old,400-setspeed*0.9*10);
    }
    
    //debug
    //line(x_old,500-13*10,x_old+1,500-13*10);
    
    //base line
    //maxspeed minspeed baseline
    stroke(204, 102, 0);
    line(0,400-30*10,1400,400-30*10);
    line(0,400+30*10,1400,400+30*10);
    line(0,400-3*10,1400,400-3*10);
    line(0,400+3*10,1400,400+3*10);
    
    line(0,800-30,1400,800-30);
    line(0,800+30,1400,800+30);
    line(0,800-3,1400,800-3);
    line(0,800+3,1400,800+3);
    
    stroke(255);
    
    if(square_go == 1)
    {
//      line(x_old,500-speed_send_old*10,x_old+1,500-speed_send*10);
//      line(x_old,600-speed_send_old,x_old+1,600-speed_send);
      line(x_old,400-setspeed_old*10,x_old+1,400-setspeed*10);
      line(x_old,800-setspeed_old,x_old+1,800-setspeed);
      //test M1_PWM value
//      line(x_old,500-m1_pwm_old*10,x_old+1,500-m1_pwm*10);
//      line(x_old,600-m1_pwm_old,x_old+1,600-m1_pwm);     
    }else if(const_go == 1)
    {
      line(x_old,500-const_speed_old*10,x_old+1,500-const_speed*10);
      line(x_old,600-const_speed_old,x_old+1,600-const_speed);
    }

    x_old = x_old + 1;
    y_old = y;
    speed_send_old = speed_send;
    setspeed_old = setspeed;
    const_speed_old = const_speed;
    M1_pwm_old = M1_pwm;
    error_history_old = error_history;
    
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

void keyReleased() {
  //clear keyboard flag
  Mode_flag = 0;
  Speed_flag = 0;
  PID_flag = 0;
  Maxmin_flag = 0;
}



