#!/usr/bin/env python

# curl -k -u lupapiste:$password https://upcsplunk.solita.fi:8089/servicesNS/nobody/search/search/jobs/export --data-urlencode search='search "POST /api/command" source="/var/log/nginx/access.log" | head 500000' -d output_mode=csv > dump.csv

import re, sys

def parseColumnNames(f):
    line = f.readline()
    return line.split(',')

inputFilename = sys.argv[1]
outputfilename = sys.argv[2]

f = open(inputFilename, "r")
out = open(outputfilename, "w")


columnNames = parseColumnNames(f)
print("Column names")
i = 0
for col in columnNames:
    print `i` + ": " + col
    i = i + 1

out.write("datetime\tid\trole\tip\tcommand\n")

ids = {}
idSeq = 100000

ips = {}
ipSeq = 100000

for line in f:
    fields = line.split(',')
    datetime = re.match("\"(.*) .*", fields[1]).group(1)

#    print "ts: " + datetime
    raw = fields[7]
    m = re.search(".*\/api\/command\/([^ ]*) .*", raw)
    if m:
        command = m.group(1)
#        print "command: " + command
        rawAll = re.findall("(\"[^\"]*\")", raw)
        url = rawAll[3]
#        print(url)
        roleMatch = re.match(".*\/app\/fi\/([^#\"]+).*", url)
        if roleMatch:
            role = roleMatch.group(1)
        else:
            role = ""

        idMatch = re.match(".*#!\/.*?\/([^\/]*).*", url)
        if idMatch:
            id = idMatch.group(1)
        else:
            id = ""

        if id != "":
            if not id in ids.keys():
                ids[id] = str(idSeq)
                idSeq = idSeq + 1
#                print("new id: " + `idSeq`)
        
            pubId = ids[id]
        else:
            pubId = ""

        ipStr = rawAll[0]
        ipMatch = re.match("\"(.*?\..*?\..*?\..*? ).*", ipStr)
        ip = ipMatch.group(1)

        if not ip in ips.keys():
            ips[ip] = str(ipSeq)
            ipSeq = ipSeq + 1
        pubIp = ips[ip][0:2] + "." + ips[ip][2:3] + "." + ips[ip][3:4] + "." + `int(ips[ip][4:6])`

    else:
        print("Skipped: " + line)
#    print(line)
    l = datetime + "\t" + pubId + "\t" + role + "\t" + pubIp + "\t" + command + "\n"
#    print(l)
    out.write(l)

print idSeq
