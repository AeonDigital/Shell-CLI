#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: shell_cli/flags/00_types.sh
# DESCRIPTION: 
# ==============================================================================

# Global array indexing all primitive, structured, and system types supported 
# by the core engine.
declare -gA CORE_METAFLAG_TYPES=(

  #
  # GROUP 01 : Primitives

  ["string"]="string" 
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
  ["enum"]="enum"
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
