baseFolder=`pwd`
echo $baseFolder
folders=`ls`
for f in $folders; do
  echo "currently in `pwd` going for $f in $baseFolder"
  cd $baseFolder/$f
  # cd $f
  npm i
done
echo 'built all'
