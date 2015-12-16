#!/bin/bash

#TESTEN VAN DE DISPALY OP RASPBERRY PI

echo "Normal Operation"
echo -ne "\x0C\x01" > /dev/spidev0.0 #Normal Operation (Start)

echo "Display Test"
echo -ne "\x0F\x01" > /dev/spidev0.0 #Display Test

echo "Sleep"
sleep 3

echo "Normal Operation"
echo -ne "\x0F\x00" > /dev/spidev0.0 #Display Test

echo "Enable SCAN for all Digits"
echo -ne "\x0B\x07" > /dev/spidev0.0 #DIGITS 1-8 AANZETTEN VOOR SCAN
echo "Decode font voor alle Digits"
echo -ne "\x09\xFF" > /dev/spidev0.0 #DECODE FONTS VOOR ALLE DIGITS

echo "Helderheid half"
echo -ne "\x0A\x08" > /dev/spidev0.0 #Intensity (Mid)

echo "Clearing Segments"
for i in {1..8}
do
	echo "   Clearing $i"
	echo -ne "\x0$i\x0F" > /dev/spidev0.0 #Normal Operation (Start)
done

echo "Sleep"
sleep 3

while :
do
	echo "Counting Segments"
	for i in {1..8}
	do
		echo "   Setting $i ON $((9-i))"
		echo -ne "\x0$((9-i))\x0$i" > /dev/spidev0.0 #Normal Operation (Start)
		sleep 1
	done
	echo "Clearing Segments"
	for i in {1..8}
	do
		echo "   Clearing $i"
		echo -ne "\x0$i\x0F" > /dev/spidev0.0 #Normal Operation (Start)
	done
	sleep 1
done
