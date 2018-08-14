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
# required python3
#  jenkinAutoPromotion  -- Trigger jenkin CD jobs based upon the the artifacts generated to specified ENV(UAT01,PERF02) and .
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
# Aug-03-2018  Prangya Parmita Kar  Initial Version,
#
#
# python3 jenkinAutoTriggerPromotion-p1.py -f1 verifiedInBuild.csv --environment UAT01
#
#
#################################################################################################
logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())

jenkin_credential_file = "credentials/jenkin_credential.json"
jenkin_env_mapping_file = "config/jenkin_env_mapping.json"
verifiedInBuild_c = 'verifiedInBuild.csv'

sanitizeSortedResultUatFile = 'sanitizeSortedResultUat.csv'
jenkinJobUrlFile = 'output/jenkinJobUrlFile.csv'
jenkinJobStatus = 'output/jenkinJobStatus.csv'
DIR_NAME = "logs"


def main(argv):
    logger.info("In main method .................")
    print(platform.python_version())

    verifiedInBuild = verifiedInBuild_c


    if len(sys.argv) < 4:
        usage()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, "h:f1:e", ["verifiedInBuild=", "environment="])
    except getopt.GetoptError as  exc:
        print(exc.msg)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-f1", "--verifiedInBuild"):
            verifiedInBuild = arg
        elif opt in ("-e", "--environment"):
            environment = arg

    create_log_file()
    start = timeit.default_timer()
    try:
        #validate_platform_clear_screen()
        start_message = "Start Process of Auto Promotion Jobs Push."
        logger.info(start_message)
        print("\n" + start_message + "\n")

        validate_inputs(verifiedInBuild, environment)
        if os.path.isfile(jenkin_env_mapping_file) is False:
            err_msg = "File [" + jenkin_env_mapping_file + "] is not present."
            raise AttributeError(err_msg)

        logger.info('Read Data from Jenking env file')
        jenkin_env_mapping_file_map = load_json(jenkin_env_mapping_file)
        print(jenkin_env_mapping_file_map)
        if environment in jenkin_env_mapping_file_map:
            env_name = jenkin_env_mapping_file_map[environment]
            envJobsUrlList = env_name["urlLists"]
        else:
            error_message = "There is no entry for " + environment + " in the file " + jenkin_env_mapping_file_map
            raise AttributeError(error_message)

        split_uat_data_on_field(verifiedInBuild, envJobsUrlList, sanitizeSortedResultUatFile)
        jenkin_values = read_jenkin_credentials(jenkin_credential_file)
        open(jenkinJobUrlFile, 'w').close()  # flush existing data
        assemble_uat_data(sanitizeSortedResultUatFile, jenkin_values)
        trigger_jenkin_jobs(jenkinJobUrlFile,sanitizeSortedResultUatFile,jenkin_values,environment,jenkin_env_mapping_file_map)
        with open(jenkinJobStatus, 'w') as file_obj:
            file_obj.writelines("Date: ".ljust(13) + "Artifact Name:".ljust(53) + "Job Status:" + '\n')
        logger.info("Wait 5 min...let the Jenkin jobs finish.")
        time.sleep(300)  # wait 5 min finish all jobs and get the job status
        jenkin_job_status(sanitizeSortedResultUatFile, jenkin_values, jenkinJobStatus)



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

        print("\nSuccessfully Pushed all jobs\n")

        logger.info(
            "Script execution status [" + exit_message + "], time taken [" + str(
                datetime.timedelta(seconds=total_time)) + "]")
        sys.exit(exit_status)


def assemble_uat_data(sanitizeSortedResultUatFile, jenkin_values):
    logger.info("Begin method assemble_uat_data - to create app url file")
    print("assemble_uat_data started")
    logger.info("Files Used: " + sanitizeSortedResultUatFile)
    file_path1 = os.path.join('.', sanitizeSortedResultUatFile)
    with open(file_path1, mode='r') as f1:
        lines = (line.rstrip() for line in f1)  # All lines including the blank ones
        lines = (line for line in lines if line)  # Non-blank lines
        for line in lines:
            jobName = line.split('|')[0]  # first part is job name
            print(jobName)
            if (jobName[0:4].lower() != 'ong-') and (jobName[0:10].lower() != 'ogd-config'):
                jobVersion = line.split('|')[1]
                print(jobVersion)
                artifactNo = line.split('|')[2]
                print(artifactNo)
                urlName = line.split('|')[3]
                #write only app url file. Rest will be pushed on-fly
                write_jenkin_jobUrl(jobName, jobVersion, artifactNo, urlName, jenkin_values)

    print("assemble_uat_data ended")
    logger.info("Successfully created URL file for all apps : "+jenkinJobUrlFile)


def write_jenkin_jobUrl(jobName, jobVersion, artifactNo, urlName, jenkin_values):
    # file_path1 = os.path.join('.', DIR_NAME, verifiedInBuild)
    # file_path2 = os.path.join('.', DIR_NAME, envJobsUrlList)
    line = urlName.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
    print(line)
    line = line + 'build --data-urlencode json=\'{\"parameter\":[{\"name\":\"BuildNum\", \"value\":\"' + artifactNo + '\"},{\"name\":\"SymVer\", \"value\":\"' + jobVersion + '\"}]}\' -H \"' + \
           jenkin_values[3] + '\"'
    print(line)
    line = 'curl -X POST ' + line
    print(line)
    with open(jenkinJobUrlFile, 'a') as file_obj:
        file_obj.writelines(line + '\n')


def trigger_jenkin_jobs(jenkinJobUrlFile,sanitizeSortedResultUatFile,jenkin_values,environment,jenkin_env_mapping_file_map):
    #Push all apps first
    logger.info("Begin method push_jenkin_jobs")
    logger.info("Push All apps first")
    if environment in jenkin_env_mapping_file_map:
        env_name = jenkin_env_mapping_file_map[environment]
        envTenantidsLists = env_name["tenantidsList"]
        envTenantidsList = str(envTenantidsLists).split(',')
    if os.stat(jenkinJobUrlFile).st_size > 0:
        counter = 0
        with open(jenkinJobUrlFile, 'r') as urlFile:
            lines = (line.rstrip() for line in urlFile)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            for line in lines:
                counter = counter + 1
                print(counter)
                # Now push the job into jenking
                try:
                    os.system(line)
                    if counter % 5 == 0:
                        time.sleep(60)
                except:
                    print("Error in Jenkin App job push...")
            logger.info("Successfully pushed all App jobs")
    #Push widget and config on-fly
    logger.info("Push All Widget and Cups jobs")
    with open(sanitizeSortedResultUatFile, 'r') as f1:
        lines = (line.rstrip() for line in f1)  # All lines including the blank ones
        lines = (line for line in lines if line)  # Non-blank lines
        for line in lines:
            lineList = line.split('|')
            jobName = lineList[0]  # first part is job name
            symver = lineList[1] # version number
            artifactNo = lineList[2] # build number or artifact  number
            urlName = lineList[3] # url
            print(jobName)
            if jobName[0:4].lower() == 'ong-':
                tenantids = '\,'.join(lineList[4:len(lineList)])
                print(tenantids)
                line = urlName.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
                line = line + 'build --data-urlencode json=\'{\"parameter\":[{\"name\":\"TENANTIDS\", \"value\":\"' + tenantids + '\"},{\"name\":\"ACTION\", \"value\":\"update\"},{\"name\":\"USERNAME\", \"value\":\"' + jenkin_values[4] + '\"},{\"name\":\"PASSWORD\", \"value\":\"'+jenkin_values[5]+'\"},{\"name\":\"Artifact_Number\", \"value\":\"'+artifactNo+'\"}]}\' -H \"' + \
                            jenkin_values[3] + '\"'
                line = 'curl -X POST ' + line
                print(line)
                #print("******widget")
                # Now push the job into jenking
                try:
                    os.system(line)
                except:
                    print("Error in Jenkin Widget job push...")
            elif jobName[0:10].lower() == 'ogd-config':
                jobNameSplit = jobName.split('-')
                if jobNameSplit[2].lower() == 'cups':
                    line = urlName.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
                    line = line + 'build --data-urlencode json=\'{\"parameter\":[{\"name\":\"Artifact_Number\", \"value\":\"' + artifactNo + '\"},{\"name\":\"ENV\", \"value\":\"' + str(environment).lower() + '\"},{\"name\":\"VERSION\", \"value\":\"' + symver + '\"},{\"name\":\"FrameworkArtifactNumber\", \"value\":\"'+jenkin_values[9]+'\"}]}\' -H \"' + \
                            jenkin_values[3] + '\"'
                    line = 'curl -X POST ' + line
                    print(line)
                    #print("********cups")
                    # Now push the job into jenking
                    try:
                        os.system(line)
                    except:
                        print("Error in Jenkin Cups job push...")
                elif jobNameSplit[-1][0:7].lower() == 'upgrade':

                    jobSection = jobNameSplit[len(jobNameSplit) - 1].split('_')  # split the last section of jobname to get tenant section and product
                    product = jobSection[1]  # get the product name like intellistrem or pcm etc..
                    if product == 'intellistream':
                        product = 'IntelliStream'
                    elif product == 'pcm':
                        product = 'PCM'
                    else:
                        print("product is different than IntelliStream or PCM")
                        # print(tenantSection+ '****' + product)
                    for tenantid in envTenantidsList:
                        line = urlName.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
                        line = line + 'build --data-urlencode json=\'{\"parameter\":[{\"name\":\"ArtifactNum\", \"value\":\"' + artifactNo + '\"},{\"name\":\"ApmEnvType\", \"value\":\"' + apmEnvType + '\"},{\"name\":\"TenantID\", \"value\":\"' + tenantid + '\"},{\"name\":\"func_user_name\", \"value\":\"' + jenkin_values[4] + '\"},{\"name\":\"func_user_password\", \"value\":\"' + jenkin_values[5] + '\"},{\"name\":\"space\", \"value\":\"' + str(environment).lower() + '\"},{\"name\":\"Enterprise\", \"value\":\"all\"},{\"name\":\"FolderVersion\", \"value\":\"version1.0\"},{\"name\":\"RulesFileName\", \"value\":\"upgrade.json\"},{\"name\":\"ApplicationName\", \"value\":\"' + product + '\"},{\"name\":\"FrameworkArtifactNumber\", \"value\":\"' + jenkin_values[9] + '\"}]}\' -H \"' + jenkin_values[3] + '\"'
                        line = 'curl -X POST ' + line
                        #print("********upgrade")
                        print(line)
                    # Now push the job into jenking
                    try:
                        os.system(line)
                    except:
                        print("Error in Jenkin OGD config upgrade job push...")
                else:
                    jobSection = jobNameSplit[len(jobNameSplit)-1].split('_') #split the last section of jobname to get tenant section and product
                    tenantSection = jobSection[0] # get the tenant section like widget or classification or uom etc..
                    product = jobSection[1]  # get the product name like intellistrem or pcm etc..
                    if product == 'intellistream':
                        product = 'IntelliStream'
                    elif product == 'pcm':
                        product = 'PCM'
                    else:
                        print("product is different than IntelliStream or PCM")
                    #print(tenantSection+ '****' + product)

                    artifactNum1= symver+'.'+artifactNo #artifact num created as per tenant config
                   # print (ArtifactNum1)

                    targetOrg = 'OGD_Development_USWest_01' # may need to change for demo
                    # need to generate the tenant id string as per env
                    if environment == 'UAT01' and product == 'IntelliStream':
                        tenantids1 = str(environment).lower() + '_intellistream_base_tenants'
                    elif environment == 'UAT01' and product == 'PCM':
                        tenantids1 = str(environment).lower() + '_pcm_base_tenants'
                    elif environment == 'PERF02':
                        tenantids1 = str(environment).lower() + '_base_tenants'
                    else:
                        print ("environment is not UAT01 or PERF02")

                  #  print (tenantids1)
                    apmEnvType = 'preprod'

                    line = urlName.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
                    line = line + 'build --data-urlencode json=\'{\"parameter\":[{\"name\":\"ArtifactNum\", \"value\":\"' + artifactNum1 + '\"},{\"name\":\"Section\", \"value\":\"' + tenantSection + '\"},{\"name\":\"TargetOrg\", \"value\":\"' + targetOrg + '\"},{\"name\":\"SPACE\", \"value\":\"' + str(environment).lower() + '\"},{\"name\":\"DedicatedSpace\", \"value\":\"' + str(environment).lower() + '\"},{\"name\":\"TenantID\", \"value\":\"' + tenantids1 + '\"},{\"name\":\"ApplicationName\", \"value\":\"' + product + '\"},{\"name\":\"ApmEnvType\", \"value\":\"' + apmEnvType + '\"},{\"name\":\"func_user_name\", \"value\":\"' +jenkin_values[4] + '\"},{\"name\":\"func_user_password\", \"value\":\"' + jenkin_values[5] + '\"},{\"name\":\"devops_user_name\", \"value\":\"' + jenkin_values[6] + '\"},{\"name\":\"devops_user_password\", \"value\":\"' + jenkin_values[7] + '\"},{\"name\":\"UAASecret\", \"value\":\"' + jenkin_values[8] + '\"},{\"name\":\"FrameworkArtifactNumber\", \"value\":\"' + jenkin_values[9] + '\"}]}\' -H \"' + jenkin_values[3] + '\"'
                    line = 'curl -X POST ' + line
                    print(line)
                    #print("******tenant-config")
                    # Now push the job into jenking
                    try:
                        os.system(line)
                    except:
                        print("Error in Jenkin Tenant config job push...")
        logger.info("Successfully Pushed all widget and cups jobs")

def jenkin_job_status(sanitizeSortedResultUatFile, jenkin_values, jenkinJobStatus):
    logger.info("Get the status of all jobs we pushed")
    with open(sanitizeSortedResultUatFile, 'r') as data_file:
        lines = (line.rstrip() for line in data_file)  # All new-line char including the blank ones
        lines = (line for line in lines if line)  # Non-blank lines
        for line in lines:
            url = line.rsplit('|')[3]
            jsonurl = url.replace('https://', 'https://' + jenkin_values[0] + ":" + jenkin_values[1] + '@', 1)
            jsonurl = jsonurl + 'lastBuild/api/json'
            print(jsonurl)
            try:
                response = requests.get(jsonurl)
                data = response.json()
                print(data)
                for key, value in data.items():
                    if key == 'result':
                        print(key, value)
                        status = value
                        if status == None:
                            status = 'RUNNING'
                # dt=datetime.datetime.now().date()
                with open(jenkinJobStatus, 'a') as file_obj:
                    file_obj.writelines(
                        str(datetime.date.today()) + " : " + line.rsplit('|')[0].ljust(50) + " : " + status + '\n')
            except:
                print(jsonurl)
                print("Error getting Jenkin job status.....")
    logger.info("Successfully write the status of all pushed jobs into : "+jenkinJobStatus)

def read_jenkin_credentials(jenkin_credential_file):
    print("read_jenkin_credentials started")
    jenkin_val = []
    data = load_json(jenkin_credential_file)
    jenkin_val.append(data['userid'])
    jenkin_val.append(data['apitoken'])
    jenkin_val.append(data['emailid'])
    jenkin_val.append(data['CRUMB'])
    jenkin_val.append(data['USERNAME'])
    jenkin_val.append(data['PASSWORD'])
    jenkin_val.append(data['devops_user_name'])
    jenkin_val.append(data['devops_user_password'])
    jenkin_val.append(data['UAASecret'])
    jenkin_val.append(data['FrameworkArtifactNumber'])
    #print(jenkin_val[0])
    #print(jenkin_val[1])
    #print(jenkin_val[2])
    print("read_jenkin_credentials ended")
    return jenkin_val


def split_uat_data_on_field(verifiedInBuild, envJobsUrlList, sanitizeSortedResultUatFile):
    logger.info("Begin method split_uat_data_on_field")
    print("Read data from "+verifiedInBuild+" and "+envJobsUrlList+" started")
    file_path1 = os.path.join('.', verifiedInBuild)
    file_path2 = os.path.join('.', envJobsUrlList)
    file_path3 = os.path.join('.', sanitizeSortedResultUatFile)
    uat_artifact_array = []
    with open(file_path1, mode='rt') as f1, open(file_path3, 'w') as final:
        writer = csv.writer(final, delimiter=',')
        reader = csv.reader(f1, delimiter=',')
        # _ = next(reader)
        lines = (line.rstrip() for line in f1)  # All lines including the blenlank ones
        lines = (line for line in lines if line)  # Non-blank lines
        for line in lines:
            artifactName = line[0:re.search('\d', line).start() - 1]  # first part is job name
           # print(artifactName)
            artifactVersion = line[re.search('\d', line).start():[m.start() for m in re.finditer(r"\.", line)][2]]
           # print(artifactVersion)
            artifactNo = re.findall(r'\d+', line)[-1]
           # print(artifactNo)
            with open(file_path2, 'r') as f2:
                for ln in f2:
                    urlList = ln.split(',')
                    if artifactName == urlList[0]:
                        urlName = urlList[1]
                        break
                    else:
                        urlName = ""

            if not urlName:
                err_msg = "***ERROR****: URL is a mandatory field. Missing in envJobsUrlList file for : " + artifactName
                logger.error(err_msg)
                raise AttributeError(err_msg)
            elif artifactName[0:4].lower() == 'ong-':
                line = artifactName + "|" + artifactVersion + "|" + artifactNo + "|" + "|".join(urlList[1:len(urlList)])
                print(line)
            else:
                line = artifactName + "|" + artifactVersion + "|" + artifactNo + "|" + urlName
            uat_artifact_array.append(line)
    if uat_artifact_array:
        write_file(sanitizeSortedResultUatFile, uat_artifact_array)
    else:
        warn_msg = "No stories(US) or defects(D) available for promotion."
        logger.info(warn_msg)
        sys.stdout.write("\n" + warn_msg)
        sys.stdout.flush()
        logger.info("Successfully created a sanitized file :"+sanitizeSortedResultUatFile)
        print("split_uat_data_on_field ended")
        sys.exit()

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



def write_file(filename, filedata_array):
    logger.info("Begin method write_file : " + filename)
    logger.info("Write File " + filename + ", contains the data: \n" + str(filedata_array))
    with open(filename, 'w') as file_obj:
        file_obj.writelines(filedata_array)
    logger.info("End method write_file : " + filename)


def validate_inputs(verifiedInBuild, environment):
    logger.info("Begin method validate_inputs")

    if not verifiedInBuild:
        err_msg = "verifiedInBuild is a mandatory field. "
        logger.error(err_msg)
        raise AttributeError(err_msg)

    if not environment:
        err_msg = "environment is a mandatory field. "
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

def usage():
    print("\n")
    usage_message_main1 = ("Usage: " + __file__ + "[--help] -f1 <verifiedInBuild> --environment <environment>")
    usage_message_main2 = ("Usage: " + __file__ + " [-h] -f1 <verifiedInBuild>  -e <environment>")
    usage_message_add = (
    "[Auto Trigger of UAT/ENV Promotion push] This script will auto trigger the Jenkin push which are ready for promotion for a specified environment")
    print(usage_message_main1)
    print("OR")
    print(usage_message_main2)
    print(usage_message_add)
    print("\n")


if __name__ == "__main__":
    main(sys.argv[1:])
