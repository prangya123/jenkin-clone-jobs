import json
import os
import pprint
from collections import OrderedDict


def load_json(json_file):
  validate_file(json_file, "JSON")
  # load the Json file into an object
  try:
    with open(json_file) as json_data:
      json_data = json.load(
          json_data, object_pairs_hook=OrderedDict, strict=None)
      return json_data

  except ValueError as ex:
    em = "Error while loading JSON file [" + json_file + "], Error [" + str(ex)
    raise ex

def validate_file(file_name, file_tag):
  start_message = "Validating file [" + pprint.pformat(file_name) + "]"
  # make sure the File name is provided
  if file_name is None or file_name == '':
    error_msg = file_tag + " file name is missing"
    raise AttributeError(error_msg)

  # make sure the File exists
  if os.path.isfile(file_name) is False:
    error_msg = file_tag + " file [" + file_name + "] do not exist"
    raise AttributeError(error_msg)