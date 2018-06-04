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
import copy
import og_utils
from packaging import version

logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())

finalHeader = 'FormattedID|VerifiedinBuildTOBEUSED|Name'
mergedResultFile = 'mergedResult.csv'
mergedSortedResultFile = 'mergedSortedResult.csv'
sortedIdFile = 'sortedId.csv'
verifiedInBuildFile = 'verifiedInBuild.csv'
sanitizeSortedResultUSFile = 'sanitizeSortedResultUS.csv'
sanitizeSortedResultDFile = 'sanitizeSortedResultD.csv'
ignoreUserStoriesFile="ignore_us.csv"
ignoreDefectsFile = "ignore_defect.csv"
DIR_NAME = "logs"


def main(argv):
    logger.info("In main method .................")
    print(platform.python_version())

    sortedResultD = None
    sortedResultUS = None

    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, "hl:d:u:", ["sortedResultD=", "sortedResultUS="])

    except getopt.GetoptError as  exc:
        print(exc.msg)
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-d", "--sortedResultD"):
            sortedResultD = arg
        elif opt in ("-u", "--sortedResultUS"):
            sortedResultUS = arg

    create_log_file()
    start = timeit.default_timer()
    try:
        validate_platform_clear_screen()
        start_message="Start Proces of Sanitizing and Merging the Defect and UserStory Files."
        logger.info(start_message)
        print("\n"+start_message+"\n")
        merge_files = MergeFiles(sortedResultD, sortedResultUS)

        merge_files.sanitize_output_result(sortedResultUS, sanitizeSortedResultUSFile, ignoreUserStoriesFile)
        merge_files.sanitize_output_result(sortedResultD, sanitizeSortedResultDFile, ignoreDefectsFile)
        merge_files.merge_file()
        merge_files.sort_merged_file()
        id_array = merge_files.get_sorted_id()
        merge_files.get_sorted_verified_in_build()
        get_ignored_ids = merge_files.get_ignored_ids(id_array)
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

        print("\nEnd Proces of Sanitizing and Merging the Defect and UserStory Files.\n")

        logger.info(
            "Script execution status [" + exit_message + "], time taken [" + str(datetime.timedelta(seconds=total_time)) + "]")
        sys.exit(exit_status)



class MergeFiles(object):
    def __new__(cls, sortedResultD, sortedResultUS):
        if not hasattr(cls, 'instance'):
            cls.instance = super(MergeFiles, cls).__new__(cls)
        return cls.instance


    def __init__(self, sortedResultD, sortedResultUS):
        super(MergeFiles, self).__init__()
        try:
            print('\n')
            print('Validating User Input: ')
            self.sortedResultD = sortedResultD
            self.sortedResultUS = sortedResultUS
            self.all_ids = set()
            self.__validate_inputData()

        except Exception as ex:
            print (ex)
            raise ex


    def __validate_inputData(self):
        common_err_msg = "is not supplied as a command line argument.";
        if self.sortedResultD is None:
            error_message="Sorted Result Defect File "+common_err_msg
            logger.error(error_message)
            print(error_message)
            raise AttributeError(error_message)
        if self.sortedResultUS is None:
            error_message="Sorted Result UserStory File "+common_err_msg
            logger.error(error_message)
            print(error_message)
            raise AttributeError(error_message)


    def sanitize_output_result(self, file_to_clean, sanitizeSortedResultFile, ignore_file):
        logger.info("Begin method sanitize_output_result.")
        ignore_array_file = []
        sanitized_file_array = []
        sanitized_file_array.append(finalHeader + '\n')
        ignore_array_file.append(finalHeader + '\n')
        with open(file_to_clean) as f1:
            f1.readline()  # skip header
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            for line in lines:
                id = line.split('|')[0]
                self.all_ids.add(id)
                verifiedInBuild = line.split('|')[1]
                name = line.split('|')[2]
                split_verifiedInBuild = re.split('[> <]', verifiedInBuild)
                artifact_name = None
                for value in split_verifiedInBuild:
                    if self.check_if_string_is_artifact(value):
                        artifact_name = self.clean_artifact(value)
                if artifact_name:
                    line_passed = id+"|"+artifact_name+"|"+name+"\n"
                    logger.debug("Line passed is: " + line_passed)
                    sanitized_file_array.append(line_passed)
                else:
                    ignored_line = id+"|"+verifiedInBuild+"|"+name+"\n"
                    logger.info("Line ignored is: "+ignored_line)
                    ignore_array_file.append(ignored_line)

        if ignore_array_file:
            ignore_array_file.sort(key=lambda x: x[0])
            filepath = os.path.join('.',DIR_NAME, ignore_file)
            og_utils.write_file(filepath, ignore_array_file)

        if sanitized_file_array:
            filepath2 = os.path.join('.', DIR_NAME, sanitizeSortedResultFile)
            og_utils.write_file(filepath2, sanitized_file_array)

        logger.info("End method sanitize_output_result.")


    def merge_file(self):
        # Merge files
        logger.info("Begin method merge_file.")
        logger.info("Files being merged are "+sanitizeSortedResultDFile+" and "+sanitizeSortedResultUSFile+".")
        filenames = [sanitizeSortedResultDFile, sanitizeSortedResultUSFile]
        filepath = os.path.join('.',DIR_NAME, mergedResultFile)
        with open(filepath, 'w') as outfile:
            outfile.write(finalHeader + '\n')
            for fname in filenames:
                fpath = os.path.join('.',DIR_NAME, fname)
                with open(fpath) as infile:
                    next(infile)  # skip header
                    for line in infile:
                        outfile.write(line)
        logger.info("End method merge_file.")


    def sort_merged_file(self):
        # Sort the mergedResult File and write into mergedSortedResult
        logger.info("Begin method sort_merged_file")
        logger.info("File being sorted is: "+mergedResultFile)
        file_path1 = os.path.join('.',DIR_NAME,mergedResultFile)
        file_path2 = os.path.join('.', DIR_NAME, mergedSortedResultFile)
        with open(file_path1, mode='rt') as f, open(file_path2, 'w') as final:
            writer = csv.writer(final, delimiter='|')
            reader = csv.reader(f, delimiter='|')
            _ = next(reader)
            result = sorted(filter(None, reader), key=lambda row: row[1])
            final.write(finalHeader + '\n')
            for row in result:
                writer.writerow(row)

        logger.info("End method sort_merged_file")


    def get_sorted_id(self):
        # get ids from sorted merged file
        logger.info("Begin method get_sorted_id")
        id_array = []
        fpath1= os.path.join('.',DIR_NAME, mergedSortedResultFile)
        with open(fpath1) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            f1.readline()  # skip header
            for line in lines:
                ids = line.split('|')[0]
                key = ids+"\n"
                if key in id_array:
                    logger.info("Id "+ids+", already exists in the id's array. Will not be added a second time.")
                else:
                    id_array.append(key)
        file_id_array = []
        file_id_array.append("FormattedID\n")
        logger.info("List of Ids to be promoted: \n" + str(id_array))
        if id_array:
            file_id_array.extend(id_array)
            og_utils.write_file(sortedIdFile, file_id_array)
        else:
            warn_msg = "No stories(US) or defects(D) available for promotion."
            logger.info(warn_msg)
            sys.stdout.write("\n"+warn_msg)
            sys.stdout.flush()
        logger.info("End method get_sorted_id")
        return id_array


    def get_sorted_verified_in_build(self):
        # get verified_in_build from sorted merged file
        logger.info("Begin method get_sorted_verified_in_build.")
        build_list = self.extract_all_builds()
        if build_list:
            list_to_examine = copy.deepcopy(build_list)
            promote_builds = self.get_only_highest_builds(list_to_examine)
            if promote_builds:
                og_utils.write_file(verifiedInBuildFile, promote_builds)
        else:
            warn_msg = "No builds availble for promotion."
            sys.stdout.write("\n"+warn_msg)
            sys.stdout.flush()
        logger.info("End method get_sorted_verified_in_build.")


    def extract_all_builds(self):
        verified_array = []
        logger.info("Begin method extract_all_builds")
        fpath = os.path.join('.', DIR_NAME, mergedSortedResultFile)
        with open(fpath) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            f1.readline()  # skip header
            for line in lines:
                verifiedInBuild = line.split('|')[1]
                verified_array.append(verifiedInBuild)
        logger.info("List of extracted builds: "+str(verified_array))
        logger.info("End method extract_all_builds")
        return verified_array


    def get_only_highest_builds(self, build_list):
        promote_builds = []
        version_dict = {}
        logger.info("Begin method get_only_highest_builds")
        for current in build_list:
            current_value = current.strip()
            version = self.getVersionFromString(current_value)
            logger.info("Version extracted for "+current_value+", is "+str(version))
            name, v, extension = current_value.partition(version)
            curr_key = name + extension
            if curr_key in version_dict:
                v_list, aux_dict = version_dict[curr_key]
                v_list.append(version)
                aux_dict[version] = current_value
                version_dict[curr_key] = v_list, aux_dict
            else:
                v_list = []
                aux_dict = {}
                v_list.append(version)
                aux_dict[version] = current_value
                version_dict[curr_key] = (v_list, aux_dict)
        logger.info("Version Dictionary is: "+str(version_dict))
        promote_builds = self.getHighestVersion(version_dict)

        logger.info("End method get_only_highest_builds")
        return promote_builds


    def getVersionFromString(self, verifiedinBuild):
        logger.info("Begin method getVersionFromString")
        version_string = None
        build_list = re.findall(r'-?\d+', verifiedinBuild)
        size = len(build_list)
        for i in range(0, size):
            if i == 0:
                version_string = build_list[i]
            else:
                version_string = version_string + "." + build_list[i]

        logger.info("End method getVersionFromString")
        return version_string


    def getHighestVersion(self, version_dict):
        logger.info("Begin method getHighestVersion")
        high_version_list = []
        for key, complex_tuple in version_dict.items():
            version_list = complex_tuple[0]
            aux_dict = complex_tuple[1]
            highestVersion = None
            for version_number in version_list:
                if highestVersion is None:
                    highestVersion = version_number
                else:
                    if (version.parse(version_number) > version.parse(highestVersion)):
                        highestVersion = version_number
            real_name = aux_dict[highestVersion]
            high_version_list.append(real_name+"\n")

        logger.info("Highest Build versions to be promoted are: "+str(high_version_list))
        logger.info("End method getHighestVersion")
        return high_version_list


    def clean_artifact(self, input_artifact_name):
        cleaned_artifact = None
        artifact_name = input_artifact_name
        logger.info("Begin method clean_artifact")
        logger.info("Incoming artifact name is : "+input_artifact_name)
        if artifact_name and "'" in artifact_name:
            artifact_name = self.split_on_given_delimiter(artifact_name, "'")
        if artifact_name and "/" in artifact_name:
            artifact_name = self.split_on_given_delimiter(artifact_name, "/")
        if artifact_name and "\"" in artifact_name:
            artifact_name = self.split_on_given_delimiter(artifact_name, "\"")
        if artifact_name and "=" in artifact_name:
            artifact_name = self.split_on_given_delimiter(artifact_name, "=")
        if artifact_name and "&nbsp;" in artifact_name:
            artifact_name = self.split_on_given_delimiter(artifact_name, "&nbsp;")
        if artifact_name:
            cleaned_artifact = artifact_name

        logger.info("Input artifact was: "+input_artifact_name+" Cleaned artifact returned is: "+cleaned_artifact)
        logger.info("End method clean_artifact")
        return cleaned_artifact


    def check_if_string_is_artifact(self, value):
        is_artifact  = False
        if '.zip' in value:
            is_artifact = True

        elif '.gz' in value:
            is_artifact = True

        elif '.json' in value:
            is_artifact = True

        return is_artifact


    def split_on_given_delimiter(self, data, delimiter):
        output = None
        my_list = data.split(delimiter)
        for value in my_list:
            if self.check_if_string_is_artifact(value):
                output = value
                break
        return output


    def write_file(self, filename, filedata_array):
        logger.info("Begin method write_file")
        logger.info("Write File " + filename + ", contains the data: \n" + str(filedata_array))
        with open(filename, 'w') as file_obj:
            file_obj.writelines(filedata_array)
        logger.info("End method write_file")


    def get_ignored_ids(self, id_array):
        logger.info("Begin method get_ignored_ids")
        ignore_ids =[]
        file_ignore_ids = []
        file_ignore_ids.append("FormattedID\n")
        for curr_id in self.all_ids:
            check_string = curr_id+"\n"
            if check_string not in id_array:
                ignore_ids.append(check_string)
        if ignore_ids:
            ignore_ids.sort(key=lambda x: x[0])
            file_ignore_ids.extend(ignore_ids)
        og_utils.write_file("ignore_ids.csv", file_ignore_ids)
        logger.info("List of Ids that will not be promoted are: "+str(ignore_ids))
        logger.info("End method get_ignored_ids")
        return ignore_ids

def create_log_file():
    og_utils.check_or_create_report_directory(DIR_NAME)
    cur_dir = os.path.dirname(os.path.realpath(__file__))
    filename = os.path.basename(__file__)
    script_file_path = os.path.splitext(__file__)[0]
    timestamp = time.strftime("%Y%m%d-%H%M%S")
    log_file = filename + timestamp+'.log'
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
  print ("\n")
  usage_message_one = ("Usage: " + __file__ + " [-h] -d <sortedResultD> -u <sortedResultUS>]")
  usage_message_two = ("Usage: " + __file__ + " [-h] --sortedResultD <sortedResultD> --sortedResultUS <sortedResultUS>]")
  print (usage_message_one)
  print ("OR")
  print (usage_message_two)

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


if __name__ == "__main__":
  main(sys.argv[1:])
