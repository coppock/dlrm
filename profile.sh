set -x

. venv/bin/activate

# Assume a single GPU with four GPCs each with 6GB of memory (e.g., A30).
for i in `seq 0 2`
do
	sudo nvidia-smi mig -dci
	sudo nvidia-smi mig -dgi

	gpcs=$((1<<(2-i)))
	mem=$((gpcs*6))
	slice=${gpcs}g.${mem}gb
	slices=$slice
	nslices=$((1<<i))
	for j in `seq $((nslices-1))`
	do
		slices=$slices,$slice
	done
	sudo nvidia-smi mig -cgi $slices -C

	devices=`nvidia-smi -L | sed -n 's/.*\(MIG-[^)]*\).*/\1/p' | xargs`
	for dev in $devices
	do
		CUDA_VISIBLE_DEVICES=$dev ncu \
		    --export=reports/$slice/`echo $dev | cut -d- -f2`.%i \
		    python dlrm_s_pytorch.py \
		        --arch-sparse-feature-size=16 \
		        --arch-mlp-bot=13-512-256-64-16 \
		        --arch-mlp-top=512-256-1 \
		        --data-generation=dataset \
		        --data-set=kaggle \
		        --raw-data-file=./input/train.txt \
		        --processed-data-file=./input/kaggleAdDisplayChallenge_processed.npz \
		        --mini-batch-size=1 \
		        --num-batches=1 \
		        --use-gpu \
		        --inference-only &
	done
	wait
done
