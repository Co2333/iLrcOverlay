#line 1 "/Users/darwin/Projects/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"


#if TARGET_OS_SIMULATOR
#error Do not support the simulator, please use the real iPhone Device.
#endif

#import <UIKit/UIKit.h>

#import "./FontLoader/UIFont+WDCustomLoader.h"
#import "./GCDWebServer/GCDWebServer.h"
#import "./GCDWebServer/GCDWebServerDataResponse.h"

#import "LyricConfig.h"
#import "LyricWindow.h"
#import "LyricController.h"

#define TWEAK_ID "wiki.qaq.DesktopLyricOverlay"
#define DEFAULT_FONT_SIZE 12

static NSString *_session = @"";
static LyricWindow *_lyricWindow = nil;
static LyricController *_lyricController = nil;
static LyricConfig *_lyricConfig = nil;

static void UpdateUserDefaults(void) {
    
    if (_lyricConfig) {
        if ([[NSDate date] timeIntervalSinceReferenceDate] - [[_lyricConfig createdAt] timeIntervalSinceReferenceDate] < 5.0) {
            return;
        }
    }
    
    NSDictionary *confDict = [NSDictionary dictionaryWithContentsOfFile:@"/private/var/mobile/Library/Preferences/" TWEAK_ID ".plist"];
    _lyricConfig = [[LyricConfig alloc] initWithDictionary:confDict];
    
    [_lyricWindow setHidden:!_lyricConfig.isEnabled];
    [_lyricController.lyricLabel setFont:_lyricConfig.font];
    
}


#include <substrate.h>
#if defined(__clang__)
#if __has_feature(objc_arc)
#define _LOGOS_SELF_TYPE_NORMAL __unsafe_unretained
#define _LOGOS_SELF_TYPE_INIT __attribute__((ns_consumed))
#define _LOGOS_SELF_CONST const
#define _LOGOS_RETURN_RETAINED __attribute__((ns_returns_retained))
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif
#else
#define _LOGOS_SELF_TYPE_NORMAL
#define _LOGOS_SELF_TYPE_INIT
#define _LOGOS_SELF_CONST
#define _LOGOS_RETURN_RETAINED
#endif

@class SpringBoard; @class CAWindowServerDisplay; 
static unsigned int (*_logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$)(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST, SEL, CGPoint, NSArray <NSNumber *> *); static unsigned int _logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST, SEL, CGPoint, NSArray <NSNumber *> *); static void (*_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$)(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST, SEL, id); 

#line 41 "/Users/darwin/Projects/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"


static unsigned int _logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(_LOGOS_SELF_TYPE_NORMAL CAWindowServerDisplay* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, CGPoint arg1, NSArray <NSNumber *> * arg2) {
    NSMutableArray <NSNumber *> *mArg2 = [arg2 mutableCopy] ?: [NSMutableArray new];
    id lyricWindowContextId = [NSDictionary dictionaryWithContentsOfFile:@"/tmp/" TWEAK_ID ".plist"][@"LyricContextId"];
    if ([lyricWindowContextId isKindOfClass:[NSNumber class]]) {
        [mArg2 addObject:lyricWindowContextId];
    }
    return _logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$(self, _cmd, arg1, mArg2);
}





static void _logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$(_LOGOS_SELF_TYPE_NORMAL SpringBoard* _LOGOS_SELF_CONST __unused self, SEL __unused _cmd, id arg1) {
    
    _logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$(self, _cmd, arg1);
    
    UpdateUserDefaults();
    
    if ([_lyricConfig isEnabled]) {
        
        _lyricController = [[UIStoryboard storyboardWithName:@"Lyric" bundle:[NSBundle bundleWithPath:@"/System/Library/CoreServices/SpringBoard.app"]] instantiateInitialViewController];
        
        _lyricWindow = [[LyricWindow alloc] initWithFrame:[[UIScreen mainScreen] bounds]];
        [_lyricWindow setBackgroundColor:[UIColor clearColor]];
        [_lyricWindow setWindowLevel:UIWindowLevelStatusBar + 1];
        [_lyricWindow setUserInteractionEnabled:NO];
        [_lyricWindow.layer setMasksToBounds:NO];
        [_lyricWindow setRootViewController:_lyricController];
        [_lyricWindow setHidden:NO];
        [_lyricWindow makeKeyAndVisible];
        [@{
            @"LyricContextId": @([_lyricWindow _contextId])
        } writeToFile:@"/tmp/" TWEAK_ID ".plist" atomically:YES];
        
        GCDWebServer *_s = [[GCDWebServer alloc] init];
        [_s addDefaultHandlerForMethod:@"GET"
                          requestClass:[GCDWebServerRequest class]
                          processBlock:^GCDWebServerResponse * _Nullable(__kindof GCDWebServerRequest * _Nonnull request) {
            
            NSMutableString *base64 = [[[[[request URL] absoluteString] componentsSeparatedByString:@"?"] lastObject] mutableCopy];
            [base64 deleteCharactersInRange:NSMakeRange(0, 6)];
            NSData *decodedData = [[NSData alloc] initWithBase64EncodedString:base64 options:kNilOptions];
            NSString *decodedString = [[NSString alloc] initWithData:decodedData encoding:NSUTF8StringEncoding];
            
            if (!decodedString.length) {
                return [GCDWebServerDataResponse responseWithHTML:@"invalid"];
            }
            
            _session = [[NSUUID UUID] UUIDString];
            __block NSString *cpy = [decodedString mutableCopy];
            __block NSString *currentSession = [_session mutableCopy];
            
            dispatch_async(dispatch_get_main_queue(), ^{
                
                [_lyricController.bannerView setHidden:NO];
                [_lyricController.lyricLabel setText:cpy];
                
                
                if (![cpy containsString:@"TEST DEBUG NO HIDE 0123 测试 😂"]) {
                    dispatch_after(dispatch_time(DISPATCH_TIME_NOW, (int64_t)(8 * NSEC_PER_SEC)), dispatch_get_main_queue(), ^{
                        if ([currentSession isEqual:_session]) {
                            [_lyricController.bannerView setHidden:YES];
                        }
                    });
                }
                
            });
            
            NSString* ret = [[NSString alloc] initWithFormat:@"ok %@", decodedString];
            return [GCDWebServerDataResponse responseWithHTML:ret];
            
        }];
        
        [_s startWithPort:6996 bonjourName:nil];
        
    }
    
}



static __attribute__((constructor)) void _logosLocalInit() {
{Class _logos_class$_ungrouped$CAWindowServerDisplay = objc_getClass("CAWindowServerDisplay"); MSHookMessageEx(_logos_class$_ungrouped$CAWindowServerDisplay, @selector(contextIdAtPosition:excludingContextIds:), (IMP)&_logos_method$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$, (IMP*)&_logos_orig$_ungrouped$CAWindowServerDisplay$contextIdAtPosition$excludingContextIds$);Class _logos_class$_ungrouped$SpringBoard = objc_getClass("SpringBoard"); MSHookMessageEx(_logos_class$_ungrouped$SpringBoard, @selector(applicationDidFinishLaunching:), (IMP)&_logos_method$_ungrouped$SpringBoard$applicationDidFinishLaunching$, (IMP*)&_logos_orig$_ungrouped$SpringBoard$applicationDidFinishLaunching$);} }
#line 125 "/Users/darwin/Projects/iLrcOverlay/SpringBoardInjector/DesktopLyricOverlay/DesktopLyricOverlay/DesktopLyricOverlay.xm"
