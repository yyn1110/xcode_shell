//
//  KXLogManager.h
//  ChatClientExample
//
//  Created by kuxing on 14-6-27.
//  Copyright (c) 2014年 zhangpeihao. All rights reserved.
//

#import <Foundation/Foundation.h>

@interface KXLogManager : NSObject

@property (nonatomic,assign,setter = logSwitch:) BOOL isCanLog;
@property (nonatomic,copy,readonly) NSString *logFilePath;
@property (nonatomic,copy,readonly) NSString *logHttpFilePath;
+(KXLogManager *)shareLogManager;
- (BOOL)hasLogFile;
- (void)writeDebugLog:(NSString *)logStr;
- (void)writeErrorLog:(NSString *)logStr;
- (void)writeNormalLog:(NSString *)logStr;
- (BOOL)removeLogFile;

- (NSString *)moveFile;
- (BOOL)removeTempLogFile;



- (BOOL)hasHttpLogFile;
- (void)writeHttpLog:(NSString *)logStr;
- (BOOL)removeHTTPLogFile;

/**
 * 注册Crash拦截
 */
@property (nonatomic,copy,readonly) NSString *logCrashFilePath;

-(void)installKXCatchCrashHandler;

- (NSString *)moveCrashFile;

- (BOOL)removeCrashFile;

- (BOOL)existCrashLog;

- (void)removeCrashDocementAllFiles;

@end
