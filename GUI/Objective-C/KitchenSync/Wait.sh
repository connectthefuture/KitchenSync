#!/bin/sh

set -e

#  Test.sh
#  Test
#
#  Created by tom on 24/07/2015.
#  Copyright (c) 2015 tom. All rights reserved.

#cp "/Users/tom/Pictures/_MG_5312.jpg" "/Users/tom/Documents/Temp/_MG_5312.jpg"
#echo "Do something... lets see what happens"
#echo "Oh no! Something went wrong" 1>&2
{
    sleep 0.5
    echo "First message"
    sleep 2
    echo "Second message"
    sleep 3
    echo "Last message"
} &

{
    sleep 1
    echo "First error message" 1>&2
    sleep 3.5
    echo "Second error message" 1>&2
    sleep 2.1
    echo "Last error message" 1>&2
} &

wait

trap "trap - SIGTERM && kill 0" SIGINT SIGTERM EXIT