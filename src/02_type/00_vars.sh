#!/usr/bin/env bash

# SHELL_CLI_TYPE - Global associative array indexing all primitive, structured, 
# and system types supported by the core engine.
#
# Purpose:
# - Serves as the authoritative registry of all data types that can be assigned 
#   to CLI flags.
# - Provides a closed set of valid type identifiers, ensuring consistency and 
#   preventing unsupported configurations.
# - Used by metaflag property validation 
#   (e.g., 'shell_cli_metaflag_property_validate_type') to confirm that a 
#   developer-defined type exists.
#
# Structure:
# - Associative array where both keys and values are identical strings 
#   representing type names.
# - Organized into logical groups for clarity and potential category-based 
#   rules:
#
#   GROUP 01 : Primitives
#     - string, text, code, bool, int, float
#
#   GROUP 02 : Date and Time
#     - time, date, datetime
#
#   GROUP 03 : Structured
#     - email, array, json, function
#
#   GROUP 04 : System Paths and URLs
#     - path, relativepath
#     - filename, filepath
#     - dirname, dirpath
#     - url, fullurl, relativeurl
#
declare -gA SHELL_CLI_TYPE=(

  #
  # GROUP 01 : Primitives

  ["string"]="string"
  ["text"]="text"
  ["code"]="code"
  ["bool"]="bool"
  ["int"]="int" 
  ["float"]="float" 


  #
  # GROUP 02 : Date and Time

  ["time"]="time" 
  ["date"]="date" 
  ["datetime"]="datetime" 


  #
  # GROUP 03 : Structured

  ["email"]="email" 
  ["array"]="array"
  ["json"]="json"
  ["function"]="function"


  #
  # GROUP 04 : System Paths and URLs

  ["path"]="path" 
  ["relativepath"]="relativepath" 

  ["filename"]="filename" 
  ["filepath"]="filepath" 
  ["dirname"]="dirname" 
  ["dirpath"]="dirpath"

  ["url"]="url" 
  ["fullurl"]="fullurl" 
  ["relativeurl"]="relativeurl"
)
