import logging
import os
import time
import getopt
import timeit
import datetime
import platform
import sys
import re

logging.getLogger("requests").setLevel(logging.WARNING)

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())

finalHeader = 'FormattedID|VerifiedinBuildTOBEUSED|Name'
sanitizeOutputResultFile = 'sanitizeOutputResultUS.csv'

def main(argv):
    logger.info("In main method .................")

    outputResultUS = None

    if len(sys.argv) < 2:
        usage()
        sys.exit(1)

    try:
        opts, args = getopt.getopt(argv, "hl:o:", ["outputResultUS="])

    except getopt.GetoptError, exc:
        print exc.msg
        usage()
        sys.exit(2)

    for opt, arg in opts:
        if opt in ("-h", "--help"):
            usage()
            sys.exit(0)

        elif opt in ("-o", "--outputResultUS"):
            outputResultUS = arg

    create_log_file()
    start = timeit.default_timer()
    try:
        validate_platform_clear_screen()
        start_message="Start of Sanitize Output result"
        logger.info(start_message)
        print("\n")
        print(start_message)
        print("\n")
        sanitize = SanitizeOutputResultUS(outputResultUS)

        sanitize.sanitize_output_result_us()


        exit_status = 0
        exit_message = 'Success'

    except Exception as ex:
        if str(ex):
            print str(ex) + "\n"

        exit_status = 1
        exit_message = 'Failed'

    finally:
        stop = timeit.default_timer()
        total_time = stop - start

        print("\n")
        print("End of Sanitize Output result.\n")
        print("\n")

        logger.info(
            "Script execution status [" + exit_message + "], time taken [" + str(datetime.timedelta(seconds=total_time)) + "]")
        sys.exit(exit_status)



class SanitizeOutputResultUS(object):
    def __new__(cls, outputResultUS):
        if not hasattr(cls, 'instance'):
            cls.instance = super(SanitizeOutputResultUS, cls).__new__(cls)
        return cls.instance

    def __init__(self, outputResultUS):
        super(SanitizeOutputResultUS, self).__init__()
        try:
            print('\n')
            print('Validating User Input: ')
            self.outputResultUS = outputResultUS
            self.__validate_inputData()

        except Exception as ex:
            print ex
            raise ex

    def __validate_inputData(self):
        common_err_msg = "is not supplied as a command line argument.";
        if self.outputResultUS is None:
            error_message="Output Result US File "+common_err_msg
            logger.error(error_message)
            print(error_message)
            raise AttributeError(error_message)

    def sanitize_output_result_us(self):
        logger.info("In sanitize_output_result_us method .................")
        with open('outputResultUS.csv') as f1:
            with open(sanitizeOutputResultFile, 'w') as f2:
                f2.write(finalHeader + '\n')
                f1.next()  # skip header
                for line in f1:
                    verifiedInBuild = line.split('|')[1]
                    split_verifiedInBuild = re.split('[> <]', verifiedInBuild)
                    artifact_list = ""
                    for value in split_verifiedInBuild:
                        if '.zip' in value:
                            if '.zip,' in value:
                                artifact_list += value
                            else:
                                artifact_list += value+','

                    if artifact_list:
                        f2.write("%-8.8s|%s|%s\n" % (
                            line.split('|')[0], artifact_list, line.split('|')[2]))
                    else:
                        f2.write("%-8.8s|%s|%s\n" % (
                            line.split('|')[0], verifiedInBuild, line.split('|')[2]))


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
  print "\n"
  usage_message_one = ("Usage: " + __file__ + " [-h] -o <outputResultUS>]")
  usage_message_two = ("Usage: " + __file__ + " [-h] --outputResultUS <outputResultUS>]")
  print usage_message_one
  print "OR"
  print usage_message_two

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
