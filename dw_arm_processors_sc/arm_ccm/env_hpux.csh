  #
  # ADS Environment Settings for csh on Solaris
  #

  if ( $?SYNOPSYS_CCSS == 0 ) then
     echo ""
     echo ""
     echo "This script requires that the environment variable SYNOPSYS_CCSS be set"
     echo ""
  endif

  if ( ! -d ${DW_ARM_SC} ) then
     echo ""
     echo "Environment variable DW_ARM_SC is not set. This script requires it to be set."
     echo "This variable should point to the ARM processor installation directory:"
     echo "    <directory_path>/dw_arm_processors_sc"
     echo ""
     exit
  endif

  #
  # Figure out the architecture.
  #
  setenv SNPS_ARCH `dirname $SYNOPSYS_CCSS`
  setenv SNPS_ARCH `basename $SNPS_ARCH`
  echo ""
  echo "Architecture: $SNPS_ARCH"
  echo ""


  ###################
  # SET ARM VARIABLES
  ###################

  ###############################################################
  # Added to work with the Processor models
  # These all depend on SNPSARMHOME, which should already be set.
  ################################################################
  echo ""
  echo Setting ARM environment variables:
  setenv ARMDLL ${DW_ARM_SC}/arm_ccm/lib-${SNPS_ARCH}
  echo '       ARMDLL          =  ${DW_ARM_SC}/arm_ccm/lib-${SNPS_ARCH}'

  setenv ARMCONF ${DW_ARM_SC}/arm_ccm/armconfig
  echo '       ARMCONF         =  ${DW_ARM_SC}/arm_ccm/armconfig'

  echo ""
  echo ""
  echo "NOTE: Setting ARMDLL and ARMCONF disables your ability to run"
  echo "      armsd/axd in the stand-alone flat memory model configuration."
  echo "      If you wish to run armsd/axd in stand-alone mode, these "
  echo "      environement variable must point to your ADS tools installation."

  if ( ! -d $ARMDLL || ! -d $ARMCONF ) then
     echo ""
     echo "WARNING: One of the following environment variables does not point to"
     echo "         a valid directory:  ARMDLL, ARMCONF"
     echo "         Please verify before continuing."
  endif

  ############################
  #  SET SHLIB_PATH
  ############################
  echo  ""
  echo  "Adding the following to SHLIB_PATH:"
  if ( $?SHLIB_PATH == 0 ) then
    setenv SHLIB_PATH /usr/dt/lib
    echo "       /usr/dt/lib"
  else
    setenv SHLIB_PATH /usr/dt/lib:${SHLIB_PATH}
    echo "       /usr/dt/lib"
  endif

  if ( ${SHLIB_PATH} !~ */usr/openwin/lib* ) then
    setenv SHLIB_PATH /usr/openwin/lib:${SHLIB_PATH}
    echo "       /usr/openwin/lib"
  endif

  ###########
  #Setup path
  ###########
  set path=($ARMDLL $path)
  echo ""
  echo Adding the following to 'path':
  echo '       ${ARMDLL}'

  if (( `uname -r` == '5.6' ) || ( `uname -r` == '5.7' )) then
    # Solaris 5.6 or 5.7 locale problem. These variables must be unset otherwise GUI programs
    # will hang when run.
    unsetenv LC_CTYPE
    unsetenv LC_NUMERIC
    unsetenv LC_TIME
    unsetenv LC_MONETARY
    unsetenv LC_COLLATE
    unsetenv LC_MESSAGES
    setenv LANG C
  endif

