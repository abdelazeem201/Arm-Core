// ============================================================================
//  Description : Miscellaneous types for the TCM.
//      Project : TCM
//       Author : Gordon Battaile
//         Date : 04/17/2002
//
//  Copyright (c) 2002 by Synopsys, Inc.
// ============================================================================


#ifndef TCM_TYPES_H
#define TCM_TYPES_H

#include "ahb_types.h"
using namespace ahb_namespace;

// ----------------------------------------------------------------------------
//  TYPEDEF : tcm_mem_size_t
//
//  Type for the size specifications for TCM memory
// ----------------------------------------------------------------------------

typedef enum {
  TCM_4KB   = 0,
  TCM_8KB   = 1,
  TCM_16KB  = 2,
  TCM_32KB  = 3,
  TCM_64KB  = 4,
  TCM_128KB = 5,
  TCM_256KB = 6,
  TCM_512KB = 7,
  TCM_1MB   = 8
} tcm_mem_size_t;

struct tcm_request_t 
{
  bool valid;
  bool read;
  ahb_addr_t addr;
  int num_of_bytes;
  unsigned int* data;

  // default constructor
  tcm_request_t()
    : valid              (false)
    , read               (false)
    , addr               (0)
    , num_of_bytes       (0)
    , data               (0)
  {}

};

#endif
