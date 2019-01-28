yourfilenames=`ls ./solidity_examples/*.sol`
for eachfile in $yourfilenames
do
   echo $eachfile
   myth -x $eachfile
done
