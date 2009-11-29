#!/usr/bin/env pike
import Stdio;

object con = File();

int main(){
   string server   = "irc.eighthbit.net";
   string nick     = "Spike";
   string userln   = "spike spike spike spike";
   int port        = 6667;
   array channels  = ({"#bots"});

   if(!con->connect(server,port)) {
      write("Unable to connect to " + server + "\n");
      exit(0);
   }
   // Still alive \o/

   con->set_nonblocking();
   sendln("NICK " + nick);
   sendln("USER " + userln);
   foreach(channels, string channel) {
      sendln("JOIN " + channel);
   }

   while(1){
      string data = con->read();
      if(data != 0){
         write("-> " + data + "\n");
         if(Regexp.match("PING",data) == 1){
            // Probably a better way to parse this.
            if(array ping = Regexp.split2("PING :(.*)",data)){
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
      }
   }
}

string sendln(string raw) {
   write("<- " + raw + "\n");
   con->write(raw + "\r\n");
}
