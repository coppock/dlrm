set -x

for config in reports/*
do
	for dev in config/*
	do
		temp=`mktemp`
		ncu --import=dev --csv >$temp
		temps="${temps+temps }$temp"
	done
	cat $temps | python3 process.py
	rm $temps
done
