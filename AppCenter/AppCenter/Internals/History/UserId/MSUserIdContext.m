#import "MSAppCenterInternal.h"
#import "MSLogger.h"
#import "MSUserIdContextPrivate.h"
#import "MSUtility.h"

/**
 * User Id history key.
 */
static NSString *const kMSUserIdHistoryKey = @"UserIdHistory";

/**
 * Singleton.
 */
static MSUserIdContext *sharedInstance;
static dispatch_once_t onceToken;

@implementation MSUserIdContext

+ (instancetype)sharedInstance {
  dispatch_once(&onceToken, ^{
    if (sharedInstance == nil) {
      sharedInstance = [[MSUserIdContext alloc] init];
    }
  });
  return sharedInstance;
}

- (instancetype)init {
  self = [super init];
  if (self) {
    NSData *data = [MS_USER_DEFAULTS objectForKey:kMSUserIdHistoryKey];
    if (data != nil) {
      _userIdHistory = (NSMutableArray *)[(NSObject *)[NSKeyedUnarchiver unarchiveObjectWithData:data] mutableCopy];
    }
    if (!_userIdHistory) {
      _userIdHistory = [NSMutableArray<MSUserIdHistoryInfo *> new];
    }
    NSUInteger count = [_userIdHistory count];
    MSLogDebug([MSAppCenter logTag], @"%tu userId(s) in the history.", count);
    _currentUserIdInfo = [[MSUserIdHistoryInfo alloc] initWithTimestamp:[NSDate date] andUserId:nil];
    [_userIdHistory addObject:_currentUserIdInfo];
  }
  return self;
}

+ (void)resetSharedInstance {
  onceToken = 0;
  sharedInstance = nil;
}

- (NSString *)userId {
  return [self currentUserIdInfo].userId;
}

- (void)setUserId:(nullable NSString *)userId {
  @synchronized(self) {
    [self.userIdHistory removeLastObject];
    self.currentUserIdInfo.userId = userId;
    self.currentUserIdInfo.timestamp = [NSDate date];
    [self.userIdHistory addObject:self.currentUserIdInfo];
    [MS_USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userIdHistory] forKey:kMSUserIdHistoryKey];
    MSLogVerbose([MSAppCenter logTag], @"Stored new userId:%@ and timestamp: %@.", self.currentUserIdInfo.userId,
                 self.currentUserIdInfo.timestamp);
  }
}

- (nullable NSString *)userIdAt:(NSDate *)date {
  @synchronized(self) {
    for (MSUserIdHistoryInfo *info in [self.userIdHistory reverseObjectEnumerator]) {
      if ([info.timestamp compare:date] == NSOrderedAscending) {
        return info.userId;
      }
    }
    return nil;
  }
}

- (void)clearUserIdHistory {
  @synchronized(self) {
    [self.userIdHistory removeAllObjects];
    [self.userIdHistory addObject:self.currentUserIdInfo];
    [MS_USER_DEFAULTS setObject:[NSKeyedArchiver archivedDataWithRootObject:self.userIdHistory] forKey:kMSUserIdHistoryKey];
    MSLogVerbose([MSAppCenter logTag], @"Cleared old userIds.");
  }
}

@end