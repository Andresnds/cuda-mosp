import glob
import sys

filenames = sorted(sys.argv[1:])
# print filenames
for filename in filenames:
    with open(filename) as f:
        all_lines = f.readlines()
        lines = all_lines[-5:]
        print filename
        if lines and lines[0].startswith('Solved'):
            for line in lines:
                print line,
            print ''
        else:
            print 'Solved: -1 instances'
            print 'totalTime: -1 seconds'
            print 'minTime: -1 seconds'
            print 'maxTime: -1 seconds'
            print 'Average: -1 seconds'
            print ''