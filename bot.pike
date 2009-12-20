#!/usr/bin/env pike
import Stdio;

object con = File();

int main(){
   string server   = "irc.eighthbit.net";
   string nick     = "Spike";
   string userln   = "spike spike spike spike";
   int port        = 6667;
   array channels  = ({"#bots"});

   connect(server,nick,userln,port,channels,1);

   // Still alive \o/
   string data;
   
   while(1){
      data = con->read();
      if(data) write(data + "\n");

      if(data != 0){
         if(data == ""){
            write("Reconnecting in 5 seconds.\n");
            sleep(5);
            if(connect(server,nick,userln,port,channels,1) == 1){
               // We can add something here to do something once we reconnect.
               // Not necessary, but doable.
            }
         }

         if(Regexp.match("^PING",data) == 1){
            // Probably a better way to parse this.
            if(array ping = Regexp.split2("PING (.*)",data)){
               sendln("PONG " + ping[1]);
            }
         }
         array pts = Regexp.split2(":(.+)!(.+)@(.+) PRIVMSG (.+) :(.+)", data);

         if(Regexp.match("!test",data) == 1){
            sendln("PRIVMSG " + pts[4] + " :you are " + pts[1]);
         }
         if(Regexp.match("!time",data) == 1){
            int hour = localtime(time())["hour"];
            int minute = localtime(time())["min"];
            sendln("PRIVMSG " + pts[4] + " :time is " + hour + ":" + minute);
         }
         if(Regexp.match("!randstr",data) == 1){
            sendln("PRIVMSG " + pts[4] + " :" + replace(replace(random_string(255),"\n",""),"\r",""));
         }
         if(Regexp.match("!join",data) == 1){
            if(array channel = Regexp.split2("^!join (.+)",pts[5])){
               sendln("JOIN " + channel[1]);
            }
         }
         if(Regexp.match("!murder",data) == 1){
            if(array who = Regexp.split2("^!murder (.+)",pts[5])){
               sendln("PRIVMSG " + pts[4] + " :\001ACTION murders " + (who[1] - "\r" - "\n" - " ") + " as per " + pts[1] + "'s command.\001");
            }
         }
      }
   }
}

int connect(string server, string nick, string userln, int port, array channels, int firstconnect) {
   // If we're just starting the script and unable to connect, don't keep trying, just die.
   // But if we've been connected and just lost the conn. for some reason, then try to regain it.

   con->close();

   if(con->connect(server,port)) {
      err("Connected to server!");
   } else {
      con->connect(server,port);
   }
   
   // We've connected.
   con->set_nonblocking();
   sendln("NICK " + nick);
   sendln("USER " + userln);
   foreach(channels, string channel) {
      sendln("JOIN " + channel);
   }
   if(firstconnect == 0){
      sendln("PRIVMSG #bots :I reconnected. Yay me.");
   }
   return 1;
}

void err(string message){
   write("+++ " + message + " +++\n");
}

void sendln(string raw) {
   write("<- " + raw + "\n");
   con->write(raw + "\r\n");
}
