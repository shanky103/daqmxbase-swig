// SWIG (http://www.swig.org) definitions for
// National Instruments NI-DAQmx Base
// Ned Konz, November 1 2007
// $Id$

// Will be Ruby module named DAQmxBase
%module  dAQmxBase

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
%import  "NIDAQmxBase.h"

%apply  unsigned long *INPUT { TaskHandle };
%apply  unsigned long *OUTPUT { TaskHandle *, bool32 * };

// %typemap(out) int32 {
//     $result = ;
// }

extern int32 DAQmxBaseLoadTask(const char INPUT[], TaskHandle *OUTPUT);
extern int32 DAQmxBaseCreateTask(const char INPUT[], TaskHandle *OUTPUT);
extern int32  DAQmxBaseStartTask(TaskHandle INPUT);
extern int32  DAQmxBaseStopTask(TaskHandle INPUT);
extern int32  DAQmxBaseClearTask(TaskHandle INPUT);
extern int32  DAQmxBaseIsTaskDone(TaskHandle INPUT, bool32 *OUTPUT);

#if 0

// Task Creation
extern int32  DAQmxBaseLoadTask(const char taskName[], TaskHandle *taskHandle);
extern int32  DAQmxBaseCreateTask(const char taskName[], TaskHandle *taskHandle);

// Task State
extern int32  DAQmxBaseStartTask(TaskHandle taskHandle);
extern int32  DAQmxBaseStopTask(TaskHandle taskHandle);
extern int32  DAQmxBaseClearTask(TaskHandle taskHandle);
extern int32  DAQmxBaseIsTaskDone(TaskHandle taskHandle, bool32 *isTaskDone);

// Channel creation
extern int32  DAQmxBaseCreateAIVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], int32 terminalConfig, float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
extern int32  DAQmxBaseCreateAIThrmcplChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, int32 thermocoupleType, int32 cjcSource, float64 cjcVal, const char cjcChannel[]);
extern int32  DAQmxBaseCreateAOVoltageChan(TaskHandle taskHandle, const char physicalChannel[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, const char customScaleName[]);
extern int32  DAQmxBaseCreateDIChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
extern int32  DAQmxBaseCreateDOChan(TaskHandle taskHandle, const char lines[], const char nameToAssignToLines[], int32 lineGrouping);
extern int32  DAQmxBaseCreateCIPeriodChan(TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, int32 edge, int32 measMethod, float64 measTime, uInt32 divisor, const char customScaleName[]);
extern int32  DAQmxBaseCreateCICountEdgesChan(TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], int32 edge, uInt32 initialCount, int32 countDirection);
extern int32  DAQmxBaseCreateCIPulseWidthChan(TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], float64 minVal, float64 maxVal, int32 units, int32 startingEdge, const char customScaleName[]);
extern int32  DAQmxBaseCreateCOPulseChanFreq(TaskHandle taskHandle, const char counter[], const char nameToAssignToChannel[], int32 units, int32 idleState, float64 initialDelay, float64 freq, float64 dutyCycle);

// Configuration
extern int32  DAQmxBaseCfgSampClkTiming(TaskHandle taskHandle, const char source[], float64 rate, int32 activeEdge, int32 sampleMode, uInt64 sampsPerChan);
extern int32  DAQmxBaseCfgImplicitTiming(TaskHandle taskHandle, int32 sampleMode, uInt64 sampsPerChan);
extern int32  DAQmxBaseDisableStartTrig(TaskHandle taskHandle);
extern int32  DAQmxBaseCfgDigEdgeStartTrig(TaskHandle taskHandle, const char triggerSource[], int32 triggerEdge);
extern int32  DAQmxBaseCfgAnlgEdgeStartTrig(TaskHandle taskHandle, const char triggerSource[], int32 triggerSlope, float64 triggerLevel);
extern int32  DAQmxBaseDisableRefTrig(TaskHandle taskHandle);
extern int32  DAQmxBaseCfgDigEdgeRefTrig(TaskHandle taskHandle, const char triggerSource[], int32 triggerEdge, uInt32 pretriggerSamples);
extern int32  DAQmxBaseCfgAnlgEdgeRefTrig(TaskHandle taskHandle, const char triggerSource[], int32 triggerSlope, float64 triggerLevel, uInt32 pretriggerSamples);

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

#endif

//  vim: filetype=swig
