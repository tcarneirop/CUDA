#!/bin/bash
#rm -f saida*.txt

for contador in {1..32}
  do 
(time (time ./CompleteEnumerationStream < 11.txt) 2>>sai11.txt)

sleep 1;

done
