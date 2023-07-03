# C.A.R.P.

_Call Aware Radio Player_

![](logo.jpg)

A radio player which stops playing whenever a call is joined. Playing is resumed after the call has ended.

Tested on Ubuntu Linux with:

- MS Teams
- Slack Hangouts

C.A.R.P. is implemented in a single shell script.

## Preconditions

- Linux with Pulse Audio Environment
- _mpg123_ and _pactl_ installed.

  On Ubuntu:
  `sudo apt install mpg123 pulseaudio-utils`


## Setup

`carp.sh` is a shell script which polls the status of your Microphone every second.

- whenever the microphone becomes used, `carp.sh` assumes that a call has started.
- whenever it becomes available again, `carp.sh` assumes that the call has ended.

In order to pause / resume a radio station it needs to know three things from you:


### 1. Streaming URL of a radio station

You can lookup the streaming URL of your preferred radio station on the Internet.

For example at https://streamurl.link/

My favorite radio station is [Radio FM4](https://fm4.orf.at/). Its streaming URL is the default in `carp.sh`. Modify this line with your URL:

```
RADIO_STATION_URL="http://ors-sn06.ors-shoutcast.at/fm4-q2a"
```

### 2. Pulse audio name of your microphone source

The pulse audio name of your microphone can be looked up with this command line:

```
pactl list short sources
```

In case the command lists more than one device you might need to try them out until you find the right one.

Exchange this value in `carp.sh` with your microphone device:

```
CALL_MICROPHONE_DEVICE="alsa_input.usb-0b0e_Jabra_Link_370_50C2ED094FE8-00.mono-fallback"
```

### 3. Pulse audio name of your output device for playing radio

I usually do my calls with a Jabra headset. But for listening to music, I prefer some real speakers. Therefore you can explicitlly define the output sink for radio.

Similar to the lookup of the microphone device, you can lookup your output devices.

```
pactl list short sinks
```

Exchange this value in `carp.sh` with your preferred output device:

```
RADIO_OUTPUT_DEVICE="alsa_output.pci-0000_01_00.1.hdmi-stereo"
```

## Execution

Just run `./carp.sh` in your terminal.


