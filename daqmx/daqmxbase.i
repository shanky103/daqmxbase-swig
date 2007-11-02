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

extern  int32 handle_DAQmx_error(int32 errCode);
%}

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32

%apply  unsigned long *OUTPUT { bool32 * };
%apply  unsigned long *OUTPUT { int32 * };
%apply  char *OUTPUT { char errorString[] };
%apply  float *OUTPUT { float64 readArray[] };
%apply  float *OUTPUT { float64 *value };
%apply  unsigned long *OUTPUT { uInt32 *value };
%apply  short *OUTPUT { int16 readArray[] };
%apply  long *OUTPUT { int32 readArray[] };
%apply  unsigned char *OUTPUT { uInt8 readArray[] };
%apply  unsigned long *OUTPUT { uInt32 readArray[] };

%include "daqmxbase_decls.i"
%include "NIDAQmxBase.h"

//  vim: filetype=swig
