#!/bin/sh

  if test -z "$SYNOPSYS_CCSS" ; then
     echo ""
     echo ""
     echo "This script requires that the environment variable SYNOPSYS_CCSS be set"
     exit
  fi

  if test ! -d "$DW_ARM_SC" ; then
     echo ""
     echo "Environment variable DW_ARM_SC is not set. This script requires it to be set."
     echo "This variable should point to the ARM processor installation directory:"
     echo "    <directory_path>/dw_arm_processors_sc"
     echo ""
     exit
  fi


  ##############################
  # Figure out the architecture.
  ##############################
  tmp=`dirname $SYNOPSYS_CCSS`
  SNPS_ARCH=`basename $tmp`; export SNPS_ARCH
  echo ""
  echo "Architecture: $SNPS_ARCH"
  echo ""

  ##############################################################
  # Added to work with the Processor models
  # These all depend on SNPSARMHOME, which should already be set.
  ##############################################################
  echo ""
  echo "Setting up ARM environment variables:"
  ARMDLL=${DW_ARM_SC}/arm_ccm/lib-${SNPS_ARCH}
  echo "    ARMDLL          =  ${DW_ARM_SC}/arm_ccm/lib-${SNPS_ARCH}"

  ARMCONF=${DW_ARM_SC}/arm_ccm/armconfig
  echo "    ARMCONF         =  ${DW_ARM_SC}/arm_ccm/armconfig"

  echo ""
  echo "NOTE: Setting ARMDLL and ARMCONF disables your ability to run"
  echo "      armsd/axd in the stand-alone flat memory model configuration."
  echo "      If you wish to run armsd/axd in stand-alone mode, these "
  echo "      environement variable must point to your ADS tools installation."


  VAR_LIST="$ARMDLL $ARMCONF"
  for VAR in $VAR_LIST
  do
     if test ! -d $VAR ; then
        STAT=1
     fi
  done
  if test $"STAT" = "1" ; then
     echo ""
     echo "WARNING: One of the following environment variables does not point to"
     echo "         a valid directory:  ARMDLL, ARMCONF"
     echo "         Please verify before continuing."
     echo " "
  fi


  ########################
  # Set up SHLIB_PATH
  ########################
  echo ""
  echo "Adding the following to SHLIB_PATH"
  if [ "x$LD_LIBRARY_PATH" = "x" ]; then
    SHLIB_PATH=/usr/dt/lib
    echo "    /usr/dt/lib"
  else
    SHLIB_PATH=/usr/dt/lib:${SHLIB_PATH}
    echo "    /usr/dt/lib "
  fi

  echo $SHLIB_PATH | grep -i "/usr/openwin/lib" > /dev/null
  if [ "$?" != "0" ]; then
    SHLIB_PATH=/usr/openwin/lib:$SHLIB_PATH
    echo "    /usr/openwin/lib"
  fi

  export LD_LIBRARY_PATH
  
 
  ############
  # Setup PATH
  ############
  PATH=$ARMDLL:$PATH
  export PATH
  echo ""
  echo Adding the following to "path":
  echo "    ${ARMDLL}"
    


  if [ ! "`uname -r`" = "5.5.1" ]; then
    # Solaris 5.6 or 5.7 locale problem. These variables must be unset otherwise GUI programs
    # will hang when run.
    LC_CTYPE=""
    LC_NUMERIC=""
    LC_TIME=""
    LC_MONETARY=""
    LC_COLLATE=""
    LC_MESSAGES=""
    LANG=C
    export LANG
  fi

