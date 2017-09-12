#################################################
#
# Purpose: This script will extract dynamically the db credentials for source and destinations databases.
#
#
# -----------    ----------------  -------------------------------------
# Date           Author            Comment
# -----------    ----------------  -------------------------------------
# Sep,11.2018    Prangya P Kar      Intial Version
#
##################################################
from itertools import islice # to exclude the first n last line used islice
def source_db():

#print ("opening n closing of file Source")

    source_file=open("source.txt","r")
    d={}

    for line in islice(source_file,4,14):
        x=line.split(":",1)
        a=x[0]
        a=a.strip()
        b=x[1]
        b=x[1].replace(',', '')
        #c=len(b)-2 #The -1 get len of b -'\n'
        #b=b[0:c]
        b=b.strip()
        d[a]=b

#    print ("\nSOURCE FILE INFO ....")
#    print(d)

    #print ("\nSOURCE FILE INFO ....")

#    print ("\nGENERATING SOURCE FILE INFO ... in db_credentials.txt")

    with open('db_commands.txt', 'w') as f:

        SRC_DB_HOST=(d['"host"'])
        print >> f, "export SRC_DB_HOST="+SRC_DB_HOST

        SRC_DB_PORT=(d['"port"'])
        print >>f, "export SRC_DB_PORT="+SRC_DB_PORT

        SRC_DB_NAME=(d['"database"'])
        print >>f, "export SRC_DB_NAME="+SRC_DB_NAME

        SRC_USER_NAME=(d['"username"'])
        print >>f, "export SRC_USER_NAME="+SRC_USER_NAME

        SRC_USER_PASSWORD=(d['"password"'])
        print >>f, "export SRC_USER_PASSWORD="+SRC_USER_PASSWORD

    source_file.close()

##################

def dest_db():
#print ("\nopening n closing of file Destination")
#from itertools import islice

    destination_file = open("destination.txt", "r")
    d = {}
    for line in islice(destination_file, 4, 13):
        x = line.split(":", 1)
        a = x[0]
        a = a.strip()
        b = x[1]
        b=x[1].replace(',', '')
        #c = len(b) - 2  # The -1 get len of b -'\n'
        #b = b[0:c]
        b = b.strip()
        d[a] = b


#    print ("\nDESTINATION FILE INFO....")
#    print(d)

    #print ("\nDESTINATION FILE INFO....")
#    print ("\nGENERATING DESTINATION FILE INFO .. in db_credentials.txt")

    with open('db_commands.txt', 'a') as f:

        DEST_DB_HOST=(d['"hostname"'])
        print >>f, "export DEST_DB_HOST="+DEST_DB_HOST

        DEST_DB_NAME = (d['"database"'])
        print >>f, "export DEST_DB_NAME=" + DEST_DB_NAME

        DEST_DB_PORT = (d['"port"'])
        print >>f,"export DEST_DB_PORT=" + DEST_DB_PORT

        DEST_USER_NAME = (d['"username"'])
        print >>f,"export DEST_USER_NAME=" + DEST_USER_NAME

        DEST_USER_PASSWORD = (d['"password"'])
        print >>f, "export DEST_USER_PASSWORD=" + DEST_USER_PASSWORD

    destination_file.close()


def main():
    source_db()
    dest_db()

if __name__ == "__main__":
        main()
