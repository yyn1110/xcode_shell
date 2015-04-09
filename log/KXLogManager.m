//
//  KXLogManager.m
//  ChatClientExample
//
//  Created by kuxing on 14-6-27.
//  Copyright (c) 2014年 zhangpeihao. All rights reserved.
//
#define log_file_name @"log.log"
#define log_http_file_name @"http_log.log"

#define log_crash_file_name @"crash.crash"
#define log_temp_crash_file_name @"crash.temp"
#define log_switch @"kx_log_switch"
#define log_document_name @"log"
#import "KXLogManager.h"
#include <libkern/OSAtomic.h>
#include <execinfo.h>
#include <mach-o/arch.h>
#import <mach-o/dyld.h>
#import <mach-o/loader.h>

const NSString *MyUncaughtExceptionHandlerSignalKey   = @"MyUncaughtExceptionHandlerSignalKey";
const NSString *SingalExceptionHandlerAddressesKey  = @"SingalExceptionHandlerAddressesKey";
const NSString *ExceptionHandlerAddressesKey        = @"ExceptionHandlerAddressesKey";
const int32_t _uncaughtExceptionMaximum = 10;

@interface KXLogManager ()
@property (nonatomic,strong) NSDateFormatter *formatter;
@property (nonatomic,copy,readwrite) NSString *logFilePath;
@property (nonatomic,copy,readwrite) NSString *logHttpFilePath;
@property (nonatomic,copy) NSString *logDocumentPath;
@property (nonatomic,strong) NSFileHandle *fileHandle;
@property (nonatomic,strong) NSFileHandle *httpFileHandle;
@property (nonatomic,strong) NSFileHandle *fileCrashHandle;
@end
@implementation KXLogManager
+(KXLogManager *)shareLogManager
{
	static KXLogManager *sharedInstance = nil;
    static dispatch_once_t onceToken = 0;
    dispatch_once(&onceToken, ^{
        sharedInstance = [[KXLogManager alloc] init];
    });
    return sharedInstance;
}
- (instancetype)init
{
    self = [super init];
    if (self) {
		NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
		NSString *documentsDirectory = [paths objectAtIndex:0];
		NSString *logDocument = [NSString stringWithFormat:@"%@/%@",documentsDirectory,log_document_name];
        self.logDocumentPath = logDocument;
		BOOL isDirectiory = YES;
		if (![[NSFileManager defaultManager] fileExistsAtPath:logDocument isDirectory:&isDirectiory]) {
			[[NSFileManager defaultManager] createDirectoryAtPath:logDocument withIntermediateDirectories:YES attributes:nil error:nil];
		}
		self.logFilePath = [NSString stringWithFormat:@"%@/%@",logDocument,log_file_name];
		
		self.logHttpFilePath = [NSString stringWithFormat:@"%@/%@",logDocument,log_http_file_name];
        _logCrashFilePath = [NSString stringWithFormat:@"%@/%@",logDocument,log_crash_file_name];
		
		
		
		
        self.formatter = [[NSDateFormatter alloc] init];
		[self.formatter setDateStyle:NSDateFormatterMediumStyle];
		[self.formatter setTimeStyle:NSDateFormatterShortStyle];
		[self.formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
    }
    return self;
}
- (void)createFile
{
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.logFilePath]) {
		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
		[self.fileHandle seekToEndOfFile];
		//NSFileHandle
	}else{
		NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		[[NSFileManager defaultManager] createFileAtPath:self.logFilePath contents:data attributes:nil];
		self.fileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logFilePath];
		[self.fileHandle seekToEndOfFile];
	}
	
	
	
}
- (void)createHttpFile
{
	
	
	
	
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.logHttpFilePath]) {
		self.httpFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logHttpFilePath];
		[self.httpFileHandle seekToEndOfFile];
		//NSFileHandle
	}else{
		NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		[[NSFileManager defaultManager] createFileAtPath:self.logHttpFilePath contents:data attributes:nil];
		self.httpFileHandle = [NSFileHandle fileHandleForWritingAtPath:self.logHttpFilePath];
		[self.httpFileHandle seekToEndOfFile];
	}
	
}

- (BOOL)hasLogFile
{
	return [[NSFileManager defaultManager] fileExistsAtPath:self.logFilePath ];
}
- (BOOL)hasHttpLogFile
{
	return [[NSFileManager defaultManager] fileExistsAtPath:self.logHttpFilePath ];
}
-(void)logSwitch:(BOOL)isCanLog
{
	_isCanLog = isCanLog;
	[[NSUserDefaults standardUserDefaults] setBool:isCanLog forKey:log_switch];
	[[NSUserDefaults standardUserDefaults]  synchronize];
	
}

- (void)writeDebugLog:(NSString *)logStr
{
	if (logStr && logStr.length >0) {
		[self createFile];
		NSDate *date = [NSDate date];
		NSString *timeFormat = [self.formatter stringFromDate:date];
		NSString *text = [NSString stringWithFormat:@"%@\t[DEBUG]\n%@\n",timeFormat,logStr];
		NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
		[self.fileHandle writeData:data];
		[self.fileHandle synchronizeFile];
	
	}
	
}
- (void)writeErrorLog:(NSString *)logStr
{
	if (logStr && logStr.length >0) {
	[self createFile];
	NSDate *date = [NSDate date];
	NSString *timeFormat = [self.formatter stringFromDate:date];
	NSString *text = [NSString stringWithFormat:@"%@\t[ERROR]\n%@\n",timeFormat,logStr];
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	[self.fileHandle writeData:data];
	[self.fileHandle synchronizeFile];
	}

}
- (void)writeNormalLog:(NSString *)logStr
{
	if (logStr && logStr.length >0) {
	[self createFile];
	NSDate *date = [NSDate date];
	NSString *timeFormat = [self.formatter stringFromDate:date];
	NSString *text = [NSString stringWithFormat:@"%@\t[NORMAL]\n%@\n",timeFormat,logStr];
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
	[self.fileHandle writeData:data];
	[self.fileHandle synchronizeFile];
	}

}
- (void)writeHttpLog:(NSString *)logStr
{
	if (logStr && logStr.length >0) {
		[self createHttpFile];
		NSDate *date = [NSDate date];
		NSString *timeFormat = [self.formatter stringFromDate:date];
		NSString *text = [NSString stringWithFormat:@"%@\t[HTTP]\n%@\n",timeFormat,logStr];
		NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
		[self.httpFileHandle writeData:data];
		[self.httpFileHandle synchronizeFile];
	}

}
- (NSString *)moveFile
{
	NSString *temFilePath = [NSString stringWithFormat:@"%@.tmp",self.logFilePath];
	NSError *error = nil;
	[[NSFileManager defaultManager] moveItemAtPath:self.logFilePath toPath:temFilePath error:&error];
	if (error) {
		NSLog(@"move file error %@",[error description]);
		
	}
	return temFilePath;
}
- (BOOL)removeLogFile
{
	NSString *temFilePath = [NSString stringWithFormat:@"%@",self.logFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:temFilePath]) {
		return 	[[NSFileManager defaultManager] removeItemAtPath:temFilePath error:nil];
	}
	return NO;
}
- (BOOL)removeTempLogFile
{
	NSString *temFilePath = [NSString stringWithFormat:@"%@.tmp",self.logFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:temFilePath]) {
	return 	[[NSFileManager defaultManager] removeItemAtPath:temFilePath error:nil];
	}
	return NO;
}
- (BOOL)removeHTTPLogFile
{
	NSString *temFilePath = [NSString stringWithFormat:@"%@",self.logHttpFilePath];
	if ([[NSFileManager defaultManager] fileExistsAtPath:temFilePath]) {
		return 	[[NSFileManager defaultManager] removeItemAtPath:temFilePath error:nil];
	}
	return NO;
}

#pragma mark ------------ Crash日志获取 --------------------

+ (NSFileHandle *)createCrashFile
{
    NSFileHandle *logCreashFile;
    NSArray *paths = NSSearchPathForDirectoriesInDomains(NSDocumentDirectory, NSUserDomainMask, YES);
    NSString *documentsDirectory = [paths objectAtIndex:0];
    NSString *logDocument = [NSString stringWithFormat:@"%@/%@",documentsDirectory,log_document_name];
    NSString *logCrashFilePath = [NSString stringWithFormat:@"%@/%@",logDocument,log_crash_file_name];

	if ([[NSFileManager defaultManager] fileExistsAtPath:logCrashFilePath])
    {
		logCreashFile = [NSFileHandle fileHandleForWritingAtPath:logCrashFilePath];
		[logCreashFile seekToEndOfFile];
	}else
    {
		NSData *data = [@"" dataUsingEncoding:NSUTF8StringEncoding];
		[[NSFileManager defaultManager] createFileAtPath:logCrashFilePath contents:data attributes:nil];
		logCreashFile = [NSFileHandle fileHandleForWritingAtPath:logCrashFilePath];
		[logCreashFile seekToEndOfFile];
	}
    
    return logCreashFile;
}

- (BOOL)existCrashLog
{
    NSLog(@"exist Crash file: %@", [[NSFileManager defaultManager] subpathsAtPath:self.logCrashFilePath]);
    
    if ([[NSFileManager defaultManager] fileExistsAtPath:self.logCrashFilePath])
    {
        return YES;
    }
    
    return NO;
}

- (NSString *)moveCrashFile
{
	NSString *temFilePath = [NSString stringWithFormat:@"%@.temp",self.logCrashFilePath];
	NSError *error = nil;
	[[NSFileManager defaultManager] moveItemAtPath:self.logCrashFilePath toPath:temFilePath error:&error];
    
	if (error)
    {
		NSLog(@"move file error %@",[error description]);
	}
    
	return temFilePath;
}

- (BOOL)removeCrashFile
{
    
	if ([[NSFileManager defaultManager] fileExistsAtPath:self.logCrashFilePath])
    {
        return 	[[NSFileManager defaultManager] removeItemAtPath:self.logCrashFilePath error:nil];
	}
    
	return NO;
}

- (void)removeCrashDocementAllFiles
{
    NSArray *fileNames = [[NSFileManager defaultManager] subpathsAtPath:self.logDocumentPath];
    
    for (int i=0; i<fileNames.count; i++)
    {
        NSString *filePath = [NSString stringWithFormat:@"%@/%@", self.logDocumentPath, fileNames[i]];
        [[NSFileManager defaultManager] removeItemAtPath:filePath error:nil];
    }
}

void signalHandler(int signal)
{
    volatile int32_t _uncaughtExceptionCount = 0;
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    
    
    if (exceptionCount > _uncaughtExceptionMaximum) // 如果太多不用处理
    {
        return;
    }
    
    // 获取信息
    NSMutableDictionary *userInfo = [NSMutableDictionary dictionaryWithObject:[NSNumber numberWithInt:signal] forKey:MyUncaughtExceptionHandlerSignalKey];
    NSArray *callStack = [KXLogManager backtrace];
    [userInfo setObject:callStack forKey:SingalExceptionHandlerAddressesKey];
    
    // 现在就可以保存信息到本地［］
}

void exceptionHandler(NSException *exception)
{
    volatile int32_t _uncaughtExceptionCount = 0;
    // 原子增加 _uncaughtExceptionCount
    int32_t exceptionCount = OSAtomicIncrement32(&_uncaughtExceptionCount);
    
    if (exceptionCount > _uncaughtExceptionMaximum) // 如果太多不用处理
    {
        return;
    }
    
    NSMutableDictionary *userInfo =[NSMutableDictionary dictionaryWithDictionary:[exception userInfo]];
    NSArray *callStack = [KXLogManager backtrace];
    
    [userInfo setObject:callStack forKey:ExceptionHandlerAddressesKey];
    
    //    NSLog(@"exception name              = %@", exception.name);
    //    NSLog(@"exception reason            = %@", exception.reason);
    //    NSLog(@"exception callStackSymbols  = %@", exception.callStackSymbols);
    //    NSLog(@"exception userInfo          = %@", userInfo);
    
    NSDateFormatter *formatter = [[NSDateFormatter alloc] init];
    [formatter setDateStyle:NSDateFormatterMediumStyle];
    [formatter setTimeStyle:NSDateFormatterShortStyle];
    [formatter setDateFormat:@"YYYY-MM-dd HH:mm:ss.SSS"];
    
    NSString *timeString = [formatter stringFromDate:[NSDate date]];
    NSString *text = [NSString stringWithFormat:
                      @"\nTime:            %@\n"
                      "Binary Images:   %@\n"
                      "*** Terminating app due to uncaught exception '%@', reason:'%@'\n"
                      "*** First throw call stack:\n"
                      "%@\n",
                      timeString,
                      printBinaryImages(),
                      exception.name,
                      exception.reason,
                      exception.callStackSymbols];
    
	NSData *data = [text dataUsingEncoding:NSUTF8StringEncoding];
    NSLog(@"%@", text);
    
    NSFileHandle *logCreashFile = [KXLogManager createCrashFile];
	[logCreashFile writeData:data];
	[logCreashFile synchronizeFile];
}


//获取调用堆栈
+ (NSArray *)backtrace
{
    void* callstack[256];
    int frames = backtrace(callstack, 256);
    char **strs = backtrace_symbols(callstack,frames);
    
    NSMutableArray *backtrace = [NSMutableArray arrayWithCapacity:frames];
    
    for (int i=0;i<frames;i++)
    {
        [backtrace addObject:[NSString stringWithUTF8String:strs[i]]];
    }
    
    free(strs);
    
    return backtrace;
}

// 注册崩溃拦截
-(void)installKXCatchCrashHandler
{
    NSSetUncaughtExceptionHandler(&exceptionHandler);
    
    signal(SIGHUP,  signalHandler);
    signal(SIGINT,  signalHandler);
    signal(SIGQUIT, signalHandler);
    signal(SIGABRT, signalHandler);
    signal(SIGILL,  signalHandler);
    signal(SIGSEGV, signalHandler);
    signal(SIGFPE,  signalHandler);
    signal(SIGBUS,  signalHandler);
    signal(SIGPIPE, signalHandler);
    
}

#pragma mark ------------ Build UUID获取 --------------------
NSString *executableUUID(void)
{
    // This now requires the testing of this feature to be done on an actual device, since it returns always empty strings on the simulator
    const struct mach_header *executableHeader = NULL;
    
    for (uint32_t i = 0; i < _dyld_image_count(); i++)
    {
        const struct mach_header *header = _dyld_get_image_header(i);
        
        if (header->filetype == MH_EXECUTE)
        {
            executableHeader = header;
            break;
        }
    }
    
    if (!executableHeader) return @"";
    
    BOOL is64bit = executableHeader->magic == MH_MAGIC_64 || executableHeader->magic == MH_CIGAM_64;
    uintptr_t cursor = (uintptr_t)executableHeader + (is64bit ? sizeof(struct mach_header_64) : sizeof(struct mach_header));
    const struct segment_command *segmentCommand = NULL;
    
    for (uint32_t i = 0; i < executableHeader->ncmds; i++, cursor += segmentCommand->cmdsize)
    {
        segmentCommand = (struct segment_command *)cursor;
        
        if (segmentCommand->cmd == LC_UUID)
        {
            const struct uuid_command *uuidCommand = (const struct uuid_command *)segmentCommand;
            const uint8_t *uuid = uuidCommand->uuid;
            return [[NSString stringWithFormat:@"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
                     uuid[0], uuid[1], uuid[2], uuid[3],
                     uuid[4], uuid[5], uuid[6], uuid[7],
                     uuid[8], uuid[9], uuid[10], uuid[11],
                     uuid[12], uuid[13], uuid[14], uuid[15]]
                    uppercaseString];
        }
    }
    
    return @"";
}

NSString *printImage(const struct mach_header *header)
{
    NSString *infoString = @"";
    uint8_t *header_ptr = (uint8_t*)header;
    typedef struct load_command load_command;
    
    const NXArchInfo *info = NXGetArchInfoFromCpuType(header->cputype, header->cpusubtype);
    
    //Print the architecture ex. armv7
    
    header_ptr += sizeof(struct mach_header);
    load_command *command = (load_command*)header_ptr;
    
    for(int i = 0; i < header->ncmds > 0; ++i)
    {
        if(command->cmd == LC_UUID)
        {
            struct uuid_command ucmd = *(struct uuid_command*)header_ptr;
            
            CFUUIDRef cuuid = CFUUIDCreateFromUUIDBytes(kCFAllocatorDefault, *((CFUUIDBytes*)ucmd.uuid));
            CFStringRef suuid = CFUUIDCreateString(kCFAllocatorDefault, cuuid);
            CFStringEncoding encoding = CFStringGetFastestEncoding(suuid);
            
            //Print UUID
            infoString = [NSString stringWithFormat:@"%s <%s> ",info->name, CFStringGetCStringPtr(suuid, encoding)];
            
            CFRelease(cuuid);
            CFRelease(suuid);
            
            break;
        }
        
        header_ptr += command->cmdsize;
        command = (load_command*)header_ptr;
    }
    
    return infoString;
}

NSString *printBinaryImages()
{
    //Get count of all currently loaded DYLD
    uint32_t count = _dyld_image_count();
	
	if (count == 0) {
		return @"";
	}
    for(uint32_t i = 0; i < count; i++)
    {
        //Name of image (includes full path)
        const char *dyld = _dyld_get_image_name(i);
        
        //Get name of file
        NSInteger slength = strlen(dyld);
        
        int j;
        for(j = slength - 1; j>= 0; --j)
            if(dyld[j] == '/') break;
        
        const struct mach_header *header = _dyld_get_image_header(i);
        
        
        NSLog(@"---%@", [NSString stringWithFormat:@"%s 0x%X - %@%s", strndup(dyld + j+1, slength - j-1), (uint32_t)header, printImage(header), dyld]);
        
        return [NSString stringWithFormat:@"%s 0x%X - %@%s", strndup(dyld + j+1, slength - j-1), (uint32_t)header, printImage(header), dyld];
    }
    return @"";
}


@end
