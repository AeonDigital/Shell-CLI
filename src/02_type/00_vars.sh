#!/usr/bin/env bash

# ==============================================================================
# SCRIPT: 02_type/00_vars.sh
# DESCRIPTION: 
# ==============================================================================

# Global array indexing all primitive, structured, and system types supported 
# by the core engine. SHELL_CLI_TYPE
declare -gA SHELL_CLI_TYPE=(

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
