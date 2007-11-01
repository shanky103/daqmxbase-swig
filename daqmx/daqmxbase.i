// SWIG (http://www.swig.org) definitions for
// National Instruments NI-DAQmx Base
// Ned Konz, November 1 2007
// $Id$

// Will be Ruby module named Daqmxbase
%module  daqmxbase

%include "typemaps.i"
%include "exception.i"

%{
#include "ruby.h"

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32
#include "NIDAQmxBase.h"
%}

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32

%apply  unsigned long *INPUT { TaskHandle };
%apply  unsigned long *OUTPUT { TaskHandle * };
%apply  unsigned long *OUTPUT { bool32 * };
%apply  unsigned long *OUTPUT { int32 * };
%apply  char *OUTPUT { char errorString[] };
%apply  float *OUTPUT { float64 readArray[] };
%apply  float *OUTPUT { float64 *value };
%apply  unsigned long *OUTPUT { uint32 *value };
%apply  short *OUTPUT { int16 readArray[] };
%apply  long *OUTPUT { int32 readArray[] };
%apply  unsigned char *OUTPUT { uint8 readArray[] };
%apply  unsigned long *OUTPUT { uint32 readArray[] };

// TODO: handle error codes using exceptions
// %exception
//   or
// %typemap(out) int32 {
//     $result = ;
// }

%include "NIDAQmxBase.h"

%include "daqmxbase_decls.i"

//  vim: filetype=swig
