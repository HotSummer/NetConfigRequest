//
//  VSDefination.h
//  Weimei
//
//  Created by Evan on 14-2-21.
//  Copyright (c) 2014年 Vip. All rights reserved.
//

#define NSMethodLog(msg) NSLog(@"Line:%d,Func:%s,%@",__LINE__,__func__,msg)

#define ResizableImage(name,top,left,bottom,right) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right)]
#define ResizableImageWithMode(name,top,left,bottom,right,mode) [[UIImage imageNamed:name] resizableImageWithCapInsets:UIEdgeInsetsMake(top,left,bottom,right) resizingMode:mode]
#define ALERT(title,msg,cancel,delegate) [[[UIAlertView alloc] initWithTitle:title message:msg delegate:delegate cancelButtonTitle:cancel otherButtonTitles:nil] show]

//GCD
#define BACK(block) dispatch_async(dispatch_get_global_queue(DISPATCH_QUEUE_PRIORITY_DEFAULT, 0), block)
#define MAIN(block) dispatch_async(dispatch_get_main_queue(),block)

//Device
#define isIOS4 ([[[UIDevice currentDevice] systemVersion] intValue]==4)
#define isIOS5 ([[[UIDevice currentDevice] systemVersion] intValue]==5)
#define isIOS6 ([[[UIDevice currentDevice] systemVersion] intValue]==6)
#define isIOS7 ([[[UIDevice currentDevice] systemVersion] intValue]==7)
#define isIOS8 ([[[UIDevice currentDevice] systemVersion] intValue]==8)

#define isAfterIOS4 ([[[UIDevice currentDevice] systemVersion] intValue]>4)
#define isAfterIOS5 ([[[UIDevice currentDevice] systemVersion] intValue]>5)
#define isAfterIOS6 ([[[UIDevice currentDevice] systemVersion] intValue]>6)
#define isAfterIOS7 ([[[UIDevice currentDevice] systemVersion] intValue]>=7)
#define isAfterIOS8 ([[[UIDevice currentDevice] systemVersion] intValue]>=8)

#define iPhone5 ([UIScreen instancesRespondToSelector:@selector(currentMode)] ? CGSizeEqualToSize(CGSizeMake(640, 1136), [[UIScreen mainScreen] currentMode].size) : NO)
#define isiPadClient UI_USER_INTERFACE_IDIOM() == UIUserInterfaceIdiomPad
#define appDelegate (AppDelegate *)[UIApplication sharedApplication].delegate


#define UIColorFromRGB(rgbValue) [UIColor colorWithRed:((float)((rgbValue & 0xFF0000) >> 16))/255.0 green:((float)((rgbValue & 0xFF00) >> 8))/255.0 blue:((float)(rgbValue & 0xFF))/255.0 alpha:1.0]

#define isSimulator (NSNotFound != [[[UIDevice currentDevice] model] rangeOfString:@"Simulator"].location)

#define VSBuyShareApplication  [UIApplication sharedApplication]

//SINGLETON
#define DECLARE_AS_SINGLETON(interfaceName)               \
+ (interfaceName*)ShareInstance;                        \

#define DEFINE_SINGLETON(interfaceName)                     \
static interfaceName* interfaceName##Instance = nil;             \
+ (interfaceName*)ShareInstance                          \
{                                                          \
static dispatch_once_t onceToken;                           \
dispatch_once(&onceToken, ^{                                \
if (nil == interfaceName##Instance) {                 \
interfaceName##Instance = [[interfaceName alloc] init];        \
}         \
});                \
return interfaceName##Instance;            \
}

//log
#ifdef DEBUG
#define VSLog(...) NSLog(__VA_ARGS__)
#else
#define VSLog(...){};
#endif

//Cagetory Dynamic
/* Example:
 @interface UIView (DHStyleManager)
 @property (nonatomic, copy) NSString* styleName;
 @end
 
 @implementation UIView (DHStyleManager)
 ADD_DYNAMIC_PROPERTY(NSString*,styleName,setStyleName);
 
 @end
 */
#define ADD_DYNAMIC_PROPERTY(PROPERTY_TYPE,PROPERTY_NAME,SETTER_NAME) \
@dynamic PROPERTY_NAME ; \
static char kProperty##PROPERTY_NAME; \
- ( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
return ( PROPERTY_TYPE ) objc_getAssociatedObject(self, &(kProperty##PROPERTY_NAME ) ); \
} \
\
- (void) SETTER_NAME :( PROPERTY_TYPE ) PROPERTY_NAME \
{ \
objc_setAssociatedObject(self, &kProperty##PROPERTY_NAME , PROPERTY_NAME , OBJC_ASSOCIATION_RETAIN); \
} \


#define kSecurityApiId @"kSecurityApiId"
//http://mb.vip.com
#define kImageBaseUrl @"http://mb-admin.vip.vip.com"

#define kUserTestFinished @"kUserTestFinished"
#define kUserTestFailed @"kUserTestFailed"

#define Online

#ifdef Online
#define pushUrl @"http://mp.vipshop.com/apns"
#else
#define pushUrl @"http://192.168.42.189:8080/apns"
#endif

#define PushURL(function) [NSString stringWithFormat:@"%@/%@", pushUrl, function]

#if __IPHONE_OS_VERSION_MIN_REQUIRED >= 70000
#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
boundingRectWithSize:maxSize options:(NSStringDrawingUsesLineFragmentOrigin) \
attributes:@{NSFontAttributeName:font} context:nil].size : CGSizeZero;
#else
#define MULTILINE_TEXTSIZE(text, font, maxSize, mode) [text length] > 0 ? [text \
sizeWithFont:font constrainedToSize:maxSize lineBreakMode:mode] : CGSizeZero;
#endif

//#define BUYDEBUG

#ifdef BUYDEBUG
#define ResourceBundle [NSBundle mainBundle]
#else
#define ResourceBundle [NSBundle bundleWithPath: \
[[NSBundle mainBundle] pathForResource:@"VSNeptune" ofType:@"bundle"]]
#endif

#ifdef BUYDEBUG
#define IMAGEURL(URL)            [NSString stringWithFormat:@"%@", (URL)]
#else
#define IMAGEURL(URL)            [NSString stringWithFormat:@"%@/%@", [[[NSBundle mainBundle] resourcePath] stringByAppendingPathComponent:@"VSNeptune.bundle"], URL]//[NSString stringWithFormat:@"%@/%@", ResourceBundle, (URL)]
#endif























