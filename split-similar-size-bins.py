import sys
import glob
import os

output_base_count = sys.argv[1].count('*')

if output_base_count > 0:
    assert sys.argv[1].strip('/').endswith('*/*')

#Import files and max_size
files = iter(sorted([f for f in glob.glob(sys.argv[1] + '/*.fastq.gz')]))
max_size = (int(sys.argv[2]) * (2**30) / 2) # into GB, and half as we sum R1

r1 = iter(files)
r2 = iter(files)

split_offset = 0
current_size = max_size * 10  # push us definitely over max size to start
fp = None

for a, b in zip(r1, r2):
    assert 'R1' in a
    assert 'R2' in b
    try:
        assert a[:a.find('.R1')] == b[:b.find('.R2')]
    except AssertionError:
        assert a[:a.find('_R1')] == b[:b.find('_R2')]

    r1_size = os.stat(a).st_size

    if output_base_count > 0:
        # WARNING: we assume x/y/foo.r1.fastq.gz
        # and that we are to preserve the relative path x/y/foo.r1.fastq.gz
        # when demultiplexing
        output_base = '/'.join(os.path.dirname(a).split('/')[-output_base_count:])
    else:
        output_base = './'
    
    if current_size + r1_size > max_size:
        if fp is not None:
            fp.close()
        split_offset += 1
        current_size = r1_size
        fp = open(sys.argv[3] + '-%d' % split_offset, 'w')
    else:
        current_size += r1_size

    fp.write("%s\t%s\t%s\n" % (a, b, output_base))
fp.close()
print(split_offset)
