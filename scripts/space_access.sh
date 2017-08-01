#!/bin/bash

echo -n "Enter Org Name [ENTER]: "
read org

echo -n "Enter Space Name [ENTER]: "
read space

usersList='212627439,212615283,212615064,212632137,212629706,212614745,212606648,212627189,212627333,212593409,212605258,212628072,212599650,212613931,212629565'

for i in $(echo $usersList | sed "s/,/ /g")
do
    echo "$i"
    cf set-space-role $i@mail.ad.ge.com  $org $space SpaceDeveloper

    cf set-space-role $i@mail.ad.ge.com $org $space SpaceManager
done