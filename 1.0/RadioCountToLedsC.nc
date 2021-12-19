#include "AM.h"
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
    interface AMPacket;
  }
}

implementation
 {
   bool busy = FALSE;
   message_t pkt;
   uint16_t counter = 0;

   task void SendMsg();


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
     post SendMsg();
   }

   //***********************Task1 Interface*************************//
   task void SendMsg()
   {
      counter++;
      if (!busy)
      {
        radio_count_msg_t* mesg = (radio_count_msg_t*)(call Packet.getPayload(&pkt, sizeof (radio_count_msg_t)));
        mesg->node_id = TOS_NODE_ID;
        mesg->counter = counter;
 
        if (TOS_NODE_ID == 1)
        {
          dbg ("RadioSend","[%s] Sending a message to node 2 \n", sim_time_string());
          if (call AMSend.send(2, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
          {
            busy = TRUE;
          }
        }
        else if (TOS_NODE_ID == 2) {
          dbg ("RadioSend","[%s] Sending a message to node 3 \n", sim_time_string());
          if (call AMSend.send(3, &pkt, sizeof(radio_count_msg_t)) == SUCCESS)
          {
            busy = TRUE;
          } 
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
        dbg("RadioRec","[%s] Message successfully received at node %hhu\n",sim_time_string(), TOS_NODE_ID);
        dbg_clear ("Pkg","\t>>>Pack \n \t\t Payload length %hhu \n", call Packet.payloadLength (msg));
        dbg_clear ("Pkg","\t\t AM Adress: %hhu \n", call AMPacket.address ());
        dbg_clear ("Pkg","\t\t Source: %hhu \n", call AMPacket.source (msg));
        dbg_clear ("Pkg","\t\t Destination: %hhu \n", call AMPacket.destination (msg));
        dbg_clear ("Pkg","\t\t AM Type: %hhu \n", call AMPacket.type (msg));
        dbg_clear ("Pkg","\t\t\t Payload \n");
        dbg_clear ("Pkg","\t\t\t node_id:  %hhu \n", mesg->node_id);
        dbg_clear ("Pkg","\t\t\t value: %hhu \n", mesg->value);
        dbg_clear ("Pkg","\n");
       }
       else
       {
        dbg("RadioRec","[%s] Error encountered during reception! \n", sim_time_string());
       }
     }
     else
     {
      dbg("RadioRec","[%s] Error encountered during reception! \n", sim_time_string());
     }
     return msg;
   }

   ///***********************Senddone Event Interface*************************//
   event void AMSend.sendDone(message_t* msg, error_t error)
   {
      busy = FALSE;
      if (&pkt == msg&&error == SUCCESS)
      {
        if (TOS_NODE_ID == 1)
        {
          dbg("RadioSend","[%s] Packet has been successfully transmitted to node 2  \n", sim_time_string());
        // call MilliTimer.stop();
        }
        else if (TOS_NODE_ID == 2)
        {
          dbg("RadioSend","[%s] Packet has been successfully transmitted to node 3 \n", sim_time_string());
        }
        else if (TOS_NODE_ID == 3)
        {
          dbg("RadioSend","[%s] Packet has been successfully transmitted to node 2! \n", sim_time_string());
        }
        else
        {
          dbg("RadioSend","Error!Transmitter ID is not present! \n");
          dbg("RadioSend","Node ID is %hhu  \n",TOS_NODE_ID);
        }
      }
      else
      {
        dbg("RadioSend","Error encountered during the transmission, counter is %hu! \n", counter);
      }
   }
 }
