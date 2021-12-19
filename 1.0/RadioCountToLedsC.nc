#include "Timer.h"
#include "RadioCountToLeds.h"
 
/**
 * Implementation of the RadioCountToLeds application. RadioCountToLeds 
 * maintains a 4Hz counter, broadcasting its value in an AM packet 
 * every time it gets updated. A RadioCountToLeds node that hears a counter 
 * displays the bottom three bits on its LEDs. This application is a useful 
 * test to show that basic AM communication and timers work.
 *
 * @author Philip Levis
 * @date   June 6 2005
 */

module RadioCountToLedsC @safe() {
  uses {
    interface Leds;
    interface Boot;
    interface Receive;
    interface AMSend;
    interface Timer<TMilli> as MilliTimer;
    interface SplitControl as AMControl;
    interface Packet;
   //  interface AMPacket;
  }
}

implementation
 {
   bool busy = FALSE;
   message_t pkt;
   uint16_t counter = 0;

   task void SendMsg1_2();
   task void SendMsg2_Radio();
   task void Intercept();


   //********************Boot Interface****************//
   event void Boot.booted()
   {
     dbg("Boot","Application booted for node (%d).\n",TOS_NODE_ID);
     call AMControl.start();
   }

   //********************SplitControl Interface*************//
   event void AMControl.startDone(error_t err)
   {
     if (err == SUCCESS)
     {
        dbg("Radio","Radio is on!\n");
        call MilliTimer.startPeriodic(TIMER_PERIOD_MILLI);
     }
     else
      {
          call AMControl.start();
      }

    }

   event void AMControl.stopDone(error_t err)
    {      }


   //************************MilliTimer Interface********************//
   event void MilliTimer.fired()
   {
     post SendMsg1_2();
   }

   //***********************Task1 Interface*************************//
   task void SendMsg1_2()
   {
      counter++;
      if (!busy)
       {
         radio_count_msg_t* mesg = (radio_count_msg_t*)(call Packet.getPayload(&pkt, sizeof (radio_count_msg_t)));
         mesg->node_id = TOS_NODE_ID;
        mesg->counter = counter;
 
       if (TOS_NODE_ID == 1)
        {
        dbg ("RadioSend","Sending a message to node 2 \n");
          if (call AMSend.send(2, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
          {
            busy = TRUE;
          }
        }
        else if (TOS_NODE_ID == 2) {
        dbg ("RadioSend","Sending a message to node 3 \n");
          if (call AMSend.send(3, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
            {
        busy = TRUE;
    }
           
        }
     }
   }

   //***********************Task2 Interface*************************//
   task void SendMsg2_Radio()
   {
     counter++;
     //call Leds.set(counter);
   if (!busy )
     {
       if (TOS_NODE_ID == 2)
        {
        radio_count_msg_t* mesg = (radio_count_msg_t*)(call Packet.getPayload(&pkt, sizeof (radio_count_msg_t)));
        mesg->node_id = TOS_NODE_ID;
        mesg->counter = counter;
        dbg ("RadioSend","Sending a message to node 3 \n");
        if (call AMSend.send(3, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
        {
  //        dbg_clear ("Pkg",">>>Pack \n \t Payload length %hhu \n", call Packet.payloadLength (&pkt));
  //        dbg_clear ("Pkg","\t Source: %hhu \n", call AMPacket.source (&pkt));
    //      dbg_clear ("Pkg","\t Destination: %hhu \n", call AMPacket.destination (&pkt));
      //    dbg_clear ("Pkg","\t AM Type: %hhu \n", call AMPacket.type (&pkt));
//          dbg_clear ("Pkg","\t\t Payload \n");
  //        dbg_clear ("Pkg","\t\t node_id:  %hhu \n", mesg->node_id);
 //         dbg_clear ("Pkg","\t\t msg_number: %hhu \n", mesg->counter);
        //  dbg_clear ("Pkg","\t\t value: %hhu \n", mesg->value);// call AMPacket.source (&pkt));
//          dbg_clear ("Pkg","\n");// call AMPacket.source (&pkt));
          busy = TRUE;
        }
        }
     }
   }

   ///***********************Intercept Interface*************************//
   task void Intercept()
   {
  //   counter++;
     //call Leds.set(counter);
   if (!busy && TOS_NODE_ID == 3)
     {
        radio_count_msg_t* mesg = (radio_count_msg_t*)(call Packet.getPayload(&pkt, sizeof (radio_count_msg_t)));
        mesg->node_id = TOS_NODE_ID;
        mesg->counter = counter;
        dbg ("RadioSend","Sending a corrupted message to node 1 \n");
          if (call AMSend.send(1, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
          {
          busy = TRUE;
          }
     }
   }

  //***********************Receive Event Interface*************************//
   event message_t* Receive.receive(message_t* msg, void* payload, uint8_t len)
   {
     if (len == sizeof(radio_count_msg_t))
     {
       if (TOS_NODE_ID == 2 || TOS_NODE_ID == 3)
       {
         radio_count_msg_t* mesg = (radio_count_msg_t*)payload;
         call Leds.set(mesg->counter);
//         post SendMsg2_Radio();
         dbg("RadioRec","Message successfully received at node 2 at time %s \n",sim_time_string());
         dbg_clear ("Pkg",">>>Pack \n \t Payload length %hhu \n", call Packet.payloadLength (&pkt));
  //       dbg_clear ("Pkg","\t Source: %hhu \n", call AMPacket.source (&pkt));
    //     dbg_clear ("Pkg","\t Destination: %hhu \n", call AMPacket.destination (&pkt));
//         dbg_clear ("Pkg","\t AM Type: %hhu \n", call AMPacket.type (&pkt));
         dbg_clear ("Pkg","\t\t Payload \n");
         dbg_clear ("Pkg","\t\t node_id:  %hhu \n", mesg->node_id);
         dbg_clear ("Pkg","\t\t msg_number: %hhu \n", mesg->counter);
         dbg_clear ("Pkg","\t\t value: %hhu \n", mesg->value);
         dbg_clear ("Pkg","\n");
       }
       else if (TOS_NODE_ID == 1)
       {
         radio_count_msg_t* mesg = (radio_count_msg_t*)payload;
         call Leds.set(mesg->counter);
         dbg("RadioRec","Message successfully received at node 1 at time %s \n",sim_time_string());
         post SendMsg1_2();
         dbg("RadioRec","Message received at node 1 at time %s \n",sim_time_string());
      } 
       else if (TOS_NODE_ID == 3)
       {
         radio_count_msg_t* mesg = (radio_count_msg_t*)payload;
         call Leds.set(mesg->counter);
         dbg("RadioRec","Message is captured by adversary at time %s \n",sim_time_string());
//         post Intercept();
       }
       else
       {
         dbg("RadioRec","Error encountered during reception! \n");
       }
     }
     else
     {
       dbg("RadioRec","Error encountered during reception! \n");
     }
     return msg;
   }

   ///***********************Senddone Event Interface*************************//
   event void AMSend.sendDone(message_t* msg, error_t error)
   {
      if (&pkt == msg&&error == SUCCESS)
      {
        if (TOS_NODE_ID == 1)
        {
          dbg("RadioSend","Transmitter ID is %hhu \n",TOS_NODE_ID);
          dbg("RadioSend","Packet has been successfully transmitted to node 2 at %s! \n", sim_time_string());
          busy = FALSE;
        // call MilliTimer.stop();
        }
        else if (TOS_NODE_ID == 2)
        {
          dbg("RadioSend","Transmitter ID IS %hhu \n",TOS_NODE_ID);
          dbg("RadioSend","Packet has been successfully transmitted to node 3 at %s! \n", sim_time_string());
          busy = FALSE;
        }
        else if (TOS_NODE_ID == 3)
        {
          dbg("RadioSend","Transmitter ID IS %hhu \n",TOS_NODE_ID);
          dbg("RadioSend","Packet has been successfully transmitted to node 2! \n");
          busy = FALSE; 
        }
        else
        {
          dbg("RadioSend","Error!Transmitter ID is not present! \n");
          dbg("RadioSend","Node ID is %hhu  \n",TOS_NODE_ID);
          post SendMsg2_Radio();
        }
      }
      else
      {
         dbg("RadioSend","Error encountered during the transmission! \n");
      }
   }
 }
