#import <substrate.h>
#import <Foundation/NSAutoreleasePool.h>
#import <Foundation/NSBundle.h>
#import <Foundation/NSString.h>
#import <CoreFoundation/CFBase.h>
#import <CoreFoundation/CFString.h>
#import <string.h>
#import <Foundation/NSObjCRuntime.h>
#import <CoreLocation/CLLocationManagerDelegate.h>

extern long ptrace(int req, int pid, int addr, int *data);
static long (*old_ptrace)(int req, int pid, int addr, int *data) = NULL;
static long st_ptrace (int req, int pid, int addr, int *data){	
	if (req == 31) {
		NSLog(@"StealthJB> Blocking PT_DENY_ATTACH from PID %d\n",pid);
		return (0);
	} else {
		NSLog(@"StealthJB> ptrace %d %d\n",req, pid);
		return old_ptrace(req,pid,addr,data);
	}
}

void* (*old_fileExistsAtPath)(void* self, SEL _cmd,NSString* path) = NULL;
void* st_fileExistsAtPath(void* self, SEL _cmd, NSString* path){
    NSLog(@"StealthJB> fileExistsAtPath %@", path);

    if ([path hasPrefix:@"/var/mobile/Applications/" ]  ||
        [path hasPrefix:@"/AppleInternal/"]  ||
        [path hasPrefix:@"/System/Library/" ] ||
        [path hasPrefix:@"/private/var/mobile/Applications/"] ||
        [path hasPrefix:@"/var/mobile/Library/Caches/com.apple.keyboards/" ] ){
	return old_fileExistsAtPath(self,_cmd,path);
    }else {
	    NSLog(@"StealthJB> Hiding %@", path);
        return 0;
    }
}


static void* (*old_contentsOfDirectoryAtPath)(void* self, SEL _cmd, NSString* path,  NSError ** error) = NULL;
void* st_contentsOfDirectoryAtPath(void* self, SEL _cmd, NSString* path, NSError ** error){
    NSLog(@"contentsOfDirectoryAtPath %@", path);

    if ([path hasPrefix:@"/var/mobile/Applications/" ]  ||
        [path hasPrefix:@"/AppleInternal/" ] ||
        [path hasPrefix:@"/System/Library/TextInput/" ] ||
        [path hasPrefix:@"/private/var/mobile/Applications/"]){
    }else {
	    NSLog(@"StealthJB> Hiding %@", path);
        return nil;
    }
    return old_contentsOfDirectoryAtPath(self, _cmd, path, error);
}

static int (*old_system)(char *) = NULL;
int st_system(char * cmd){
    if (!cmd){
    NSLog(@"StealthJB> An App is trying to detect the Jailbreak by calling system(%s)...",cmd);
        return 0;
    }
    else{ 
    NSLog(@"StealthJB> An App is calling system(%s)",cmd);
	return old_system(cmd);
    }
}


__attribute__((constructor)) static void initialize() {
    NSLog(@"StealthJBInitialize!");
    
    MSHookFunction(system, st_system, (void**)&old_system);
    NSLog(@"StealthJB> system => %p => %p",old_system,st_system);

    MSHookFunction(ptrace, st_ptrace, (void**)&old_ptrace);
    NSLog(@"StealthJB> ptrace => %p => %p",old_ptrace,st_ptrace);

    MSHookMessageEx([NSFileManager class], @selector(fileExistsAtPath:), (IMP)st_fileExistsAtPath, (IMP *)&old_fileExistsAtPath);
    NSLog(@"StealthJB> fileExistsAtPath => %p => %p",old_fileExistsAtPath,st_fileExistsAtPath);

    MSHookMessageEx([NSFileManager class], @selector(contentsOfDirectoryAtPath:error:), (IMP)st_contentsOfDirectoryAtPath, (IMP *)&old_contentsOfDirectoryAtPath);
    NSLog(@"StealthJB> contentsOfDirectoryAtPath => %p => %p",old_contentsOfDirectoryAtPath,st_contentsOfDirectoryAtPath);
}


