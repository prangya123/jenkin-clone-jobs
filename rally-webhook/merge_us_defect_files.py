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

logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())

finalHeader = 'FormattedID|VerifiedinBuildTOBEUSED|Name'
mergedResultFile = 'mergedResult.csv'
mergedSortedResultFile = 'mergedSortedResult.csv'
sortedIdFile = 'sortedId.csv'
verifiedInBuildFile = 'verifiedInBuild.csv'
sanitizeSortedResultUSFile = 'sanitizeSortedResultUS.csv'

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
        start_message="Start of Merging of Defect File and UserStory File"
        logger.info(start_message)
        print("\n")
        print(start_message)
        print("\n")
        merge_files = MergeFiles(sortedResultD, sortedResultUS)

        merge_files.sanitize_output_result_us()
        merge_files.merge_file()
        merge_files.sort_merged_file()
        merge_files.get_sorted_id()
        merge_files.get_sorted_verified_in_build()

        exit_status = 0
        exit_message = 'Success'

    except Exception as ex:
        if str(ex):
            print (str(ex) + "\n")

        exit_status = 1
        exit_message = 'Failed'

    finally:
        stop = timeit.default_timer()
        total_time = stop - start

        print("\n")
        print("End of Merging of Defect File and UserStory File.\n")
        print("\n")

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


    def sanitize_output_result_us(self):
        logger.info("In sanitize_output_result_us method .................")
        with open(self.sortedResultUS) as f1:
            f1.readline()  # skip header
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            with open(sanitizeSortedResultUSFile, 'w') as f2:
                f2.write(finalHeader + '\n')
                for line in lines:
                    verifiedInBuild = line.split('|')[1]
                    split_verifiedInBuild = re.split('[> <]', verifiedInBuild)
                    artifact_name = ""
                    for value in split_verifiedInBuild:
                        if '.zip' in value:
                            artifact_name = value
                            break
                        elif '.gz' in value:
                            artifact_name = value
                            break

                    if artifact_name:
                        f2.write("%-8.8s|%s|%s\n" % (
                            line.split('|')[0], artifact_name, line.split('|')[2]))
                    else:
                        f2.write("%-8.8s|%s|%s\n" % (
                            line.split('|')[0], verifiedInBuild, line.split('|')[2]))

    def merge_file(self):
        # Merge files
        logger.info("In merge_file method .................")
        filenames = [self.sortedResultD, sanitizeSortedResultUSFile]
        with open(mergedResultFile, 'w') as outfile:
            outfile.write(finalHeader + '\n')
            for fname in filenames:
                with open(fname) as infile:
                    next(infile)  # skip header
                    for line in infile:
                        outfile.write(line)

    def sort_merged_file(self):
        # Sort the mergedResult File and write into mergedSortedResult
        logger.info("In sort_merged_file method .................")
        with open(mergedResultFile, mode='rt') as f, open(mergedSortedResultFile, 'w') as final:
            writer = csv.writer(final, delimiter='|')
            reader = csv.reader(f, delimiter='|')
            _ = next(reader)
            result = sorted(filter(None, reader), key=lambda row: row[1])
            final.write(finalHeader + '\n')
            for row in result:
                writer.writerow(row)

    def get_sorted_id(self):
        # get ids from sorted merged file
        logger.info("In get_sorted_id method .................")
        with open(mergedSortedResultFile) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            with open(sortedIdFile, 'w') as f2:
                f1.readline()  # skip header
                for line in lines:
                    ids = line.split('|')[0]
                    f2.write(ids+", ")

    def get_sorted_verified_in_build(self):
        # get verified_in_build from sorted merged file
        logger.info("In get_sorted_verified_in_build method .................")
        with open(mergedSortedResultFile) as f1:
            lines = (line.rstrip() for line in f1)  # All lines including the blank ones
            lines = (line for line in lines if line)  # Non-blank lines
            with open(verifiedInBuildFile, 'w') as f2:
                f1.readline()  # skip header
                for line in lines:
                    verifiedInBuild = line.split('|')[1]
                    if verifiedInBuild != 'None' and verifiedInBuild != '' and verifiedInBuild != 'N/A':
                        f2.write(verifiedInBuild + ", ")



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
