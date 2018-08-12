import logging
import os
import time
import getopt
import timeit
import datetime
import platform
import sys
import csv
import re
import traceback
import json
import requests
#################################################################################################
# require python3
#
#  jenkin-clone-folder  -- Auto clone the jenkin jobs from source_dir to dest_dir
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
# Aug-10-2018  Prangya Parmita Kar  Initial Version,
#
#
# python3 jenkin-clone-folder -s <source_dir> -d <dest_dir>([-t get or post]
# python3 jenkin-clone-folder -s <source_dir> -d <dest_dir> -t get - it will only get config files for each files and folder of source_dir
# python3 jenkin-clone-folder -s <source_dir> -d <dest_dir> -t post - it will only post /create jobs
#
#
# to run:
# python3 jenkin-clone-folder.py -s <Oil_and_Gas_Digital-Auto/job/TEMP/> -d <Oil_and_Gas_Digital-Auto/job/TEMP2/>
# require the destin folder <Oil_and_Gas_Digital-Auto/job/TEMP2/> to be available , not yet included to add but can add in automation if required.
# it only clones for jenkin url isjenkins.dsa.apps.ge.com , if need from other url need to modify the code.
#################################################################################################
logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())

jenkin_credential_file = "credentials/jenkin_credential.json"
jenkinUrl = 'isjenkins.dsa.apps.ge.com'
url = ""
DIR_NAME = "logs"

fileName = 'joblist.txt'
fileDirName = 'jobDir.txt'
fileNameDerived = 'joblistDerived.txt'
fileNameDerivedDest = 'joblistDerivedDest.txt'
fileNamePost = "joblistPost.txt"


def main(argv):
    logger.info("In main method .................")
    print(platform.python_version())
    task = None

    if len(sys.argv) < 4:
        usage()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, 'h:s:d:t:', ['source_dir=', 'dest_dir=', 'task=',])
    except getopt.GetoptError as  exc:
        print(exc.msg)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-s", "--source_dir"):
            source_dir = arg
        elif opt in ("-d", "--dest_dir"):
            dest_dir = arg
        elif opt in ("-t", "--task"):
            task = arg


    check_or_create_report_directory(DIR_NAME)
    create_log_file()
    start = timeit.default_timer()
    try:
        validate_platform_clear_screen()
        start_message = "Start Process of Auto Jobs Clone."
        logger.info(start_message)
        print("\n" + start_message + "\n")
        validate_inputs(source_dir, dest_dir)
        jenkin_values = read_jenkin_credentials(jenkin_credential_file)
        if (not task) or str(task).upper() == 'GET':
            open(fileName, 'w').close()
            open(fileDirName, 'w').close()
            source_dir='/job/'+source_dir
            getResponse(jenkin_values,source_dir)
            write_joblist(jenkin_values)
            getConfigXml(fileNameDerived)

        if (not task) or str(task).upper() == 'POST':
            print(task)
            time.sleep(30)  # wait 5 min to get all all jobs
            dest_dir='/job/'+dest_dir
            #Note - jenkin ip doesn't work with post. u need to provide url name
            writeDestUrl(fileNameDerived, fileNameDerivedDest, source_dir, dest_dir)
            createJenkinJob(jenkin_values, fileNameDerivedDest, fileNamePost, dest_dir)


        exit_status = 0
        exit_message = 'Success'

    except Exception as ex:
        if str(ex):
            print(str(ex) + "\n")
        logger.exception(ex)
        exit_status = 1
        exit_message = 'Failed'
        exc_type, exc_obj, exc_tb = sys.exc_info()
        traceback.print_tb(exc_tb)

    finally:
        stop = timeit.default_timer()
        total_time = stop - start

        print("\nSuccessfully Completed\n")

        logger.info(
            "Script execution status [" + exit_message + "], time taken [" + str(
                datetime.timedelta(seconds=total_time)) + "]")
        sys.exit(exit_status)


def getResponse(jenkin_values,source_dir):
    logger.info("Starting getResponse process")
    # Set the request parameters
    url = 'https://' + jenkin_values[0] + ':' + jenkin_values[1] + '@' + jenkinUrl + source_dir + 'api/json?pretty=true'
    print(url)
    print('+++++'+source_dir)
    # Do the HTTP get request
    try:
        response = requests.get(url, verify=True)  # Verify is check SSL certificate
        print(response.status_code)
        # Error handling
        # Check for HTTP codes other than 200
        if response.status_code != 200:
            print('Status:', response.status_code, 'Problem with the request. Exiting.')
            exit()
        else:
            json_data = requests.get(url).json()
            #print(json_data)
            with open(fileName, 'a') as f, open(fileDirName, 'a') as fd:
                for i in json_data["jobs"]:
                    #print("*****"+i["url"])
                    if i["_class"] == "hudson.model.FreeStyleProject":
                        print("*****" + i["url"])
                        json.dump(i["url"], f)
                        f.write('\n')
                    else:
                        source_dir='/'+str(i["url"]).split('/',3)[-1]
                        print(source_dir)
                        json.dump(i["url"], fd)
                        fd.write('\n')
                        getResponse(jenkin_values,source_dir)
            logger.info("URLs successfully written to file : "+fileName)
    except:
        print("Error in getResponse function")
        logger.error("Error in getResponse function")
        raise AttributeError("Error in getResponse function")

def find_config(abspath):
    logger.info("Starting find_config process")
    for root, dirs, files in os.walk(abspath, topdown=False):
        for name in files:
            if name == "config.xml":
                f = os.path.join(root, name)
                print(f)
    logger.info("End find_config process")

#update the file with USER and APITOKEN
def write_joblist(jenkin_values):
    logger.info("Preparing Derived job list")
    try:
        with open(fileDirName, "r") as fd:
            entireFile = fd.read()
            if "http://" in entireFile:
                newText = entireFile.replace("http://", "http://" + jenkin_values[0] + ":" + jenkin_values[1] + "@")
                write_file(fileNameDerived,newText,"w")
        with open(fileName, "r") as f:
            entireFile = f.read()
            # if "--suite" in entireFile:
            if "http://" in entireFile:
                newText = entireFile.replace("http://", "http://" + jenkin_values[0] + ":" + jenkin_values[1] + "@")
                # return {fileName: newText}
                write_file(fileNameDerived,newText,"a")
    except:
        print("Error in preparing derived job file")
        logger.error("Error in preparing derived job file")
        raise

    # read file joblistDerived.csv
def getConfigXml(fileNameDerived):
    logger.info("Get job config xml file")
    try:
        with open(fileNameDerived, "r") as f:
            for line in f:
                line=re.sub(r'^"|"$', '', line)
                line = re.sub(r'\n$', '', line)
                print("inside getConfigXml")
                print(line)
                jobName = line.split('/')[-2]
                print(jobName)
                str = 'curl -X GET '+line+'config.xml -o jenkinxml/'+jobName+'.xml'
                print(str)
                os.system(str)
        logger.info("Job config xml files generated successfully")
    except:
        print("Error in gettin config xml file")
        logger.error("Error in gettin config xml file")
        raise

def writeDestUrl(fileNameDerived, fileNameDerivedDest,source_dir, dest_dir):
    logger.info("Preparing writeDestUrl process")
    with open(fileNameDerived, "r") as f:
        entireFile = f.read()
        if source_dir in entireFile:
            newText = entireFile.replace(source_dir,dest_dir)
            # return {fileName: newText}
            write_file(fileNameDerivedDest, newText, "w")
    logger.info("End writeDestUrl process")

def createJenkinJob(jenkin_values, fileNameDerivedDest, fileNamePost,dest_dir):
    logger.info("Creating jenkin job to push")
    try:
        with open(fileNameDerivedDest, mode='r') as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            for line in lines:
                jobName = line.split('/')[-2]
                #preJobName = jobName.split('-')[-1]
                #postJobName = jobName.rsplit('-', 1)[0]
                jobPath = line.rsplit(dest_dir)[-1].rsplit('/',3)[0]
                jobPath = jobPath+'/'
                if jobPath.lower() == 'job/':
                    jobPath = ''
                print("THIS IS INSIDE writePostConfigXml")
                #below url is not working as IP address is dynamic and need to provide domain name
                #newLine = line.split('/')[0]+'//'+line.split('/')[2]+'/job/'+dest_dir + 'createItem?name=' + jobName + ' --data-binary @' + jobName + '.xml -H Content-Type:text/xml\"\n'
                newLine = 'https://' + jenkin_values[0] + ':' + jenkin_values[1] + '@' + jenkinUrl + dest_dir + jobPath + 'createItem?name=' + jobName + ' --data-binary @jenkinxml/' + jobName + '.xml -H Content-Type:text/xml\n'
                print(newLine)
                newLine='curl -s -X POST '+newLine
                print(newLine)
                os.system(newLine)
    except:
        print("Error in creating jenkin jobs file")
        logger.error("Error in creating jenkin jobs file")
        raise

def read_jenkin_credentials(jenkin_credential_file):
    print("read_jenkin_credentials started")
    logger.info("read_jenkin_credentials started")
    jenkin_val = []
    data = load_json(jenkin_credential_file)
    jenkin_val.append(data['userid'])
    jenkin_val.append(data['apitoken'])
    jenkin_val.append(data['emailid'])
    print("read_jenkin_credentials ended")
    logger.info("read_jenkin_credentials ended")
    return jenkin_val


def load_json(json_file):
  logger.info("Begin method load_json : "+json_file)
  # load the Json file into an object
  try:
    with open(json_file) as json_data:
      json_data = json.load(json_data,  strict=None)
      logger.info("End method load_json : "+json_file)
      return json_data

  except ValueError as ex:
    em = "Error while loading JSON file [" + json_file + "], Error [" + str(ex)
    raise ex



def write_file(filename, filedata_array,write_mode):
    logger.info("Begin method write_file : " + filename)
    logger.info("Write File " + filename + ", contains the data: \n" + str(filedata_array))
    with open(filename, write_mode) as file_obj:
        file_obj.writelines(filedata_array)
    logger.info("End method write_file : " + filename)


def validate_inputs(source_dir, dest_dir):
    logger.info("Begin method validate_inputs")
    if not source_dir:
        err_msg = "source_dir is a mandatory field. "
        logger.error(err_msg)
        raise AttributeError(err_msg)
    if not dest_dir:
        err_msg = "Destination directory is a mandatory field. "
        logger.error(err_msg)
        raise AttributeError(err_msg)
    logger.info("End method validate_inputs")



def validate_platform_clear_screen():
    platform_system = platform.system()
    if platform_system not in ['Linux', 'Darwin', 'Windows', 'CYGWIN_NT-6.2-WOW64']:
        logger.error(platform_system + ' is not supported.')
        raise ValueError(platform_system + ' is not supported.')
    else:
        # clearscreen
        if platform_system in ('Windows', 'CYGWIN_NT-6.2-WOW64'):
            os.system('cls')
        else:
            os.system('clear')


def create_log_file():
    cur_dir = os.path.dirname(os.path.realpath(__file__))
    filename = os.path.basename(__file__)
    script_file_path = os.path.splitext(__file__)[0]
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    log_file = filename + timestamp + '.log'
    log_file_path = os.path.join(cur_dir, DIR_NAME, log_file)
    # reset the default log file
    print(cur_dir)
    print(log_file_path)
    open(log_file_path, 'w').close()
    logger.setLevel(logging.DEBUG)

    if log_file is None:
        # use the console handler for logging
        handler = logging.StreamHandler()
    else:
        # use the file handler for logging
        handler = logging.FileHandler(log_file_path)

    # create formatter
    fmt = '%(asctime)s %(filename)-15s %(levelname)-6s: %(message)s'
    fmt_date = '%Y-%m-%dT%H:%M:%S%Z'
    formatter = logging.Formatter(fmt, fmt_date)
    handler.setFormatter(formatter)
    # add the handler to the logger
    logger.addHandler(handler)

def check_or_create_report_directory(dir_name):
  report_directory = os.path.join('.', dir_name)
  if not os.path.exists(report_directory):
    logging.info("Directory ["+str(report_directory)+"] does not exist. Creating it.")
    os.makedirs(report_directory)
  else:
    logging.info("Directory ["+str(report_directory)+"] exists.")
  return report_directory

def usage():
    print("\n")
    usage_message_main1 = ("Usage: " + __file__ + "[--help] -s <source_dir> -d <dest_dir>([-t get or post] optional argument - default -> both get and post)")
    print(usage_message_main1)
    print("\n")


if __name__ == "__main__":
    main(sys.argv[1:])
