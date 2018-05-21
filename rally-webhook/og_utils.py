import json
import os
import pprint
import logging
from collections import OrderedDict

logger = logging.getLogger()
logger.addHandler(logging.NullHandler())


def load_json(json_file):
  logger.info("Begin method load_json")
  validate_file(json_file, "JSON")
  # load the Json file into an object
  try:
    with open(json_file) as json_data:
      json_data = json.load(
          json_data, object_pairs_hook=OrderedDict, strict=None)
      logger.info("End method load_json")
      return json_data

  except ValueError as ex:
    em = "Error while loading JSON file [" + json_file + "], Error [" + str(ex)
    raise ex

def validate_file(file_name, file_tag):
  logger.info("Begin method validate_file")
  start_message = "Validating file [" + pprint.pformat(file_name) + "]"
  # make sure the File name is provided
  if file_name is None or file_name == '':
    error_msg = file_tag + " file name is missing"
    raise AttributeError(error_msg)

  # make sure the File exists
  if os.path.isfile(file_name) is False:
    error_msg = file_tag + " file [" + file_name + "] do not exist"
    raise AttributeError(error_msg)
  logger.info("End method validate_file")


def write_file(filename, filedata_array):
    logger.info("Begin method write_file")
    logger.info("Write File " + filename + ", contains the data: \n" + str(filedata_array))
    with open(filename, 'w') as file_obj:
      file_obj.writelines(filedata_array)
      logger.info("End method write_file")

def remove_specific_pattern(input_string):
  logger.info("Begin method remove_specific_pattern")
  output_string = None
  if '\xe2\x80\x8b' in input_string:
    prefix, separator, postfix = input_string.partition('\xe2\x80\x8b')
    output_string = prefix+postfix
  if '\\xe2\\x80\\x8b' in input_string:
    prefix, separator, postfix = input_string.partition('\\xe2\\x80\\x8b')
    output_string = prefix + postfix
  else:
    output_string = input_string
  logger.info("Input was: "+input_string+". Cleaned value was: "+output_string)
  logger.info("End method remove_specific_pattern")
  return output_string