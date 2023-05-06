/****************************************************************************
 *  File        : mem_copy.c
 *
 *  Project     : ISC - ARM
 * 
 *  Author      : Ed Kohler
 *
 *  Description : This program prompts the user for a hexadecimal memory 
 *					file.  This file should contain addresses maked by an
 *					'@' (@0000 for 0x0000) and data.  Each data word should
 *					be 32-bits long and there should be a carraige
 *					return in between words.  
 *
 ****************************************************************************/

#include <stdlib.h>
#include <stdio.h>
#include <string.h>

#include <ws.h>


/* Base address register for PEx's memory port */
#define PEx_MEM				( 0x000 )
#define PEx_RESET_REG       ( 0x800 )
#define PEx_CONTROL_REG     ( 0x900 )
#define PEx_STATUS_REG      ( 0xA00 )

/* LAD bus offsets */
#define CTRL_1_OFFSET       ( 0x0 )
#define CTRL_2_OFFSET       ( 0x1 )
#define CTRL_3_OFFSET       ( 0x3 )
#define DPM_OFFSET          ( 0x100 )
#define STAT_OFFSET         ( 0x0 )

/* Default test settings */
#define DEFAULT_ITERATIONS  ( 1 )
#define PE_DEFAULT_MASK     ( 6 )
#if defined WIN32 || defined _ULTRA_
#define DEFAULT_SLOT       (0)
#else
#define DEFAULT_SLOT       (0xF)
#endif


/* Define offsets for block ram */
#define MAX_DWORDS_PER_TRANSFER ( 0x100 )
#define SHIFT_DPM_OFFSET        ( 20 )
#define SHIFT_WRITE_SEL         ( 20 )


/* User defined error codes */
#define ERROR_MEMORY_COMPARE_FAILED                   (WS_ERR_SECTION_USER_DEFINED_START + 0)
#define ERR_UNKNOWN_SWITCH                            (WS_ERR_SECTION_USER_DEFINED_START + 1)
#define ERR_NOT_ENOUGH_ARGS                           (WS_ERR_SECTION_USER_DEFINED_START + 2)

/* Other Misc definitions */
#define RETURN_PRINT_ERROR( rc ) \
{ printf( "ERROR %u: %s\n", rc, WS_ErrorString( rc ) ); \
  WS_Close( WS_SlotNumber );  return ( rc ); }

#define SLASH         ("/")
#define BITS_IN_DWORD (32)

#define BitTst( o,b )                       (((o) & (1 << (b))) != 0)
#if !defined(WIN32)
#define MAX_PATH (255)
#endif

/****************************************************************************
 *                              Prototypes                                  *
 ****************************************************************************/
WS_RetCode
DisplayPEConfiguration( DWORD WS_SlotNumber );

WS_RetCode
Mem_Copy_Example( float    clk_freq,
		  float    uclk_freq,
                  DWORD    WS_SlotNumber);

WS_RetCode
VerifyData(DWORD    ref[], 
           DWORD    test[],
           DWORD    size, 
           char    *errstr);

WS_RetCode
WriteData( DWORD    WS_SlotNumber, 
           DWORD    PeNum, 
           DWORD    Address, 
           DWORD    Port, 
           DWORD    DataToWrite[], 
           DWORD    NumDWORDSToWrite );


WS_RetCode 
ReadData(  DWORD    WS_SlotNumber, 
           DWORD    PeNum,
           DWORD    Address, 
           DWORD    Port,
           DWORD   *ReadBuffer,
           DWORD    NumDWORDSToRead );

WS_RetCode
ProgramPE( DWORD    WS_SlotNumber, 
           DWORD    PeNum, 
           char*    filename );


/****************************************************************************
 *                              Variables                                   *
 ****************************************************************************/
  char  *XilinxPartType[]=
  {
    "",
    "XC4013XL",
    "XC4020XL",
    "XC4028XL",
    "XC4036XL",
    "XC4044XL",
    "XC4052XL",
    "XC4062XL",
    "XC4085XL",
    "XC4013XLA",
    "XC4020XLA",
    "XC4028XLA",
    "XC4036XLA",
    "XC4044XLA",
    "XC4052XLA",
    "XC4062XLA",
    "XC4085XLA",
    "XC40110XV",
    "XC40150XV",
    "XC40200XV",
    "XC40250XV",
    "XCV50",
    "XCV100",
    "XCV150",
    "XCV200",
    "XCV300",
    "XCV400",
    "XCV600",
    "XCV800",
    "XCV1000"
  };

  char  *XilinxPackageType[]=
  {
    "",
    "HQ240",
    "HQ304",
    "BG432",
    "BG560",
    "BG352",
    "FG256"
  };

  char *DeviceID[]=
  {
      "",
      "PCI",
      "PE",
      "SRAM",
      "PLD",
      "IO FPGA",
      "CPU",
      "FLASH",
      "NONE"
  };

  char *Part_Type_PLD_Devices[]=
  {
      "",
      "XC9536",
      "XC9572XL",
      "XC95144XL",
      "XC9536XL"
  };

  char *Pkg_Type_PLD_Devices[]=
  {
      "",
      "CS48",
      "PQ100",
      "TQ100",
      "VQ64"
  };

  char *Memory_Devices[]=
  {
      "",
      "Cypress CY7C1334",
      "Cypress CY7C1350",
      "GSI GS71108",
      "Alliance AS4LC4M16",
      "Samsung KM736V849T"
  };

  char *WS_BoardType[]=
  {
      "",
      "StarFire",
      "StarFire II",
      "WildStar PCI",
      "WildStar Compact PCI",
      "WildStar VME"
  };



  WS_BASE_BOARD_TYPE
    BaseBoardType;


/****************************************************************************
 *                                   Main                                   *
 ****************************************************************************/
WS_RetCode main( int  argc, char *argv [] )
{
    WS_RetCode
      rc = WS_SUCCESS;

    int
      argi;

    float
      clk_freq = WS_MIN_MCLK_FREQ,
      uclk_freq = WS_MIN_UCLK_FREQ;

    
    DWORD
      WS_SlotNumber = DEFAULT_SLOT;      /* Default Slot number for the Wildstar WS_SlotNumber */
  
  
    const char * help_string = 
      "Usage: mem_copy <list of options>\n"
      "   Options:\n"
      "      -f <frequency>   Set the MClk Freqency ( default = 25MHz)\n"
      "      -u <frequency>   Set the UClk Frequency ( default = 320kHz)\n"
      "      -h               Show this help.\n"
      "      -s <slot ID>     Set the slot number. ( default = F )\n";

    if ( argc < 2 )
    {
      printf ( "%s\n\n", help_string );
      return(ERR_NOT_ENOUGH_ARGS);
    }
    else
    {
      for ( argi = 1; argi < argc; argi++ )
      {
        if ( argv [ argi ][ 0 ] == '-' )
        {
          switch ( toupper( argv [ argi ] [ 1 ]) )
          {
            case 'S':  /* Set the slot number */
              argi++;
              if (argi < argc)
              {  
                WS_SlotNumber = strtoul( argv [ argi ], NULL, 16 );
                printf("Setting Slot Number to %x\n", WS_SlotNumber );
              }
              else
              {
                printf( "  Warning:  Invalid Slot Number!\n");
                return(rc );
                
              }
              if ( (WS_SlotNumber < 0) || ( WS_SlotNumber > WS_MAX_BOARDS ) )
              {
                printf( "  Warning:  Invalid Slot Number!\n");
                return(rc );
              }
              break;
  
  	    case 'F': /* Set the M-clock frequency */
              argi++;
              if (argi < argc)
              {  
                 clk_freq = (float) atof ( argv [ argi ] );
                 printf( "Setting the Mclk to [%2.1f] MHz.\n", clk_freq);
              }
              else
              {
                printf( "Warning:  Invalid Clock Frequency (Max Value is [%2.1f]!\n", WS_MAX_MCLK_FREQ);
                printf( "                                   Min Value is [%2.1f]!\n", WS_MIN_MCLK_FREQ);
                return(rc);
              }
              if ( (clk_freq < WS_MIN_MCLK_FREQ ) || (clk_freq > WS_MAX_MCLK_FREQ  ) )
              {
                printf( "Warning:  Invalid Clock Frequency (Max Value is [%2.1f]!\n", WS_MAX_MCLK_FREQ);
                printf( "                                   Min Value is [%2.1f]!\n", WS_MIN_MCLK_FREQ);
                return(rc);
              }
              break;

            case 'U':  /* Set the U-clock Frequency */
              argi++;
              if (argi < argc)
              {
                 uclk_freq = (float) atof ( argv [ argi ] );
                 printf( "Setting the Uclk to [%2.1f] MHz.\n", uclk_freq);
              }
              else  
              {
                printf( "Warning:  Invalid Clock Frequency (Max Value is [%2.1f]!\n", WS_MAX_UCLK_FREQ);
                printf( "                                   Min Value is [%2.1f]!\n", WS_MIN_UCLK_FREQ);
                return(rc);   
              }
              if ( (uclk_freq < WS_MIN_UCLK_FREQ ) || (uclk_freq > WS_MAX_UCLK_FREQ  ) )
              {
                printf( "Warning:  Invalid Clock Frequency (Max Value is [%2.1f]!\n", WS_MAX_UCLK_FREQ);
                printf( "                                   Min Value is [%2.1f]!\n", WS_MIN_UCLK_FREQ);
                return(rc);
              }
              break;

            case 'H':  /* Print the help message */
              printf ( "%s\n\n", help_string );
              return(WS_SUCCESS);
              break;
  
           default:
              printf ( "  Unknown option: \"%s\"\n", argv [ argi ] );
              printf ( "%s\n\n", help_string );
              return(ERR_UNKNOWN_SWITCH);       
          }
        }  
      }
    }
    rc = Mem_Copy_Example(clk_freq, uclk_freq, WS_SlotNumber);
    return(rc);

}


/****************************************************************************
 * Function:  Mem_Copy_Example
 *
 * Description:   Test the memory functionality of a WILDStar WS_SlotNumber.
 *   
 * Arguments:
 *   clk_freq      frequency with which to program the clock
 *   uclk_freq	   frequency with which to run the ARM clock
 *
 * Returns:
 *   WS_SUCCESS  upon successful completion
 *
 *
 ****************************************************************************/
WS_RetCode
Mem_Copy_Example( float    clk_freq,
		          float	   uclk_freq,
                  DWORD    WS_SlotNumber )
{

  DWORD
	Reset,
        PENumber=1,
        StatusWord,
        *WriteBufferLocalPex,
	*ReadBufferLocalPex,
	reading,
	temp_addr,
	address,
	value,
	host_ARM;

  char
    *PartType,
    *PackageType,
    *error="Data Mismatch",
    line[9],
    FileName[MAX_PATH];

  FILE *memfile;

  int count=0,
	  i=0,
	  foundat=0,
	  total=0;

  WS_PhysicalBoardConfig
    WildstarConfiguration;

  WS_RetCode
    rc=WS_SUCCESS;

 /***************************************************************
  **                                                           **   
  **                 Open the board for testing                **
  **                                                           **
  ***************************************************************/
  rc = WS_Open( WS_SlotNumber, 0 );
  if ( rc != WS_SUCCESS )
  {
    RETURN_PRINT_ERROR(rc);
  }

  if ( rc == WS_SUCCESS )
  {
    /***************************************************************
     **                                                           **   
     **            Display configuration information              **
     **                                                           **
     ***************************************************************/
    rc = DisplayPEConfiguration( WS_SlotNumber );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }

    rc = WS_GetPhysicalConfig( WS_SlotNumber, &WildstarConfiguration );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }

    BaseBoardType = WildstarConfiguration.BaseInfo.BaseBoardType;
    
    /***************************************************************
     **                                                           **   
     **                  Set the MClock Frequency                 **
     **                                                           **
     ***************************************************************/
    rc = WS_MClkSetConfig ( WS_SlotNumber, PROG_OSCILLATOR, clk_freq, 1 );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }

    printf ( "Successfully Set MCLK to [%2.1f] MHz\n", clk_freq );

    /***************************************************************
     **                                                           **
     **                  Set the UClock Frequency                 **
     **                                                           **
     ***************************************************************/

    rc = WS_UClkSetConfig ( WS_SlotNumber, PROG_OSCILLATOR, uclk_freq );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }
  
    printf ( "Successfully set UCLK to [%2.1f] MHz\n", uclk_freq );

    /***************************************************************
     **                                                           **   
     **                         Program PE1                       **
     **                                                           **
     ***************************************************************/
    PartType = XilinxPartType[WildstarConfiguration.BaseInfo.PE_Device[1].dPartType];
    PackageType = XilinxPackageType[WildstarConfiguration.BaseInfo.PE_Device[1].dPackageType];

    sprintf (FileName , "%s%s%s%spex.x86",PartType, SLASH, PackageType, SLASH );

    rc = ProgramPE(WS_SlotNumber, WS_PE1, FileName );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }
    printf ( "Successfully programmed PE1\n\n" );

   /***************************************************************
    **                                                           **   
    **    Start the ARM Test example now that the PEs are all    **
    **                      programmed.                          **
    **                                                           **
    ***************************************************************/
    printf ( "@@@@ Beginning ARM Test @@@@\n\n" );

    printf ( "**** Resetting the PE's ****\n\n" );
    rc = WS_WritePeReg( WS_SlotNumber, WS_PE1, PEx_RESET_REG, 1, &Reset ); 

    /***************************************************************
     **                                                           **
     **                  Set the Display                          **
     **                                                           **
     ***************************************************************/
    /* Currently Can't Update Display Due to Error on Starfire */
    //rc = WS_UpdateDisplay ( WS_SlotNumber, "ARM9" );
    //if ( rc != WS_SUCCESS )
    //{
    //  RETURN_PRINT_ERROR(rc);
    //}

    /***************Connect Host to Memory System*******************/
    host_ARM = 0x00000001;
    rc = WS_WritePeReg( WS_SlotNumber, WS_PE1, PEx_CONTROL_REG, 1, &host_ARM);
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }
    printf( "Host now connected to Memory System.\n" );

    /**************Read in the File*********************************/
    printf ( "Enter the filename of the Hex Memory File \t" );
    scanf("%s", FileName);
    getchar();

    /**************Check to see that filename is valid**************/
    while ((memfile = fopen(FileName, "r")) == NULL)
    {
      printf ("%s is an invalid filename, please try again.\t", FileName);
      scanf("%s", FileName);          
      getchar();
    }

    WriteBufferLocalPex = malloc(sizeof(DWORD)*256);
    ReadBufferLocalPex = malloc(sizeof(DWORD)*256);
    while (fscanf(memfile, "%s", line) != EOF)
    {
      /* Address or 257th DWORD*/
      if ((sscanf(line, "@%x", &address) > 0) || (count == 256))
      {
        if (foundat > 0)
	{
          /* Send the Data over to the Starfire Board */
          printf("Transferring %d DWORDS starting at address 0x%08x\n", count, temp_addr);
          rc = WriteData(WS_SlotNumber, PENumber, temp_addr, PEx_MEM, WriteBufferLocalPex, count );
  	  if ( rc != WS_SUCCESS )
          {
            RETURN_PRINT_ERROR(rc);
          }          

          /* Verify that Data was Written to Memory Properly */
          rc = ReadData( WS_SlotNumber, PENumber, temp_addr, PEx_MEM, ReadBufferLocalPex, count );
          if ( rc != WS_SUCCESS )
          {
            RETURN_PRINT_ERROR(rc);
          }          
          rc = VerifyData(WriteBufferLocalPex, ReadBufferLocalPex, count, error);
          if ( rc != WS_SUCCESS )
          {
            RETURN_PRINT_ERROR(rc);
          }          
	
          /* Increment the Total Number of DWORDS Transferred */	  
	  total += count;
        }
		
        /* Increment the Number of Address found and reset the Count */
        foundat++;
        count = 0;

        /* If this section was enterred because the count exceeded 255
           then, then this line does not contain an address.  The value
           should then be placed into the DWORD Buffer and the count
           incremented. */
        if (sscanf(line, "@%x", &address) == 0)
        {
          temp_addr = temp_addr + 0x100;
          if (sscanf(line, "%x", &value) > 0)
          {
            WriteBufferLocalPex[count] = value;
            count++;
          }
        }
    	else 
          temp_addr = address;
      }	
	
      /* Instruction */
      else if (sscanf(line, "%x", &value) > 0)
      {
        /* If the first Line wasn't an Address, probably want to
           send the data to address 0x0. */
        if (foundat == 0)
        {
          printf("First Line should be an Address!\n");
          printf("Assuming address 0x0.\n");
          temp_addr = 0x0;
          count = 0;
          foundat++;	  
        }

        /* Store the DWORD into a Memory Buffer and Increment Count*/
        WriteBufferLocalPex[count] = value;
        count++;
      }
	  
      /* Invalid */
      else
        printf("Found Invalid line at %d.\n",total+count);

    }

    /* Send the last segment of data to the FPGA's Memory */
    if (count > 0)
    {
      printf("Transferring %d DWORDS starting at address 0x%08x\n", count, temp_addr);
      rc = WriteData(WS_SlotNumber, PENumber, temp_addr, PEx_MEM, WriteBufferLocalPex, count );
      if ( rc != WS_SUCCESS )
      {
        RETURN_PRINT_ERROR(rc);
      } 
         
      /* Verify that Data was Written to Memory Properly */
      rc = ReadData( WS_SlotNumber, PENumber, temp_addr, PEx_MEM, ReadBufferLocalPex, count );
      if ( rc != WS_SUCCESS )
      {
        RETURN_PRINT_ERROR(rc);
      }          
      rc = VerifyData(WriteBufferLocalPex, ReadBufferLocalPex, count, error);
      if ( rc != WS_SUCCESS )
      {
        RETURN_PRINT_ERROR(rc);
      }

      /* Increment the Total Number of DWORDS Transferred */
      total += count;
      count = 0;
    }

    /* The Memory File Has Been Completely Transferred */
    printf ("%i DWORDS sent to memory.\n", total);
    printf ("Memory has now been loaded.\n\n");
    fclose (memfile);

    /* Return Allocated Memory to CPU */
    free (WriteBufferLocalPex);
    free (ReadBufferLocalPex);

    /********Reset the PE to tell the ARM to start*********/
    printf ( "Resetting the PE's \n\n" );
    rc = WS_WritePeReg( WS_SlotNumber, WS_PE1, PEx_RESET_REG, 1, &Reset );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }

    /********Time to WAIT for ARM to run the Program********/
    printf ( "Waiting for Done Signal From ARM .");
    do
    {
      printf (".");
      rc = WS_ReadPeReg ( WS_SlotNumber, WS_PE1, PEx_STATUS_REG, 1, &StatusWord );
    } while ( (StatusWord & 0x1) != 1 );

    /***************Connect Host to Memory System*******************/
    host_ARM = 0x00000001;
    rc = WS_WritePeReg( WS_SlotNumber, WS_PE1, PEx_CONTROL_REG, 1, &host_ARM);
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }
    printf( "\n\nHost now connected to Memory System.\n" );

    /********Read back Memory Contents to get Results*******/
    printf("\nEnter the Number (dec) of DWORDS to display (0 to quit)...\t");
    scanf("%u", &temp_addr);
    while (temp_addr > 0)
      {
        printf("Enter the Address (hex) of data to display...\t");
	scanf("%x", &address);
        ReadBufferLocalPex = malloc(temp_addr*sizeof(DWORD));
        rc = ReadData( WS_SlotNumber, PENumber, address, PEx_MEM, ReadBufferLocalPex, temp_addr );
        for (reading=0; reading < temp_addr; reading++)
	  {
	    printf("Address = %08x\tValue = %08x\n", address+reading, ReadBufferLocalPex[reading]);
	  }
        free (ReadBufferLocalPex);
	printf("\nEnter the Number (dec) of DWORDS to display (0 to quit)...\t");
	scanf("%u", &temp_addr);
      }
	
   /***************************************************************
    **                                                           **   
    **             Program PE1 with a safe image                 **
    **                                                           **
    ***************************************************************/
    PartType = XilinxPartType[WildstarConfiguration.BaseInfo.PE_Device[1].dPartType];
    PackageType = XilinxPackageType[WildstarConfiguration.BaseInfo.PE_Device[1].dPackageType];

    sprintf (FileName , "%s%s%s%ssafe.x86",PartType, SLASH, PackageType, SLASH );

    rc = ProgramPE(WS_SlotNumber, WS_PE1, FileName );
    if ( rc != WS_SUCCESS )
    {
      RETURN_PRINT_ERROR(rc);
    }
    printf ( "Successfully programmed PE1 with a safe image.\n\n" );

    if ( rc == WS_SUCCESS)
    {
      printf ( "\t\t** SUCCESSFUL**\n");
    }

    /* Close the WS_SlotNumber */
    rc = WS_Close( WS_SlotNumber );

    return ( (int) rc);
  }
  return ( (int) rc);
}/*end main()*/



/********************** Exported Function ************************************
 * Function:	  VerifyData
 * 
 * Returns:		  DWORD -  return code
 * Description:   Compares two buffers and returns any errors.  The maximum
 *                number of errors returned is MAX_ERR_COUNT.
 *****************************************************************************/

WS_RetCode
VerifyData(DWORD ref[], DWORD test[], DWORD size, char *errstr)
{
#define MAX_ERR_COUNT 16

  DWORD
    memCntr,
    errCount;

  WS_RetCode
    rc = WS_SUCCESS;

  errCount=0;

  /*  Loop counts off in DWORDS.
   *  Mismatches will stop being counted after MAX_ERR_COUNT errors.
   *  Note: compares ref data with test data
   */
  for ( memCntr=0; (memCntr < size) && (errCount < MAX_ERR_COUNT); memCntr++)
  {
    if (ref[memCntr] != test[memCntr])
    {
      rc=ERROR_MEMORY_COMPARE_FAILED;
      if (errCount==0)
      {
        printf("ERROR: %s\n", errstr);
        printf("\t Failure offset:\tDWORD:\tExpected Data:\tActual Data:\n");
      }
      printf("\t 0x%08lx\t\t%i\t0x%08x\t0x%08x\t", memCntr*sizeof(DWORD), memCntr, 
                                  ref[memCntr], test[memCntr]);
      printf("\n");
      
	  errCount++;
    }
  }

  if ( (errCount!=0) && (errCount<MAX_ERR_COUNT))
  {
    printf("Number of memory errors found: %d.\n\n", errCount);
  }
  else if (errCount!=0)
  {
    printf("Memory comparison stopped after %d errors.\n\n", MAX_ERR_COUNT);
  }
  return(rc);
}

/******************************* Function ************************************
 * Function:	  WriteData
 * 
 * Returns:		  DWORD -  return code
 * Description:   Write data to memory
 *****************************************************************************/

WS_RetCode
WriteData(DWORD WS_SlotNumber, 
          DWORD PeNum, 
          DWORD Address, 
          DWORD Port, 
          DWORD DataToWrite[], 
          DWORD NumDWORDSToWrite )
{

  DWORD
    StatusWord,
    memCntr = 0,
    dDpmOffset,
    dMemAddress,
    dNumDwords,
    dWriteSel,
    dControlReg1,
    dControlReg2,
    dControlReg3;



  WS_RetCode
    rc = WS_SUCCESS;

	dControlReg3 = 1;

  /* Set initial values of the control register 2 */
  dNumDwords = MAX_DWORDS_PER_TRANSFER;
  dWriteSel = 0;
  dControlReg2 = (dWriteSel << SHIFT_WRITE_SEL) | dNumDwords;


  /* if the number of dwords to write is greater than 256 */
  if ( NumDWORDSToWrite > MAX_DWORDS_PER_TRANSFER )
  {
    do
    {
      /* Set up control register */
      dMemAddress = Address + memCntr;
      dDpmOffset = 0;
      dControlReg1 = (dDpmOffset << SHIFT_DPM_OFFSET) | dMemAddress;


      /* Write data to DPM */
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + DPM_OFFSET, MAX_DWORDS_PER_TRANSFER, &DataToWrite[memCntr] );
      memCntr = memCntr + MAX_DWORDS_PER_TRANSFER;

      /* Write to the Control Registers */
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_1_OFFSET, 1, &dControlReg1 );
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_2_OFFSET, 1, &dControlReg2 );
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_3_OFFSET, 1, &dControlReg3 );


      /* Check to see all data was transferred */
      do
      {
        rc = WS_ReadPeReg ( WS_SlotNumber, PeNum, Port + STAT_OFFSET, 1, &StatusWord );
      } while ( (StatusWord & 0x1) != 1 );

    }while (( ( NumDWORDSToWrite - memCntr ) >= MAX_DWORDS_PER_TRANSFER ) && ( rc == WS_SUCCESS ));

  } 
  
  /* if the number of dwords to write is less than or equal to 256 */
  if (( rc == WS_SUCCESS ) && (( NumDWORDSToWrite - memCntr ) != 0 ))
  {
    /* Write to DPM */
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + DPM_OFFSET, ( NumDWORDSToWrite - memCntr ), &DataToWrite[memCntr] );
    
    /* Update up control register 1 */
    dMemAddress = Address + memCntr;
    dDpmOffset = 0;
    dControlReg1 = (dDpmOffset << SHIFT_DPM_OFFSET) | dMemAddress;
    
    /* Update up control register 2 */
    dNumDwords = NumDWORDSToWrite - memCntr;
    dControlReg2 = (dWriteSel << SHIFT_WRITE_SEL) | dNumDwords;

    
    /* Write to the Control Registers */
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_1_OFFSET, 1, &dControlReg1 );
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_2_OFFSET, 1, &dControlReg2 );
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_3_OFFSET, 1, &dControlReg3 );

    /* Check to see all data was transferred */
    do
    {
        rc = WS_ReadPeReg ( WS_SlotNumber, PeNum, Port + STAT_OFFSET, 1, &StatusWord );
    } while ( (StatusWord & 0x1) != 1 );
  }

  return ( rc );

}


/******************************* Function ************************************
 * Function:	  ReadData
 * 	
 * Returns:		  DWORD -  return code
 * Description:   Read data from memory
 *****************************************************************************/

WS_RetCode
ReadData(DWORD WS_SlotNumber, DWORD PeNum, DWORD Address, DWORD Port, DWORD *ReadBuffer, DWORD NumDWORDSToRead )
{

  DWORD
    StatusWord,
    memCntr = 0,
    dDpmOffset,
    dMemAddress,
    dNumDwords,
    dWriteSel,
    dControlReg1,
    dControlReg2,
    dControlReg3;

  WS_RetCode
    rc = WS_SUCCESS;

  /* Set initial values of the control register D */
  dNumDwords = MAX_DWORDS_PER_TRANSFER;
  dWriteSel = 1;
  dControlReg2 = (dWriteSel << SHIFT_WRITE_SEL) | dNumDwords;



  /* if the number of dwords to read is greater than MAX_DWORDS_PER_TRANSFER */
  if ( NumDWORDSToRead > MAX_DWORDS_PER_TRANSFER )
  {
    do
    {

      /* Set up control register */
      dMemAddress = Address + memCntr;
      dDpmOffset = 0;
      dControlReg1 = (dDpmOffset << SHIFT_DPM_OFFSET) | dMemAddress;

      /* Write to the Control Registers */
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_1_OFFSET, 1, &dControlReg1 );
      rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_2_OFFSET, 1, &dControlReg2 );
	  rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_3_OFFSET, 1, &dControlReg3 );

      /* Check to see all data was transferred */
      do
      {
        rc = WS_ReadPeReg ( WS_SlotNumber, PeNum, Port + STAT_OFFSET, 1, &StatusWord );
      }while ( (StatusWord & 0x1) != 1 );


      /* Read data from memory */
      rc = WS_ReadPeReg( WS_SlotNumber, PeNum, Port + DPM_OFFSET, MAX_DWORDS_PER_TRANSFER, &ReadBuffer[memCntr] );
      memCntr = memCntr + MAX_DWORDS_PER_TRANSFER;

		}while (( ( NumDWORDSToRead - memCntr ) >= MAX_DWORDS_PER_TRANSFER ) && ( rc == WS_SUCCESS ));

  } 
  
  /* if the number of dwords to write is less than or equal to MAX_DWORDS_PER_TRANSFER */
  if (( rc == WS_SUCCESS ) && (( NumDWORDSToRead - memCntr ) != 0 ))
  {

    /* Update up control register A */
    dMemAddress = Address + memCntr;
    dDpmOffset = 0;
    dControlReg1 = (dDpmOffset << SHIFT_DPM_OFFSET) | dMemAddress;
    
    /* Update up control register D */
    dNumDwords = NumDWORDSToRead - memCntr;
    dControlReg2 = (dWriteSel << SHIFT_WRITE_SEL) | dNumDwords;
    
    /* Write to the Control Registers */
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_1_OFFSET, 1, &dControlReg1 );
    rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_2_OFFSET, 1, &dControlReg2 );
		rc = WS_WritePeReg( WS_SlotNumber, PeNum, Port + CTRL_3_OFFSET, 1, &dControlReg3 );

    /* Check to see all data was transferred */
    do
    {
        rc = WS_ReadPeReg ( WS_SlotNumber, PeNum, Port + STAT_OFFSET, 1, &StatusWord );
    }while ( (StatusWord & 0x1) != 1 );

    /* Read data from memory */
    rc = WS_ReadPeReg( WS_SlotNumber, PeNum, Port + DPM_OFFSET, ( NumDWORDSToRead - memCntr ), &ReadBuffer[memCntr] );

  }

  return ( rc );

}


/********************** Exported Function ************************************
 * Function:	  ProgramPE
 * 	
 * Returns:		  DWORD -  return code
 * Description:   programs PE from given filename
 *****************************************************************************/

WS_RetCode
ProgramPE( DWORD WS_SlotNumber, DWORD PeNum, char * filename)
{

#define WS_MAX_PGM_DWORDS  ( 400000 )

  FILE* 
    pInFile;

  DWORD
   *progBuffer,
    numDwordsRead;

  WS_RetCode
    rc = WS_SUCCESS;



  if ( (pInFile = fopen(filename,"rb")) != NULL )
  {
    progBuffer = (DWORD *)malloc( WS_MAX_PGM_DWORDS * sizeof(DWORD) );
    if( progBuffer != NULL )
    {
      numDwordsRead = fread( progBuffer,
                             sizeof(DWORD),
                             WS_MAX_PGM_DWORDS,
                             pInFile );

      rc = WS_ProgramPe( WS_SlotNumber,
                         PeNum,
                         progBuffer,
                         numDwordsRead,
                         NULL );
      free(progBuffer);
    }
    else
    {
      printf("Memory allocation error\n");
      rc = -1;
    }
    fclose( pInFile );
  }
  else
  {
    printf ( "Unable to open file '%s'\n", filename );
    rc = -1;
  }

  return(rc);
}



/******************************* Function ************************************
 * Function:	  DisplayPEConfiguration
 * Parameters:	
 * Returns:		  DWORD -  return code 
 * Description:   Displays configurations information about the WildStar Board
 *****************************************************************************/

WS_RetCode
DisplayPEConfiguration( DWORD WS_SlotNumber)
{

  WS_RetCode
    rc =  WS_SUCCESS;

  static WS_PhysicalBoardConfig
    WildstarConfiguration;

  static WS_Version
    WildstarVersion;

 /***************************************************************
  **                                                           **   
  **  Get and Display version information about the            **
  **                   Wildstar board                          **
  **                                                           **
  ***************************************************************/
  rc = WS_GetVersions( WS_SlotNumber, &WildstarVersion );

  printf ("\n\n******** Wildstar Version Information ********\n\n");


  printf ( "API Version:            %01x.%02x.%02x\n", ((WildstarVersion.dAPI >> 16 ) & 0xFF),
           ((WildstarVersion.dAPI >> 8 ) & 0xFF), WildstarVersion.dAPI & 0xFF);

  printf ( "PCI Version:            %01x.%02x.%02x\n", ((WildstarVersion.dPCI >> 16 ) & 0xFF),
           ((WildstarVersion.dPCI >> 8 ) & 0xFF), WildstarVersion.dPCI & 0xFF);

  printf ( "Flash PLD Version:      %01x.%02x.%02x\n", ((WildstarVersion.dFlash_PLD >> 16 ) & 0xFF),
           ((WildstarVersion.dFlash_PLD >> 8 ) & 0xFF), WildstarVersion.dFlash_PLD & 0xFF);

  printf ( "CrossBar0 PLD Version:  %01x.%02x.%02x\n", ((WildstarVersion.dCrossBar0_PLD >> 16 ) & 0xFF),
           ((WildstarVersion.dCrossBar0_PLD >> 8 ) & 0xFF), WildstarVersion.dCrossBar0_PLD & 0xFF);

  printf ( "CrossBar1 PLD Version:  %01x.%02x.%02x\n\n", ((WildstarVersion.dCrossBar1_PLD >> 16 ) & 0xFF),
           ((WildstarVersion.dCrossBar1_PLD >> 8 ) & 0xFF), WildstarVersion.dCrossBar1_PLD & 0xFF);



 /***************************************************************
  **                                                           **   
  **    Get and Display Configuration information about the    **
  **                   Wildstar board                          **
  **                                                           **
  ***************************************************************/
  rc = WS_GetPhysicalConfig( WS_SlotNumber, &WildstarConfiguration );


  /* If there is configuration information display it otherwise don't */
  if ( rc == WS_SUCCESS )
  {
    printf ( "******** BaseBoard Information ********\n\n");

    /* BaseBoard information */
    printf ( "%s\n", WildstarConfiguration.BaseInfo.cDescription );
    if ( WildstarConfiguration.BaseInfo.BaseBoardType <= sizeof(WS_BoardType)/sizeof(char *) )
    {
      printf ( "\tBaseBoard Type:    %s\n", WS_BoardType[WildstarConfiguration.BaseInfo.BaseBoardType] );
    }
    printf ( "\tSerial Number      1000%u\n\n", WildstarConfiguration.BaseInfo.dSerialNumber );

    /* PCI Information */
    if ( WildstarConfiguration.BaseInfo.PCI_Device.dDeviceId == WS_PCI_DEVICE_ID )
    {
      printf ( "%s\n",  WildstarConfiguration.BaseInfo.PCI_Device.cDescription );
      if ( WildstarConfiguration.BaseInfo.PCI_Device.dPartType <= sizeof(XilinxPartType)/sizeof(char *) )
      {
        printf ( "\tPart Type:     %s\n", XilinxPartType[WildstarConfiguration.BaseInfo.PCI_Device.dPartType] );
      }
      if ( WildstarConfiguration.BaseInfo.PCI_Device.dPackageType <= sizeof(XilinxPackageType)/sizeof(char *) )
      {
        printf ( "\tPackage Type:  %s\n", XilinxPackageType[WildstarConfiguration.BaseInfo.PCI_Device.dPackageType] );
      }
      printf ( "\tSpeed Grade:   -%u\n\n", WildstarConfiguration.BaseInfo.PCI_Device.dSpeedGrade );
    }

    /* PE0 Information */
    if ( WildstarConfiguration.BaseInfo.PE_Device[0].dDeviceId == WS_PE_DEVICE_ID )
    {
      printf ( "%s\n", WildstarConfiguration.BaseInfo.PE_Device[0].cDescription );
      if ( WildstarConfiguration.BaseInfo.PE_Device[0].dPartType <= sizeof(XilinxPartType)/sizeof(char *) )
      {
        printf ( "\tPart Type:     %s\n", XilinxPartType[WildstarConfiguration.BaseInfo.PE_Device[0].dPartType] );
      }
      if ( WildstarConfiguration.BaseInfo.PE_Device[0].dPackageType <= sizeof(XilinxPackageType)/sizeof(char *) )
      {
        printf ( "\tPackage Type:  %s\n", XilinxPackageType[WildstarConfiguration.BaseInfo.PE_Device[0].dPackageType] );
      }
      printf ( "\tSpeed Grade:   -%u\n\n", WildstarConfiguration.BaseInfo.PE_Device[0].dSpeedGrade );
    }

    /* PE1 Information */
    if ( WildstarConfiguration.BaseInfo.PE_Device[1].dDeviceId == WS_PE_DEVICE_ID )
    {
      printf ( "%s\n", WildstarConfiguration.BaseInfo.PE_Device[1].cDescription );
      if ( WildstarConfiguration.BaseInfo.PE_Device[1].dPartType <= sizeof(XilinxPartType)/sizeof(char *) )
      {
        printf ( "\tPart Type:     %s\n", XilinxPartType[WildstarConfiguration.BaseInfo.PE_Device[1].dPartType] );
      }
      if ( WildstarConfiguration.BaseInfo.PE_Device[1].dPackageType <= sizeof(XilinxPackageType)/sizeof(char *) )
      {
        printf ( "\tPackage Type:  %s\n", XilinxPackageType[WildstarConfiguration.BaseInfo.PE_Device[1].dPackageType] );
      }
      printf ( "\tSpeed Grade:   -%u\n\n", WildstarConfiguration.BaseInfo.PE_Device[1].dSpeedGrade );
    }

    /* PE2 Information */
    if ( WildstarConfiguration.BaseInfo.PE_Device[2].dDeviceId == WS_PE_DEVICE_ID )
    {
      printf ( "%s\n", WildstarConfiguration.BaseInfo.PE_Device[2].cDescription );
      if ( WildstarConfiguration.BaseInfo.PE_Device[2].dPartType <= sizeof(XilinxPartType)/sizeof(char *) )
      {
        printf ( "\tPart Type:     %s\n", XilinxPartType[WildstarConfiguration.BaseInfo.PE_Device[2].dPartType] );
      }
      if ( WildstarConfiguration.BaseInfo.PE_Device[2].dPackageType <= sizeof(XilinxPackageType)/sizeof(char *) )
      {
        printf ( "\tPackage Type:  %s\n", XilinxPackageType[WildstarConfiguration.BaseInfo.PE_Device[2].dPackageType] );
      }
      printf ( "\tSpeed Grade:   -%u\n\n", WildstarConfiguration.BaseInfo.PE_Device[2].dSpeedGrade );
    }
  }
  else
  {
    printf ("    ** BaseBoard Configuration Information Not Available **\n\n");
    exit(1);
  }

  /* Mezzanine Information */
  if ( WildstarConfiguration.MezzInfo[0].dMezzCardType == WS_MEZZ_CARD_TYPE_MEM )
  {
    printf ( "******** Mezzanine Card[0] Information ********\n\n");
    printf ( "%s\n", WildstarConfiguration.MezzInfo[0].cDescription );
    printf ( "\tMezz. Card Serial Number: [%u]\n\n", WildstarConfiguration.MezzInfo[0].dSerialNumber );

    /* Memory Devices */
    if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dDeviceId == WS_MEMORY_DEVICE_ID )
    {
      printf ("\tMezz Device[0]:  %s\n", WildstarConfiguration.MezzInfo[0].Mezz_Device[0].cDescription );
      if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dDeviceId <= sizeof(DeviceID)/sizeof(char *) )
      {
        printf ("\t\tDescription:   %s\n", DeviceID[WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dDeviceId] );  
      }
      if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dPartType <= sizeof(Memory_Devices)/sizeof(char *) )
      {
        printf ("\t\tPart Type:     %s\n", Memory_Devices[WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dPartType] );
      }
      printf ("\t\tSpeed Grade:   -%u\n", WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dSpeedGrade );
      printf ("\t\tPort Size:     %u DWORDS\n\n", WildstarConfiguration.MezzInfo[0].Mezz_Device[0].dMemorySize );
    }

    /* Crossbar Devices */
    if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dDeviceId == WS_PLD_DEVICE_ID )
    {
      printf ("\tMezz Device[1]: %s\n", WildstarConfiguration.MezzInfo[0].Mezz_Device[1].cDescription );
      if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dDeviceId <= sizeof(DeviceID)/sizeof(char *) )
      {
        printf ("\t\tDescription:  %s\n", DeviceID[WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dDeviceId] );
      }
      if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dPartType <= sizeof(Part_Type_PLD_Devices)/sizeof(char *) )
      {
        printf ("\t\tPart Type:    %s\n", Part_Type_PLD_Devices[WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dPartType] );
      }
      if ( WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dPackageType <= sizeof(Pkg_Type_PLD_Devices)/sizeof(char *) )
      {
        printf ("\t\tPackage Type: %s\n", Pkg_Type_PLD_Devices[WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dPackageType] );
      }
      printf ("\t\tSpeed Grade:  -%u\n\n", WildstarConfiguration.MezzInfo[0].Mezz_Device[1].dSpeedGrade );
    }
  }



  if ( WildstarConfiguration.MezzInfo[1].dMezzCardType == WS_MEZZ_CARD_TYPE_MEM )
  {
    printf ( "******** Mezzanine Card[1] Information ********\n\n");
    printf ( "%s\n", WildstarConfiguration.MezzInfo[1].cDescription );
    printf ( "\tMezz. Card Serial Number: [%u]\n\n", WildstarConfiguration.MezzInfo[1].dSerialNumber );

    /* Memory Devices */
    if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dDeviceId == WS_MEMORY_DEVICE_ID )
    {
      printf ("\tMezz Device[0]:  %s\n", WildstarConfiguration.MezzInfo[1].Mezz_Device[0].cDescription );
      if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dDeviceId <= sizeof(DeviceID)/sizeof(char *) )
      {
        printf ("\t\tDescription:   %s\n", DeviceID[WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dDeviceId] );  
      }
      if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dPartType <= sizeof(Memory_Devices)/sizeof(char *) )
      {
        printf ("\t\tPart Type:     %s\n", Memory_Devices[WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dPartType] );
      }
      printf ("\t\tSpeed Grade:   -%u\n", WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dSpeedGrade );
      printf ("\t\tPort Size:     %u DWORDS\n\n", WildstarConfiguration.MezzInfo[1].Mezz_Device[0].dMemorySize );
    }

    /* Crossbar Devices */
    if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dDeviceId == WS_PLD_DEVICE_ID )
    {
      printf ("\tMezz Device[1]: %s\n", WildstarConfiguration.MezzInfo[1].Mezz_Device[1].cDescription );
      if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dDeviceId <= sizeof(DeviceID)/sizeof(char *) )
      {
        printf ("\t\tDescription:  %s\n", DeviceID[WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dDeviceId] );
      }
      if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dPartType <= sizeof(Part_Type_PLD_Devices)/sizeof(char *) )
      {
        printf ("\t\tPart Type:    %s\n", Part_Type_PLD_Devices[WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dPartType] );
      }
      if ( WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dPackageType <= sizeof(Pkg_Type_PLD_Devices)/sizeof(char *) )
      {
        printf ("\t\tPackage Type: %s\n", Pkg_Type_PLD_Devices[WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dPackageType] );
      }
      printf ("\t\tSpeed Grade:  -%u\n\n", WildstarConfiguration.MezzInfo[1].Mezz_Device[1].dSpeedGrade );
    }
  }

  return(rc);
}

