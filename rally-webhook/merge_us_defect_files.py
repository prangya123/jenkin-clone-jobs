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
        merge_files.get_sorted_id()
        merge_files.get_sorted_verified_in_build()

        exit_status = 0
        exit_message = 'Success'

    except Exception as ex:
        if str(ex):
            print (str(ex) + "\n")
        exc_type, exc_obj, exc_tb = sys.exc_info()
        traceback.print_tb(exc_tb)
        sys.exit(2)
        exit_status = 1
        exit_message = 'Failed'

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
        ignore_array = []
        sanitized_file_array = []
        sanitized_file_array.append(finalHeader + '\n')
        ignore_array.append(finalHeader + '\n')
        with open(file_to_clean) as f1:
            f1.readline()  # skip header
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            for line in lines:
                verifiedInBuild = line.split('|')[1]
                split_verifiedInBuild = re.split('[> <]', verifiedInBuild)
                artifact_name = None
                for value in split_verifiedInBuild:
                    if self.check_if_string_is_artifact(value):
                        artifact_name = self.clean_artifact(value)


                if artifact_name:
                    line_passed = line.split('|')[0]+"|"+artifact_name+"|"+line.split('|')[2]+"\n"
                    logger.debug("Line passed is: " + line_passed)
                    sanitized_file_array.append(line_passed)
                else:
                    ignored_line = line.split('|')[0]+"|"+verifiedInBuild+"|"+line.split('|')[2]+"\n"
                    logger.debug("Line ignored is: "+ignored_line)
                    ignore_array.append(ignored_line)

        if ignore_array:
            self.write_file(ignore_file, ignore_array)

        if sanitized_file_array:
            self.write_file(sanitizeSortedResultFile, sanitized_file_array)

        logger.info("End method sanitize_output_result.")


    def merge_file(self):
        # Merge files
        logger.info("Begin method merge_file.")
        logger.info("Files being merged are "+sanitizeSortedResultDFile+" and "+sanitizeSortedResultUSFile+".")
        filenames = [sanitizeSortedResultDFile, sanitizeSortedResultUSFile]
        with open(mergedResultFile, 'w') as outfile:
            outfile.write(finalHeader + '\n')
            for fname in filenames:
                with open(fname) as infile:
                    next(infile)  # skip header
                    for line in infile:
                        outfile.write(line)
        logger.info("End method merge_file.")


    def sort_merged_file(self):
        # Sort the mergedResult File and write into mergedSortedResult
        logger.info("Begin method sort_merged_file")
        logger.info("File being sorted is: "+mergedResultFile)
        with open(mergedResultFile, mode='rt') as f, open(mergedSortedResultFile, 'w') as final:
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
        with open(mergedSortedResultFile) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            f1.readline()  # skip header
            for line in lines:
                ids = line.split('|')[0]
                id_array.append(ids+"\n")

        logger.info("List of Ids to be promoted: \n" + str(id_array))
        if id_array:
            self.write_file(sortedIdFile, id_array)
        logger.info("End method get_sorted_id")


    def get_sorted_verified_in_build(self):
        # get verified_in_build from sorted merged file
        logger.info("Begin method get_sorted_verified_in_build.")
        verified_array = []
        with open(mergedSortedResultFile) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            f1.readline()  # skip header
            for line in lines:
                verifiedInBuild = line.split('|')[1]
                verified_array.append(verifiedInBuild+"\n")
        logger.info("Artifacts to be promoted: \n" + str(verified_array))
        if verified_array:
            self.write_file(verifiedInBuildFile, verified_array)
            logger.info("End method get_sorted_verified_in_build.")


    def clean_artifact(self, input_artifact_name):
        cleaned_artifact = None
        artifact_name = input_artifact_name
        logger.info("Begin method clean_artifact")
        logger.info("Incoming artifact name is : "+input_artifact_name)
        if artifact_name and "'" in artifact_name:
            artifact_name = self.split_on_apostrophe(artifact_name)
        if artifact_name and "/" in artifact_name:
            artifact_name = self.split_on_forwardslash(artifact_name)
        if artifact_name and "\"" in artifact_name:
            artifact_name = self.split_on_doublequote(artifact_name)
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


    def split_on_apostrophe(self, data):
        output = None
        my_list = data.split("'")
        for value in my_list:
            if self.check_if_string_is_artifact(value):
                output = value
                break
        return output


    def split_on_forwardslash(self, data):
        output = None
        my_list = data.split("/")
        for value in my_list:
            if self.check_if_string_is_artifact(value):
                output = value
                break
        return output


    def split_on_doublequote(self, data):
        output = None
        my_list = data.split("\"")
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
