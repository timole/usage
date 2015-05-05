#!/usr/bin/env python

# curl -k -u lupapiste:$password https://upcsplunk.solita.fi:8089/servicesNS/nobody/search/search/jobs/export --data-urlencode search="search source=\"/home/lupapiste/logs/events.log\" earliest=-3months | regex _raw=\"\\\"type\\\":\\\"command\\\""" -d output_mode=csv > lupapiste-usage-dump-3months.csv
# curl -k -u lupapiste:$password https://upcsplunk.solita.fi:8089/servicesNS/nobody/search/search/jobs/export --data-urlencode search='search source="/home/lupapiste/logs/events.log" | regex _raw=\"type\":\"command\"' -d output_mode=csv
# ../scripts/convert-events.py lupapiste-usage-dump-all-20150428.csv lupapiste-cron-dump-all-20150428.csv lupapiste-usage-events-all-20150428.tsv lupapiste-usage-events-all-ids-20150428.tsv
import re, sys, json

a = None

def parseColumnNames(f):
    line = f.readline()
    return line.split(',')

inputFilename = sys.argv[1]
inputFilenameCron = sys.argv[2]
outputfilename = sys.argv[3]
outputfilenameIds = sys.argv[4]

f = open(inputFilename, "r")
fcron = open(inputFilenameCron, "r")
out = open(outputfilename, "w")
outIds = open(outputfilenameIds, "w")

columnNames = parseColumnNames(f)
print("Column names")


i = 0
for col in columnNames:
    print `i` + ": " + col
    i = i + 1

out.write("datetime\tuserId\trole\tmunicipalityId\tapplicationId\taction\ttarget\n")

ids = {}
idSeq = 100000

userIds = {}
userIdSeq = 100000

parsed = 0
errors = 0
for line in f:
    fields = line.split(',')
    datetime = re.match("\"(.*) .*", fields[1]).group(1)

#    print "ts: " + datetime
    rawMatch = re.match(".*? - (.*)\"", line)
    js = rawMatch.group(1).replace("\"\"", "\"")
    
    try:
        data = json.loads(js)
    except ValueError:
        errors = errors + 1
        sys.stdout.write('E')
        #print("Error parsing json")
        continue

    if data["type"] == "command":
#        print(data)
        action = data["action"]
        if action == "login" or action == "register-user" or action == "update-user" or action == "update-user-organization" or action == "reset-password" or action == "users-for-datatables" or action == "impersonate-authority" or action == "frontend-error":
            continue
#        if not id in data["data"].keys():
#            continue
        id = ""
        role = ""
        userId = ""
        try:

            if action == "create-application":
                id = ""
                role = data["user"]["role"]
                userId = data["user"]["id"]
            else:
                if action == "neighbor-response":
#                    print(data)
                    id = data["data"]["applicationId"]
                    role = "neighbor"
                    userId = data["data"]["neighborId"]
                else:
                    userId = data["user"]["id"]
                    role = data["user"]["role"]
                    id = data["data"]["id"]
        except:
            sys.stdout.write('i')
            #print("No id for " + data["action"])

        target = ""
        if action == "update-doc":
            target = data["data"]["updates"][0][0]
        if action == "upload-attachment":
            if "attachmentType" in data["data"].keys():
                target = data["data"]["attachmentType"]["type-id"]
        if action == "mark-seen":
            target = data["data"]["type"]
        if action == "approve-doc":
            target = data["data"]["path"]
        if action == "add-comment":
            target = data["data"]["target"]["type"]
        if action == "create-doc":
            target = data["data"]["schemaName"]
        if action == "invite-with-role":
            target = data["data"]["role"]

        if id != "":
            if not id in ids.keys():
                ids[id] = str(idSeq)
                idSeq = idSeq + 1
        
            pubId = ids[id]
        else:
            pubId = ""

        municipalityId = ""
        if id != "":
            municipalityId = id.split('-')[1]

        if not userId in userIds.keys():
            userIds[userId] = str(userIdSeq)
            userIdSeq = userIdSeq + 1
        pubUserId = userIds[userId]

        l = datetime + "\t" + pubUserId + "\t" + role + "\t" + municipalityId + "\t" + pubId + "\t" + action + "\t" + target + "\n"
#        print(l)
        out.write(l)

    parsed = parsed + 1

    if parsed % 1000 == 0:
        sys.stdout.write('.')
        sys.stdout.flush()


columnNames = parseColumnNames(fcron)
for line in fcron:
    fields = line.split(',')

    datetime = re.match("\"(.*) .*", fields[1]).group(1)

#    print "ts: " + datetime
    raw = fields[7]

    rawMatch = re.match(".*?\[(LP.*?)\].*", raw)
    id = rawMatch.group(1)

    jsMatch = re.match(".*? - (.*)\"", line)
    js = jsMatch.group(1).replace("\"\"", "\"")
        
    try:
        data = json.loads(js)
    except ValueError:
        errors = errors + 1
        sys.stdout.write('E')
        #print("Error parsing json")
        continue

    if data["event"] == "Found new verdict":
        if id != "":
            if not id in ids.keys():
                ids[id] = str(idSeq)
                idSeq = idSeq + 1
        
            pubId = ids[id]
        else:
            pubId = ""

        l = datetime + "\t" + "1" + "\t" + "system" + "\t" + pubId + "\t" + "batch-give-verdict" + "\t" + "" + "\n"
#        print(l)
        out.write(l)

    else:
        sys.stdout.write('N')

    parsed = parsed + 1

    if parsed % 1000 == 0:
        sys.stdout.write('.')
        sys.stdout.flush()

outIds.write("applicationId\toriginalApplicationId\n")
for idKey in ids.keys():
    id = ids[idKey]
    if id is None or idKey is None:
        print "Error: None:"
        print("id")
        print(id)
        print("idKey")
        print(idKey)
    else:
        outIds.write(id + "\t" + idKey + "\n")

outIds.close()
out.close()

print

print "Errors: " + str(errors)
