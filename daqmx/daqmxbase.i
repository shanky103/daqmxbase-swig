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

// Read
extern int32  DAQmxBaseReadAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, float64 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadBinaryI16(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, int16 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadBinaryI32(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, int32 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadDigitalU8(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, uInt8 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadDigitalU32(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, bool32 fillMode, uInt32 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadDigitalScalarU32(TaskHandle taskHandle, float64 timeout, uInt32 *value, bool32 *reserved);
extern int32  DAQmxBaseReadCounterF64(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, float64 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadCounterU32(TaskHandle taskHandle, int32 numSampsPerChan, float64 timeout, uInt32 readArray[], uInt32 arraySizeInSamps, int32 *sampsPerChanRead, bool32 *reserved);
extern int32  DAQmxBaseReadCounterScalarF64(TaskHandle taskHandle, float64 timeout, float64 *value, bool32 *reserved);
extern int32  DAQmxBaseReadCounterScalarU32(TaskHandle taskHandle, float64 timeout, uInt32 *value, bool32 *reserved);

// Write
extern int32  DAQmxBaseWriteAnalogF64(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, float64 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
extern int32  DAQmxBaseWriteDigitalU8(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, uInt8 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
extern int32  DAQmxBaseWriteDigitalU32(TaskHandle taskHandle, int32 numSampsPerChan, bool32 autoStart, float64 timeout, bool32 dataLayout, uInt32 writeArray[], int32 *sampsPerChanWritten, bool32 *reserved);
extern int32  DAQmxBaseWriteDigitalScalarU32(TaskHandle taskHandle, bool32 autoStart, float64 timeout, uInt32 value, bool32 *reserved);

// Misc stuff
extern int32  DAQmxBaseCfgInputBuffer(TaskHandle taskHandle, uInt32 numSampsPerChan);
extern int32  DAQmxBaseResetDevice(const char deviceName[]);
extern int32  DAQmxBaseGetExtendedErrorInfo(char errorString[], uInt32 bufferSize);
extern int32  DAQmxBaseGetDevSerialNum(const char device[], uInt32 *data);

//  vim: filetype=swig
