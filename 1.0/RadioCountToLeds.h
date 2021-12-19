#ifndef BLINK_TO_RADIO_H
#define BLINK_TO_RADIO_H

typedef nx_struct radio_count_msg {
  nx_uint16_t counter;
  nx_uint8_t node_id;
  nx_uint8_t value;
} radio_count_msg_t;

enum {
  AM_RADIO_COUNT_MSG  = 240,
  TIMER_PERIOD_MILLI = 250,
};

#endif
