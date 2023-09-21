import sys
import gzip
import os

delimiter = b'::MUX::'
mode = 'wb'
ext = b'.fastq.gz'
sep = b'/'
rec = b'@'

# load mapping information
fpmap = {}
for l in open(sys.argv[1], 'rb'):
    idx, r1, r2, outbase = l.strip().split(b'\t')
    fpmap[rec + idx] = (r1, r2, outbase)  # append rec in mapping rather than per seq filter

# gather other parameters
fp = open(sys.argv[2], 'rb')
out_d = sys.argv[3].encode('ascii')

# this is our encoded file, and the one we care about
idx = rec + sys.argv[4].encode('ascii')
fname_r1, fname_r2, outbase = fpmap[idx]

# setup output locations
outdir = out_d + sep + outbase
fullname_r1 = outdir + sep + fname_r1 + ext
fullname_r2 = outdir + sep + fname_r2 + ext

os.makedirs(outdir, exist_ok=True )
current_fp_r1 = gzip.open(fullname_r1, mode)
current_fp_r2 = gzip.open(fullname_r2, mode)
current_fp = (current_fp_r1, current_fp_r2)

# we assume R1 comes first...
orientation_offset = 0

# setup a parser
id_ = iter(fp)
seq = iter(fp)
dumb = iter(fp)
qual = iter(fp)

for i, s, d, q in zip(id_, seq, dumb, qual):
    fname_encoded, id_ = i.split(delimiter, 1)

    if fname_encoded == idx:
        id_ = rec + id_

        current_fp[orientation_offset].write(id_)
        current_fp[orientation_offset].write(s)
        current_fp[orientation_offset].write(d)
        current_fp[orientation_offset].write(q)
        orientation_offset = 1 - orientation_offset  # switch between 0 / 1
