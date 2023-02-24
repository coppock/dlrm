import csv
import sys

tputs = {}
for record in csv.DictReader(sys.stdin):
    if (record['Section Name'] == 'GPU Speed Of Light Throughput' and
            record['Metric Name'] == 'Compute (SM) [%]'):
        if record['Kernel Name'] in tputs:
            tputs[record['Kernel Name']] = (
                tputs[record['Kernel Name']][0] + 1,
                tputs[record['Kernel Name']][1] + float(record['Metric Value']),
            )
        else:
            tputs[record['Kernel Name']] = (1, float(record['Metric Value']))

for tput in tputs:
    print(tput, tputs[tput][0], tputs[tput][1] / tputs[tput][0], sep='\t')
