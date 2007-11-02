// SWIG (http://www.swig.org) definitions for
// National Instruments NI-DAQmx Base
// Ned Konz, November 1 2007
// $Id$

// Will be Ruby module named Daqmxbase
%module  daqmxbase

%include "typemaps.i"
%include "exception.i"
%include "carrays.i"
%include "cdata.i"

%{
#include <string.h>
#include <stdlib.h>
#include "ruby.h"

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32
#include "NIDAQmxBase.h"

static VALUE dmxError = rb_define_class("DAQmxBaseError", rb_eRuntimeError);
static VALUE dmxWarning = rb_define_class("DAQmxBaseWarning", rb_eRuntimeError);

int32 handle_DAQmx_error(int32 errCode)
{
  static const char errorSeparator[] = "ERROR : ";
  static const char warningSeparator[] = "WARNING : ";
  static const char *separator;
  size_t errorBufferSize;
  size_t prefixLength;
  char *errorBuffer;

  if (errCode == 0)
    return 0;

  separator = errCode < 0 ? errorSeparator : warningSeparator;
  errorBufferSize = (size_t)DAQmxBaseGetExtendedErrorInfo(NULL, 0);
  prefixLength = strlen(separator);
  errorBuffer = malloc(prefixLength + errorBufferSize);
  strcat(errorBuffer, separator);
  DAQmxBaseGetExtendedErrorInfo(errorBuffer + prefixLength, (uInt32)errorBufferSize);

  if (errCode < 0)
    rb_raise(dmxError, errorBuffer);
  else if (errCode > 0)
    rb_raise(dmxWarning, errorBuffer);

  return errCode;
}

%};

// patch typo in header file
#define  DAQmxReadBinaryI32  DAQmxBaseReadBinaryI32

%apply  unsigned long *OUTPUT { bool32 * };
%apply  unsigned long *OUTPUT { int32 * };
%apply  char *OUTPUT { char errorString[] };
%apply  float *OUTPUT { float64 *value };
%apply  unsigned long *OUTPUT { uInt32 *value };

// ruby size param in: alloc array of given size
%typemap(in) (int16 readArray[], uInt32 arraySizeInSamps) {
  long len;

  if (FIXNUM_P($input))
    len = FIX2LONG($input);
  else
    rb_raise(rb_eTypeError, "readArray size must be FIXNUM");

  if (len <= 0)
    rb_raise(rb_eRangeError, "readArray size must be > 0 (but got %ld)", len);

  temp = calloc((size_t)len, sizeof(int16));
  $1 = temp;
  $2 = (uInt32)len;
};

// free array allocated by above
%typemap(freearg) (int16 readArray[], uInt32 arraySizeInSamps) {
  if ($1) free($1);
};

// make Ruby Array of FIXNUM
%typemap(argout) (int16 readArray[], uInt32 arraySizeInSamps) {
  long i;
  // result is return val from function
  if (result != 0)
  {
    $result = NULL;
    free($1);
    handle_DAQmx_error(result);
    return NULL;
  }
  // create Ruby array of given length
  $result = rb_ary_new2($2);

  // populate it an element at a time.
  for (i = 0; i < (long)$2; i++)
    rb_ary_store($result, i, LONG2FIX($1[i]));

  // $result is what will be passed to Ruby
};

// Note that TaskHandle is typedef'd as uInt32*
// so here &someTask is equivalent to a TaskHandle.
%inline{
  typedef struct Task { uInt32 handle; } Task;
};

// pass string and size to C function
%typemap(in) (char *str, int len) {
  $1 = STR2CSTR($input);
  $2 = (int) RSTRING($input)->len;
};

%extend Task {
  // if you give a non-empty name, you get LoadTask, else CreateTask.
  Task(const char taskName[]) {
    Task *t = (Task *)calloc(1, sizeof(Task));
    int32 result;
    if (&taskName[0] == NULL || taskName[0] == '\0')
      result = DAQmxBaseCreateTask(taskName, (TaskHandle *)&t);
    else
      result = DAQmxBaseLoadTask(taskName, (TaskHandle *)&t);
    if (result) handle_DAQmx_error(result);
    return t;
  }
  ~Task() {
    int32 result = DAQmxBaseStopTask((TaskHandle)$self);
    result = DAQmxBaseClearTask((TaskHandle)$self);
    free($self);
  }
};

%include "daqmxbase_decls.i"
%include "NIDAQmxBase.h"

//  vim: filetype=swig ts=2 sw=2 et ai
