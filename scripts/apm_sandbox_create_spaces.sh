#!/bin/bash

echo -n "Enter Org Name [ENTER]: "
read org

echo -n "Enter Env Name [ENTER]: "
read env

cf create-space apm-$env -o $org

cf create-space apm-$env-analysis -o $org

