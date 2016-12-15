--- server mode ---
info: Connect device to Mobile phone by bluetooth and make sure that sound is playing using connector J 19 in device.

1. Start the device in A2DP server mode, run the following command (Into console of device):
# /opt/var-bluetooth-snd-dev/./bluetooth-snd-server.sh

2. scan and connecting the external device to Variscite board over bluetooth

3. Trusr external device to Variscite board
/opt/var-bluetooth-snd-dev/./bluetooth-snd-server.sh -t C8:14:79:27:F1:82
Where "bd adress" we can get with command "hcitool scan"

For example:
# /opt/var-bluetooth-snd-dev/./bluetooth-snd-server.sh
.. connect external device via bluetooth
# /opt/var-bluetooth-snd-dev/./bluetooth-snd-server.sh -t C8:14:79:27:F1:82
 [NEW] Controller F8:DC:7A:07:8D:A6 VAR-A2DP [default]
 [NEW] Device C8:14:79:27:F1:82 SM-T315
 [bluetooth]# trust C8:14:79:27:F1:82
 [bluetooth]# quit
 [DEL] Controller F8:DC:7A:07:8D:A6 VAR-A2DP [default]

On the side of the client device to connect to the device VAR-A2DP and play sound through it.
For audio playback, make sure you connect headphones or speakers to the connector J19 in device.

Note: If sound not playing you can see paragraph "FAQ".


--- client mode ---
info: Connect and play sound through bluetooth headphones.

---- connect ----
Into console of device:
1. Start utilite "bluetoothctl":
	root@imx6ul-var-dart:~# bluetoothctl

example:
 bluetoothctl
 [NEW] Controller F8:DC:7A:07:8D:A6 VAR-A2DP [default]
 [NEW] Device C8:14:79:27:F1:82 SM-T315
 [bluetooth]#

2. Prepare to сonnection:
	[bluetooth]# power on
	[bluetooth]# agent on
	[bluetooth]# default-agent

example:
 [bluetooth]# power on
 Changing power on succeeded
 [bluetooth]# agent on
 Agent registered
 [bluetooth]# default-agent
 Default agent request successful
 [bluetooth]#

4. Now make sure that your headphones are in pairing mode. They need to show up.

3. Enable scanning
	[bluetooth]# scan on

example:
 [NEW] Device 68:DF:DD:5D:CF:96 malupas
 [NEW] Device 00:06:F7:B3:E9:ED MM100
 [NEW] Device 00:07:80:41:68:15 KTS540_0000000
 [NEW] Device C8:14:79:27:F1:82 SM-T315
 [bluetooth]# scan on
 Discovery started
 [CHG] Controller F8:DC:7A:07:8D:A6 Discovering: yes
 [CHG] Device 00:06:F7:B3:E9:ED RSSI: -57
 [CHG] Device 00:07:80:41:68:15 RSSI: -65
 [CHG] Device 68:DF:DD:5D:CF:96 RSSI: -98
 [CHG] Device 00:07:80:41:68:15 RSSI: -73

My bluetooth headphones is "[NEW] Device 00:06:F7:B3:E9:ED MM100"

4. Disable scanning
	[bluetooth]# scan off

example:
 [bluetooth]# scan off
 Discovery stopped
 [CHG] Controller F8:DC:7A:07:8D:A6 Discovering: no
 [bluetooth]#

5. pairing device
	[bluetooth]# pair 00:06:F7:B3:E9:ED

6. connecting device
	[bluetooth]# connect 00:06:F7:B3:E9:ED

example:
 [bluetooth]# connect 00:06:F7:B3:E9:ED
 Attempting to connect to 00:06:F7:B3:E9:ED
 [CHG] Device 00:06:F7:B3:E9:ED Connected: yes
 Connection successful
 [MM100]#

7. trusting device
	[MM100]# trust 00:06:F7:B3:E9:ED

example:
 [MM100]# trust 00:06:F7:B3:E9:ED
 [CHG] Device 00:06:F7:B3:E9:ED Trusted: yes
 Changing 00:06:F7:B3:E9:ED trust succeeded
 [MM100]#

8. quit from bluetoothctl console
	[MM100]# quit

example:
 [MM100]# quit
 [DEL] Controller F8:DC:7A:07:8D:A6 VAR-A2DP [default]
 root@imx6ul-var-dart:~#

---- play test sound to M100 headphones ----

1. Card check availability.
	# pactl list cards

example:
 root@imx6ul-var-dart:~# pactl list cards
 Card #0
        Name: alsa_card.platform-sound
        Driver: module-alsa-card.c
        Owner Module: 6
        Properties:
                alsa.card = "0"
                alsa.card_name = "wm8731-audio"
                alsa.long_card_name = "wm8731-audio"
                device.bus_path = "platform-sound"
                sysfs.path = "/devices/platform/sound/sound/card0"
                device.string = "0"
                device.description = "wm8731-audio"
                module-udev-detect.discovered = "1"
                device.icon_name = "audio-card"
        Profiles:
                input:analog-mono: Analog Mono Input (sinks: 0, sources: 1, priority: 2, available: yes)
                input:analog-stereo: Analog Stereo Input (sinks: 0, sources: 1, priority: 60, available: yes)
                output:analog-mono: Analog Mono Output (sinks: 1, sources: 0, priority: 200, available: yes)
                output:analog-mono+input:analog-mono: Analog Mono Duplex (sinks: 1, sources: 1, priority: 202, available: yes)
                output:analog-stereo: Analog Stereo Output (sinks: 1, sources: 0, priority: 6000, available: yes)
                output:analog-stereo+input:analog-stereo: Analog Stereo Duplex (sinks: 1, sources: 1, priority: 6060, available: yes)
                off: Off (sinks: 0, sources: 0, priority: 0, available: yes)
        Active Profile: output:analog-stereo+input:analog-stereo
        Ports:
                analog-input-mic: Microphone (priority: 8700, latency offset: 0 usec)
                        Properties:
                                device.icon_name = "audio-input-microphone"
                        Part of profile(s): input:analog-mono, input:analog-stereo, output:analog-mono+input:analog-mono, output:analog-stereo+input:analog-stereo
                analog-input-linein: Line In (priority: 8100, latency offset: 0 usec)
                        Part of profile(s): input:analog-mono, input:analog-stereo, output:analog-mono+input:analog-mono, output:analog-stereo+input:analog-stereo
                analog-output: Analog Output (priority: 9900, latency offset: 0 usec)
                        Part of profile(s): output:analog-mono, output:analog-mono+input:analog-mono, output:analog-stereo, output:analog-stereo+input:analog-stereo

 Card #6
        Name: bluez_card.00_06_F7_B3_E9_ED
        Driver: module-bluez5-device.c
        Owner Module: 37
        Properties:
                device.description = "MM100"
                device.string = "00:06:F7:B3:E9:ED"
                device.api = "bluez"
                device.class = "sound"
                device.bus = "bluetooth"
                device.form_factor = "headset"
                bluez.path = "/org/bluez/hci0/dev_00_06_F7_B3_E9_ED"
                bluez.class = "0x240404"
                bluez.alias = "MM100"
                device.icon_name = "audio-headset-bluetooth"
                device.intended_roles = "phone"
        Profiles:
                headset_head_unit: Headset Head Unit (HSP/HFP) (sinks: 1, sources: 1, priority: 20, available: yes)
                a2dp_sink: High Fidelity Playback (A2DP Sink) (sinks: 1, sources: 0, priority: 10, available: yes)
                off: Off (sinks: 0, sources: 0, priority: 0, available: yes)
        Active Profile: headset_head_unit
        Ports:
                headset-output: Headset (priority: 0, latency offset: 0 usec)
                        Part of profile(s): headset_head_unit, a2dp_sink
                headset-input: Headset (priority: 0, latency offset: 0 usec)
                        Part of profile(s): headset_head_unit

We are interested in Card # 6.

2. Switch a2dp profile
	# pactl set-card-profile <card #id from item 1> a2dp_sink

example:
 root@imx6ul-var-dart:~# pactl set-card-profile 6 a2dp_sink
 root@imx6ul-var-dart:~#

3. play wav file from pulse subsystem to bluetooth headphones
	# paplay -p  --device=bluez_sink.XX_XX_XX_XX_XX_XX test.wav
Where:
XX_XX_XX_XX_XX_XX - bd_add from item 1
test.wav - is the path to audio file

example:
 root@imx6ul-var-dart:~# paplay -p --device=bluez_sink.00_06_F7_B3_E9_ED test.wav



--- FAQ ---
1. If sound not playing of headseat connecter (device in server mode)
It may not be configured ALSA, use this command:

# amixer set 'Output Mixer HiFi' on
