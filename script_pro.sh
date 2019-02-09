yourfilenames=`ls ./solidity_examples/*.sol`
for eachfile in $yourfilenames
do
   echo $eachfile
   python3 myth -w $eachfile
done
