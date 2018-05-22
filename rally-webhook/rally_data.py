import sys, os, csv
import getopt
import og_utils
from pyral import Rally, rallyWorkset, RallyRESTAPIError
import argparse
import logging
import os
import time
import platform
import timeit
import traceback
import datetime
logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())
#################################################################################################
# required python3 , pyral
#  showdefects -- show defects in a workspace/project conforming to some common criterion
#
# -----------    ----------------  -------------------------------------
#  Date           Author            Comment
# -----------    ----------------  -------------------------------------
#   May-17-2018  Khushnuma Daruwala      Intial Version
#
# python3 rally_data.py -c rallyuser.cfg -e QA01
# python3 rally_data.py --config_file devops-rallyuser.cfg --environment QA01
#
#criterion:
#   PromotedImpactedEnvironment = QA01 and State = Closed and VerifiedEnvironment = QA01 and Resolution = Code Change
#   Exclude Projects =  'The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor','Green Beret'

#################################################################################################
DEFECT_QUERY_FILE = 'rally_defect_config.json'
USER_STORY_QUERY_FILE = 'rally_userstory_config.json'
ALL_TYPE = 'all'
USER_STORY_TYPE = 'userstory'
DEFECT_TYPE = 'defect'
VALID_TYPES =[USER_STORY_TYPE, DEFECT_TYPE]
header = 'FormattedID | VerifiedinBuildTOBEUSED | Name | State | PromotedImpactedEnvironment'
finalHeader = 'FormattedID|VerifiedinBuildTOBEUSED|Name'
us_entity = 'UserStory'
defect_entity  = 'Defect'
def main(argv):
    logger.info("Begin main method.")
    logger.info("Python version: "+str(platform.python_version()))
    print(platform.python_version())
    environment = None
    config_file = None
    story_type = None
    rally_query =None
    entity_name = None

    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, "h:c:e:t:", ["help=", "config_file=", "environment=", "type="])
    except getopt.GetoptError as exc:
        print(exc.msg)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-c", "--config_file"):
            config_file = arg
        elif opt in ("-e", "--environment"):
            environment = arg
        elif opt in ("-t", "--type"):
            story_type = arg

    create_log_file()
    start = timeit.default_timer()
    try:
        validate_platform_clear_screen()
        start_message="Start Process of Retrieving data from Rally for promotion."
        logger.info(start_message)
        print("\n"+start_message+"\n")
        validate_inputs(config_file, environment, story_type)
        rally, projects, workspace = get_rally_projects(config_file)
        entity_name = set_entity(story_type)
        entity_dict = get_file_data_based_on_entity(entity_name)
        query_file = entity_dict['q_file']
        if os.path.isfile(query_file) is False:
            err_msg = "File [" + query_file + "] is not present."
            raise AttributeError(err_msg)

        query_file_map = og_utils.load_json(query_file)
        if environment in query_file_map:
            rally_query = query_file_map[environment]
        else:
            error_message = "There is no entry for " + environment + " in the file " + query_file
            raise AttributeError(error_message)

        data_array, raw_data_array = get_rally_entity_data(projects, rally, entity_name, workspace, rally_query)
        #print(data_array)
        og_utils.write_file(entity_dict['stageFile'], data_array)
        file_split_data_array, split_data_array = split_data_on_field(raw_data_array)
        og_utils.write_file(entity_dict['finalFile'], file_split_data_array)
        sorted_file_array = create_sorted_file(split_data_array)
        og_utils.write_file(entity_dict['finalSortedFile'], sorted_file_array)

        exit_status = 0
        exit_message = 'Success'

    except Exception as ex:
        if str(ex):
            print (str(ex) + "\n")
        logger.exception(ex)
        exit_status = 1
        exit_message = 'Failed'
        exc_type, exc_obj, exc_tb = sys.exc_info()
        traceback.print_tb(exc_tb)

    finally:
        stop = timeit.default_timer()
        total_time = stop - start

        print("\nEnd Process of Retrieving data from Rally for promotion.\n")

        logger.info(
            "Script execution status [" + exit_message + "], time taken [" + str(datetime.timedelta(seconds=total_time)) + "]")
        sys.exit(exit_status)

def get_rally_entity_data(projects, rally, entity_name, workspace, rally_query):
    logger.info("Begin method get_rally_entity_data")
    raw_data_array = []
    data_array = []
    data_array.append(header+"\n")
    for proj in projects:
        response = rally.get(entity_name, fetch=True, query=rally_query, order='VerifiedinBuildTOBEUSED',
                             workspace=workspace, project=proj.Name)
        #print(response)
        response.encoding = "utf-8"
        if response.resultCount > 0:
            if entity_name == us_entity:
                for userstory in response:
                    VerifiedinBuildTOBEUSED = userstory.VerifiedinBuildTOBEUSED
                    if VerifiedinBuildTOBEUSED != None:
                        VerifiedinBuildTOBEUSED_byte = VerifiedinBuildTOBEUSED.encode("utf-8")
                        VerifiedinBuildTOBEUSED_str = (str(VerifiedinBuildTOBEUSED_byte)).strip()
                    else:
                        VerifiedinBuildTOBEUSED_str = 'None'
                    line = userstory.FormattedID+"|"+VerifiedinBuildTOBEUSED_str+"|"+userstory.Name+"|"+userstory.ScheduleState+"\n"
                    data_array.append(line)
                    raw_data_array.append((userstory.FormattedID, VerifiedinBuildTOBEUSED_str, userstory.Name))
            elif entity_name == defect_entity:
                if proj.Name not in ['The Fellowship', 'Hulk', 'Hydra', 'Shield', 'Thor', 'Green Beret']:
                    for defect in response:
                        VerifiedinBuildTOBEUSED = defect.VerifiedinBuildTOBEUSED
                        if VerifiedinBuildTOBEUSED != None:
                                VerifiedinBuildTOBEUSED_byte = VerifiedinBuildTOBEUSED.encode("utf-8")
                                VerifiedinBuildTOBEUSED_str = (str(VerifiedinBuildTOBEUSED_byte)).strip()
                        else:
                            VerifiedinBuildTOBEUSED_str = 'None'
                        line = defect.FormattedID+"|"+VerifiedinBuildTOBEUSED_str+"|"+defect.Name+"|"+defect.State+"|"+defect.PromotedImpactedEnvironment+"\n"
                        data_array.append(line)
                        raw_data_array.append((defect.FormattedID, VerifiedinBuildTOBEUSED_str, defect.Name))
    logger.info("End method get_rally_entity_data")
    return data_array, raw_data_array


def split_data_on_field(raw_data_array):
    logger.info("Begin method split_data_on_field")
    split_data_array = []
    file_split_data_array =[]
    file_split_data_array.append(finalHeader+"\n")
    for current_tuple in raw_data_array:
        curr_id = (current_tuple[0]).strip()
        curr_build =current_tuple[1]
        curr_name = (current_tuple[2]).strip()
        if ',' in curr_build:
            logger.info("Splitting VerifiedinBuildTOBEUSED on comma: "+curr_build)
            verifiedInBuildSplit = curr_build.split(',')
            for each_obj in verifiedInBuildSplit:
                cleaned_build = og_utils.remove_specific_pattern(each_obj.strip())
                line= curr_id+"|"+cleaned_build+"|"+curr_name+"\n"
                file_split_data_array.append(line)
                split_data_array.append((curr_id, cleaned_build, curr_name))
        else:
            cleaned_build = og_utils.remove_specific_pattern(curr_build.strip())
            line = curr_id + "|" + curr_build.strip() + "|" + curr_name + "\n"
            file_split_data_array.append(line)
            split_data_array.append((curr_id, cleaned_build, curr_name))

    logger.info("End method split_data_on_field")
    return file_split_data_array, split_data_array


def create_sorted_file(split_data_array):
    logger.info("Begin method split_data_array.")
    sorted_file_array = []
    sorted_file_array.append(finalHeader + "\n")
    if split_data_array:
        split_data_array.sort(key=lambda x: x[1])
        for curr_tuple in split_data_array:
            line = curr_tuple[0]+"|"+curr_tuple[1]+"|"+curr_tuple[2]+"\n"
            sorted_file_array.append(line)
    logger.info("Sorted File data: "+str(sorted_file_array))
    logger.info("End method split_data_array.")
    return sorted_file_array


def set_entity(story_type):
    logger.info("Begin method set_entity")
    entity_name = None
    if story_type == USER_STORY_TYPE:
        entity_name = us_entity
    elif story_type == DEFECT_TYPE:
        entity_name = defect_entity
    logger.info("Entity name: "+entity_name)
    logger.info("End method set_entity")
    return entity_name


def get_file_data_based_on_entity(entity_name):
    entity_dict = {}
    logger.info("Begin method get_file_data_based_on_entity")
    if entity_name == us_entity:
        entity_dict['entity_name']= us_entity
        entity_dict['q_file'] = USER_STORY_QUERY_FILE
        entity_dict['stageFile']= 'outputResultUS.csv'
        entity_dict['finalFile'] = 'splitResultsUS.csv'
        entity_dict['finalSortedFile'] = 'sortedResultUS.csv'

    elif entity_name == defect_entity:
        entity_dict['entity_name']= defect_entity
        entity_dict['q_file'] = DEFECT_QUERY_FILE
        entity_dict['stageFile']= 'outputResultD.csv'
        entity_dict['finalFile'] = 'splitResultsD.csv'
        entity_dict['finalSortedFile'] = 'sortedResultD.csv'
    logger.info("End method get_file_data_based_on_entity")

    return entity_dict


def get_rally_projects(config_file):
    logger.info("Begin method get_rally_projects")
    projects =None
    rally_input = []
    input = "--config=" + config_file
    rally_input.append(input)
    server, username, password, apikey, workspace, project = rallyWorkset(rally_input)
    logger.info("Server: "+server+", username: "+username+", password: "+password+", apikey: "+apikey+", workspace: "+workspace+", project: "+project)
    if apikey:
        rally = Rally(server, apikey=apikey, workspace=workspace, project=project)
    else:
        rally = Rally(server, user=username, password=password, workspace=workspace, project=project)

    projects = rally.getProjects(workspace)
    logger.info("Project List: "+str(len(projects)))
    logger.info("End method get_rally_projects")
    return rally, projects, workspace



def validate_inputs(config_file, environment, story_type):
    logger.info("Begin method validate_inputs")

    if not config_file:
        err_msg = "Cannot have blank config_file. Please give a valid file name."
        logger.error(err_msg)
        raise AttributeError(err_msg)

    if not environment:
        err_msg = "Environment is a mandatory field. "
        logger.error(err_msg)
        raise AttributeError(err_msg)

    if not story_type:
        err_msg = "story_type is a mandatory field. Please enter a valid value: "+str(VALID_TYPES)
        logger.error(err_msg)
        raise AttributeError(err_msg)

    if story_type not in VALID_TYPES:
        err_m = "Input story_type "+story_type+" is not a valid value. Please enter a valid story_type: "+str(VALID_TYPES)
        logger.error(err_m)
        raise AttributeError(err_m)

    logger.info("End method validate_inputs")


def validate_platform_clear_screen():
    platform_system = platform.system()
    if platform_system not in [ 'Linux', 'Darwin', 'Windows', 'CYGWIN_NT-6.2-WOW64' ]:
      logger.error(platform_system+' is not supported.')
      raise ValueError(platform_system+' is not supported.')
    else:
      # clearscreen
      if platform_system in ('Windows', 'CYGWIN_NT-6.2-WOW64'):
        os.system('cls')
      else:
        os.system('clear')


def create_log_file():
    cur_dir = os.path.dirname(os.path.realpath(__file__))
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    log_file = os.path.splitext(__file__)[0] + timestamp+'.log'
    log_file_path = os.path.join(cur_dir, log_file)
    # reset the default log file
    open(log_file_path, 'w').close()
    logger.setLevel(logging.DEBUG)

    if log_file is None:
        # use the console handler for logging
        handler = logging.StreamHandler()
    else:
        # use the file handler for logging
        handler = logging.FileHandler(log_file)

    # create formatter
    fmt = '%(asctime)s %(filename)-15s %(levelname)-6s: %(message)s'
    fmt_date = '%Y-%m-%dT%H:%M:%S%Z'
    formatter = logging.Formatter(fmt, fmt_date)
    handler.setFormatter(formatter)
    # add the handler to the logger
    logger.addHandler(handler)


def usage():
  print ("\n")
  usage_message_main1 = ("Usage: " + __file__ + "[--help] --config_file <config_file> --environment <environment>")
  usage_message_main2 = ("Usage: " + __file__ + " [-h] -c <config_file> -e <environment>")
  usage_message_add = ("[Environment Promotion list of User Stories or Defect(s)] This script lists all User Stories or Defect(s) which are ready for promotion for a specified environment")
  print (usage_message_main1)
  print("OR")
  print(usage_message_main2)
  print(usage_message_add)
  print("\n")


if __name__ == "__main__":
  main(sys.argv[1:])