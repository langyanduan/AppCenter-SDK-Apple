#import <Foundation/Foundation.h>
#import <OCHamcrestIOS/OCHamcrestIOS.h>
#import <OCMock/OCMock.h>
#import <XCTest/XCTest.h>

#import "AVABinary.h"
#import "AVAErrorLog.h"
#import "AVAException.h"
#import "AVAThread.h"
#import "AvalancheHub+Internal.h"

@interface AVAErrorLogTests : XCTestCase

@end

@implementation AVAErrorLogTests

#pragma mark - Tests

- (void)testSerializingEventToDictionaryWorks {

  // If
  AVAErrorLog *sut = [self errorLog];

  // When
  NSMutableDictionary *actual = [sut serializeToDictionary];

  // Then
  assertThat(actual, notNilValue());
  assertThat(actual[@"id"], equalTo(sut.crashId));
  assertThat(actual[@"process"], equalTo(sut.process));
  assertThat(actual[@"processId"], equalTo(sut.processId));
  assertThat(actual[@"parentProcess"], equalTo(sut.parentProcess));
  assertThat(actual[@"parentProcessId"], equalTo(sut.parentProcessId));
  assertThat(actual[@"crashThread"], equalTo(sut.crashThread));
  assertThat(actual[@"applicationPath"], equalTo(sut.applicationPath));
  assertThat(actual[@"appLaunchTOffset"], equalTo(sut.appLaunchTOffset));
  assertThat(actual[@"exceptionType"], equalTo(sut.exceptionType));
  assertThat(actual[@"exceptionCode"], equalTo(sut.exceptionCode));
  assertThat(actual[@"exceptionAddress"], equalTo(sut.exceptionAddress));
  assertThat(actual[@"exceptionReason"], equalTo(sut.exceptionReason));
  assertThat(actual[@"fatal"], equalTo(sut.fatal));
  assertThat(actual[@"threads"], equalTo(sut.threads));
  assertThat(actual[@"exceptions"], equalTo(sut.exceptions));
  assertThat(actual[@"binaries"], equalTo(sut.binaries));
  assertThat(actual[@"type"], equalTo(@"error"));
  assertThat(actual[@"device"], notNilValue());
  assertThat(actual[@"toffset"], equalTo(sut.toffset));
  assertThat(actual[@"properties"], equalTo(sut.properties));
}

- (void)testNSCodingSerializationAndDeserializationWorks {

  // If
  AVAErrorLog *sut = [self errorLog];

  // When
  NSData *serializedEvent =
      [NSKeyedArchiver archivedDataWithRootObject:sut];
  id actual = [NSKeyedUnarchiver unarchiveObjectWithData:serializedEvent];

  // Then
  assertThat(actual, notNilValue());
  assertThat(actual, instanceOf([AVAErrorLog class]));

  AVAErrorLog *actualError = actual;
  assertThat(actualError.crashId, equalTo(sut.crashId));
  assertThat(actualError.process, equalTo(sut.process));
  assertThat(actualError.processId, equalTo(sut.processId));
  assertThat(actualError.parentProcess, equalTo(sut.parentProcess));
  assertThat(actualError.parentProcessId, equalTo(sut.parentProcessId));
  assertThat(actualError.crashThread, equalTo(sut.crashThread));
  assertThat(actualError.applicationPath, equalTo(sut.applicationPath));
  assertThat(actualError.appLaunchTOffset, equalTo(sut.appLaunchTOffset));
  assertThat(actualError.exceptionType, equalTo(sut.exceptionType));
  assertThat(actualError.exceptionCode, equalTo(sut.exceptionCode));
  assertThat(actualError.exceptionAddress, equalTo(sut.exceptionAddress));
  assertThat(actualError.exceptionReason, equalTo(sut.exceptionReason));
  assertThat(actualError.fatal, equalTo(sut.fatal));
  assertThatInteger(actualError.threads.count, equalToInteger(1));
  assertThatInteger(actualError.exceptions.count, equalToInteger(1));
  assertThat(actualError.type, equalTo(sut.type));
  assertThat(actualError.sid, equalTo(sut.sid));
  assertThat(actualError.device, equalTo(sut.device));
  assertThat(actualError.toffset, equalTo(sut.toffset));
  assertThat(actualError.properties, equalTo(sut.properties));
}

#pragma mark - Helper

- (AVAErrorLog *)errorLog {
  AVAErrorLog *errorLog = [AVAErrorLog new];
  NSString *crashId = @"crashId";
  NSString *process = @"process";
  NSNumber *processId = @(12);
  NSString *parentProcess = @"parentProcess";
  NSNumber *parentProcessId = @(13);
  NSNumber *crashThread = @(4);
  NSString *applicationPath = @"applicationPath";
  NSNumber *appLaunchTOffset = @(134);
  NSString *exceptionType = @"exceptionType";
  NSString *exceptionCode = @"exceptionCode";
  NSString *exceptionAddress = @"exceptionAddress";
  NSString *exceptionReason = @"exceptionReason";
  NSNumber *fatal = @(4);
  NSArray<AVAThread *> *threads = [NSArray arrayWithObject:[AVAThread new]];
  NSArray<AVAException *> *exceptions =
  [NSArray arrayWithObject:[AVAException new]];
  NSArray<AVABinary *> *binaries = [NSArray arrayWithObject:[AVABinary new]];
  AVADeviceLog *device = [AVADeviceLog new];
  NSString *sessionId = @"1234567890";
  NSNumber *tOffset = @(3);
  NSDictionary *properties = @{ @"Key" : @"Value" };
  
  errorLog.crashId = crashId;
  errorLog.process = process;
  errorLog.processId = processId;
  errorLog.parentProcess = parentProcess;
  errorLog.parentProcessId = parentProcessId;
  errorLog.crashThread = crashThread;
  errorLog.applicationPath = applicationPath;
  errorLog.appLaunchTOffset = appLaunchTOffset;
  errorLog.exceptionType = exceptionType;
  errorLog.exceptionCode = exceptionCode;
  errorLog.exceptionAddress = exceptionAddress;
  errorLog.exceptionReason = exceptionReason;
  errorLog.fatal = fatal;
  errorLog.threads = threads;
  errorLog.exceptions = exceptions;
  errorLog.binaries = binaries;
  errorLog.sid = sessionId;
  errorLog.device = device;
  errorLog.toffset = tOffset;
  errorLog.properties = properties;
  
  return errorLog;
}

@end
