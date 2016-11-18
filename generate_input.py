import random

INSTANCE_PER_FILE = 10

random.seed(12980634913)

index = 0
def generate_orders(x, y):
    global index
    index += 1
    with open('andre_%d_%d.txt' %(x, y), 'w') as f:
        for i in xrange(INSTANCE_PER_FILE):
            num_instance = i + index * INSTANCE_PER_FILE
            f.write("Instance %d\n" % num_instance)
            f.write("%d %d \n" % (x, y))
            for p in xrange(x):
                for q in xrange(y):
                    if random.random() < 0.25:
                        ordered = 1
                    else:
                        ordered = 0
                    f.write(" %d" % ordered)
                f.write("\n")
            f.write("\n")


for x in xrange(9, 20, 2):
    for y in [8, 9, 10]:
        generate_orders(x, y)
