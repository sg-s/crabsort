from datetime import date
import os
today = date.today()


# delete old version file
os.remove('+crabsort/version.m')

out_file = open('+crabsort/version.m','a+')

out_file.write('function v = version()')
out_file.write('\n')

temp = ("v = 'v" + today.strftime('%y.%m.%d') + "';")
temp = temp.replace('.0','.')
out_file.write(temp)
out_file.write('\n')


out_file.write('disp(v)')

out_file.close()