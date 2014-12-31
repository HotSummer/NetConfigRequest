//
//  BFM.m
//  BFM
//
//  Created by xiangying on 14-8-29.
//  Copyright (c) 2014年 Elephant. All rights reserved.
//

#import "BFMRequest.h"
#import <objc/runtime.h>
#import <objc/message.h>
#import "VSSystemConfig.h"
#import <CommonCrypto/CommonDigest.h>
#import "NSObject+Reflection.h"
#import "VSSessionInterface.h"
#import "VSStartManager.h"
#import "VSClassAndRequest.h"

#define Later_Sign YES
#define NetException @"网络异常"
#define Debug YES

//#define SHOW_Debug @"SHOW_Debug"
@implementation BFMRequest

//随机生成字母
char rands(void)
{
    if(rand()%2)
        return rand()%26+'a';
    else
        return rand()%26+'A';
}

int randi(void){
    return rand()%10000;
}

/**
 *  当编译器遇到属性声明时，它会生成一些可描述的元数据（metadata），将其与相应的类、category和协议关联起来。存在一些函数可以通过名称在类或者协议中查找这些metadata
 *
 *  @param property 一个指向属性描述符的不透明句柄
 *
 *  @return 属性类型
 */
static const char* getPropertyType(objc_property_t property) {
    
    //获取编码后的属性类型, 字符串以T开头，紧接@encode type和逗号，接着以V和变量名结尾。
    //例如：@property char charDefault;  Tc,VcharDefaults  @property(retain)ididRetain;  T@,&,VidRetain @property(copy)NSString *content; T@"NSString"
    //具体@encode type参见https://developer.apple.com/library/mac/documentation/Cocoa/Conceptual/ObjCRuntimeGuide/Articles/ocrtTypeEncodings.html#//apple_ref/doc/uid/TP40008048-CH100-SW1
    const char *attributes = property_getAttributes(property);
    //printf("attributes=%s\n", attributes);
    char buffer[1 + strlen(attributes)];
    strcpy(buffer, attributes);//复制属性的attribute列表
    char *state = buffer, *attribute;
    while ((attribute = strsep(&state, ",")) != NULL) {
        if (attribute[0] == 'T' && attribute[1] != '@') {
            // it's a C primitive type:
            /*
             if you want a list of what will be returned for these primitives, search online for
             "objective-c" "Property Attribute Description Examples"
             apple docs list plenty of examples of what you get for int "i", long "l", unsigned "I", struct, etc.
             */
            NSString *name = [[NSString alloc] initWithBytes:attribute + 1 length:strlen(attribute) - 1 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
        else if (attribute[0] == 'T' && attribute[1] == '@' && strlen(attribute) == 2) {
            // it's an ObjC id type:
            return "id";
        }
        else if (attribute[0] == 'T' && attribute[1] == '@') {
            // it's another ObjC object type:
            NSString *name = [[NSString alloc] initWithBytes:attribute + 3 length:strlen(attribute) - 4 encoding:NSASCIIStringEncoding];
            return (const char *)[name cStringUsingEncoding:NSASCIIStringEncoding];
        }
    }
    return "";
}

//数据类型不匹配
+(void)showErrortype:(NSString*)type value:(id)value path:(NSString*)key{
#ifdef SHOW_Debug
    NSString *err = [NSString stringWithFormat:@"试图将%@设置为%@",NSStringFromClass([value class]),type];
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:key message:err delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
#endif
}

+(void)showException:(NSException*)exception path:(NSString*)key{
#ifdef SHOW_Debug
    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:exception.name message:exception.reason delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
    [alert show];
#endif
}

/**
 *  递归处理NSArray里面数据的反射
 *
 *  @param originData 数组
 *  @param className  数组里面元素的对象名
 *
 *  @return 一个里面元素是已经被映射成对象的数组
 */
+(NSArray *)recursion:(NSArray *)originData className:(NSString *)className{
    NSMutableArray *arrRecursion = [[NSMutableArray alloc] init];
    for (int i=0; i<originData.count; i++) {
        Class theClass = NSClassFromString(className);
        NSObject *object = [[theClass alloc] init];
        if (!object) {
            NSLog(@"124");
        }
        id content = originData[i];
        if ([content isKindOfClass:[NSDictionary class]]) {//数组里面是一个dictionary
            NSDictionary *dic = (NSDictionary *)content;
            [dic enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
                if ([obj isKindOfClass:[NSArray class]] || [obj isKindOfClass:[NSMutableArray class]]) {
                    if ([object respondsToSelector:@selector(classForArrayProperty)]) {
                        NSDictionary *dic = [object classForArrayProperty];
                        NSString *className = dic[key];
                        NSArray *nextLevelRecursion = [BFMRequest recursion:obj className:className];
                        [object setValue:nextLevelRecursion forKey:key];
                    }
                }else{
                    @try {
                        /**
                         根据类型判断
                         */
                        unsigned int propertyCount;
                        objc_property_t *pProperty = class_copyPropertyList([object class], &propertyCount);
                        NSString *type = nil;
                        for (int i = 0; i<propertyCount; i++) {
                            objc_property_t property = pProperty[i];
                            NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                            if ([propertyname isEqualToString:key]) {
                                //匹配的属性
                                type = [NSString stringWithUTF8String:getPropertyType(property)];
                                break;
                            }
                        }
                        if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"]) {
                            [object setValue:[NSNumber numberWithInteger:[obj integerValue]] forKey:key];
                        }else if ([type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
                            [object setValue:[NSNumber numberWithLongLong:[obj longLongValue]] forKey:key];
                            
                        }else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                            [object setValue:[NSNumber numberWithDouble:[obj doubleValue]] forKey:key];
                            
                        }
                        else if ([type isEqualToString:@"B"]){
                            [object setValue:[NSNumber numberWithInteger:[obj boolValue]] forKey:key];
                        }
                    
                        else if([type isEqualToString:@"NSNumber"]){
                            [object setValue:obj forKey:key];
                            
                        }else if ([type isEqualToString:@"NSString"]) {
                            [object setValue:[NSString stringWithFormat:@"%@",obj] forKey:key];
                            
                        }else{//自定义的类
                            if (type != nil) {
                                id objectParam = [BFMRequest contentToClass:obj className:type];
                                
                                [object setValue:objectParam forKey:key];
                            }
                        }
                        
                    }
                    @catch (NSException *exception) {
                        [BFMRequest showException:exception path:key];
                    }
                    @finally {
                        
                    }
                }
            }];
        }else if ([content isKindOfClass:[NSArray class]]){//数组里面是一个array
            if ([object respondsToSelector:@selector(classForArrayProperty)]) {
                NSDictionary *dic = [object classForArrayProperty];
                NSString *className = [dic allValues][0];//class的类里面只有一个array
                NSArray *nextLevelRecursion = [BFMRequest recursion:content className:className];
                NSString *key = [dic allKeys][0];
                [object setValue:nextLevelRecursion forKey:key];
            }
        }else{//其他元素
            
        }
        
        [arrRecursion addObject:object];
    }
    return arrRecursion;
}

+(void)mork:(BaseNetwork *)config{
    [config.resParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        
        NSArray *array = [(NSString*)obj componentsSeparatedByString:@"."];
        id object = [NSClassFromString(array[0]) shareInstance];
        for (int i = 1; i<array.count-1; i++) {
            @try {
                object = [object valueForKey:array[i]];
            }
            @catch (NSException *exception) {
                [BFMRequest showException:exception path:key];
                
            }
            @finally {
                
            }
        }
        
        unsigned int propertyCount;
        objc_property_t *pProperty = class_copyPropertyList([object class], &propertyCount);
        NSString *type = nil;
        for (int i = 0; i<propertyCount; i++) {
            objc_property_t property = pProperty[i];
            NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
            if ([propertyname isEqualToString:[array lastObject]]) {
                //匹配的属性
                type = [NSString stringWithUTF8String:getPropertyType(property)];
                break;
            }
        }
        if (type) {
            
            @try {
                if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"]) {
                    [object setValue:[NSNumber numberWithInteger:randi()] forKey:[array lastObject]];
                }else if ([type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
                    [object setValue:[NSNumber numberWithLongLong:randi()] forKey:[array lastObject]];
                    
                }else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                    [object setValue:[NSNumber numberWithDouble:randi()] forKey:[array lastObject]];
                    
                }
                
                else if([type isEqualToString:@"NSNumber"]){
                    [object setValue:[NSNumber numberWithInt:randi()] forKey:[array lastObject]];
                    
                }else if ([type isEqualToString:@"NSString"]) {
                    int a = rand()%10+4;
                    char mychar[a];
                    for (int i =0; i<a; i++) {
                        mychar[i] = rands();
                    }
                    NSString *string = [NSString stringWithFormat:@"%s",mychar];
                    [object setValue:string forKey:[array lastObject]];
                    
                }else if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSMutableArray"]) {
                    
                    [object setValue:[NSMutableArray array] forKey:[array lastObject]];
                    
                }else {
                    
                    #ifdef SHOW_Debug
                    UIAlertView *alert = [[UIAlertView alloc] initWithTitle:config.url message:@"未知的数据类型" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                    [alert show];
                    #endif

                }
            }
            @catch (NSException *exception) {
                [BFMRequest showException:exception path:key];
            }
            @finally {
                
            }
        }else {
#ifdef SHOW_Debug
            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:[array lastObject] message:@"该属性不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
            [alert show];
#endif
        }
    }];
}

#pragma mark - 能够解析self的请求
/**
 *  发送请求，解析返回的数据，是下述方法的拓展
 *
 *  @param config        该网络请求的配置文件
 *  @param requestObject 请求的对象
 *  @param responseObj   接收返回数据的对象，如果为空则会使用配置文件中的类名+shareInstance的方法获取到该类。否则将返回数据赋值给该对象
 */
+(void)requsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject responseObj:(NSObject *)responseObj :(void (^)(NSInteger code,NSString *msg)) callBack{
    NSMutableDictionary *parmers = [BFMRequest assembleRequestValue:config :callBack request:requestObject];
    
    //先拿默认
    NSString *url = [NSString stringWithFormat:@"%@%@",VSSERVERURL,config.url];

    
    //再拿外部设置
    BOOL isSSL = config.ssl && [config.ssl isEqualToString:@"1"];
    if (isSSL) {
        NSString *configurl = [VSStartManager shareInstance].externParam.sessionUrl;
        if (configurl && ![configurl isEqualToString:@""] ) {
            url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
        }
    }else{
        NSString *configurl = [VSStartManager shareInstance].externParam.serverUrl;
        if (configurl && ![configurl isEqualToString:@""] ) {
            url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
        }
    }
    
    //最后拿开发强制设置
    if ([config.url hasPrefix:@"http://"] || [config.url hasPrefix:@"https://"] ) {
        url = config.url;
    }
    

    

    NSString *method = config.method;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    

    
    //拼接请求的基础数据
    [BFMRequest assembleBaseRequest:parmers];
    
    if (Later_Sign) {
        NSString *userToken = [parmers objectForKey:@"userToken"];
        if (userToken  && [[VSSessionInterface shareInstance] userToken] ){
            NSString *sign = [self sha1SignString:parmers withUserSecrect:[[VSSessionInterface shareInstance] userSecret]];
            NSString *result = [NSString stringWithFormat:@"OAuth apiSign=%@",sign];
            [manager.requestSerializer setValue:result forHTTPHeaderField:@"Authorization"];
        }else{
            NSString *sign = [self sha1SignString:parmers];
            NSString *result = [NSString stringWithFormat:@"OAuth apiSign=%@",sign];
            [manager.requestSerializer setValue:result forHTTPHeaderField:@"Authorization"];
        }
    }
    
    if (Debug) {
        NSLog(@"url:%@ request:%@", url, parmers);
    }
    NSObject *wResponseObject = responseObj;
    AFHTTPRequestOperation *afRequest;
    
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        afRequest = [manager POST:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                [BFMRequest parseData:responseObject config:config :callBack request:wResponseObject];
            }else{
                callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mork
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];//将url和request添加dictionary中
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else if ([[method uppercaseString] isEqualToString:@"PUT"]){
        afRequest = [manager PUT:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                [BFMRequest parseData:responseObject config:config :callBack request:wResponseObject];
            }else{
                callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else{
       afRequest = [manager GET:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (DEBUG) {
               NSLog(@"%@", responseObject);
           }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([responseObject objectForKey:@"code"]) {
                if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                    [BFMRequest parseData:responseObject config:config :callBack request:wResponseObject];
                }else{
                    callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
                }
            }else{
                //支付结构不一样
                [BFMRequest parseData:responseObject config:config :callBack request:wResponseObject];
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == 404) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }
    
    if(isSSL){
        afRequest.shouldUseCredentialStorage = NO;
        [afRequest setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            }
        }];
    }

}

/**
 *  发送请求，解析返回的数据
 *
 *  @param config        该网络请求的配置文件
 *  @param requestObject 请求的对象
 *  @param responseObj   接收返回数据的对象，使用配置文件中的类名+shareInstance的方法获取到该类
 */
+(void)requsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject :(void (^)(NSInteger code,NSString *msg)) callBack{
    NSMutableDictionary *parmers = [BFMRequest assembleRequestValue:config :callBack request:requestObject];
    NSString *url = [NSString stringWithFormat:@"%@%@",VSSERVERURL,config.url];
    
    
    //再拿外部设置
    BOOL isSSL = config.ssl && [config.ssl isEqualToString:@"1"];
    if (isSSL) {
        NSString *configurl = [VSStartManager shareInstance].externParam.sessionUrl;
        if (configurl && ![configurl isEqualToString:@""] ) {
            url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
        }
    }else{
        NSString *configurl = [VSStartManager shareInstance].externParam.serverUrl;
        if (configurl && ![configurl isEqualToString:@""] ) {
            url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
        }
    }
    
    //最后拿开发强制设置
    if ([config.url hasPrefix:@"http://"] || [config.url hasPrefix:@"https://"] ) {
        url = config.url;
    }

    NSString *method = config.method;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", @"text/html",@"image/png", nil];
    
    [BFMRequest assembleBaseRequest:parmers];
    if (Later_Sign) {
        NSString *userToken = [parmers objectForKey:@"userToken"];
        if (userToken && [[VSSessionInterface shareInstance] userToken] ){
            NSString *sign = [self sha1SignString:parmers withUserSecrect:[[VSSessionInterface shareInstance] userSecret]];
            NSString *result = [NSString stringWithFormat:@"OAuth apiSign=%@",sign];
             [manager.requestSerializer setValue:result forHTTPHeaderField:@"Authorization"];
        }else{
            NSString *sign = [self sha1SignString:parmers];
            NSString *result = [NSString stringWithFormat:@"OAuth apiSign=%@",sign];
            [manager.requestSerializer setValue:result forHTTPHeaderField:@"Authorization"];

        }
    }
    
    if (Debug) {
        NSLog(@"url:%@ request:%@", url, parmers);
    }
    
    NSObject *wRequestObject = requestObject;
    AFHTTPRequestOperation *afRequest;
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        afRequest = [manager POST:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
            }else if ( [[responseObject objectForKey:@"code"] intValue] == 10036) {
                NSRange rang = [url rangeOfString:@"user/secure_check"];
                if (rang.location != NSNotFound) {
                    [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
                }
            }
            else{
                callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mork
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else if ([[method uppercaseString] isEqualToString:@"PUT"]){
       afRequest = [manager PUT:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (DEBUG) {
               NSLog(@"%@", responseObject);
           }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
            }else{
                callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else{
       afRequest = [manager GET:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
           if (DEBUG) {
               NSLog(@"%@", responseObject);
           }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            if ([[responseObject objectForKey:@"code"] intValue] == 200) {
                [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
            }else{
                callBack([[responseObject objectForKey:@"code"] intValue],responseObject[@"msg"]);
            }
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == 404) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }
    
    
    if(isSSL){
        afRequest.shouldUseCredentialStorage = NO;
        [afRequest setWillSendRequestForAuthenticationChallengeBlock:^(NSURLConnection *connection, NSURLAuthenticationChallenge *challenge) {
            if ([challenge.protectionSpace.authenticationMethod isEqualToString:NSURLAuthenticationMethodServerTrust]) {
                [challenge.sender useCredential:[NSURLCredential credentialForTrust:challenge.protectionSpace.serverTrust] forAuthenticationChallenge:challenge];
            }
        }];
    }
}

/**
 *  拼接请求的基础数据
 *
 *  @param parmers 用来存储基础数据的dictionary
 */
+ (void)assembleBaseRequest:(NSMutableDictionary *)parmers{
    //api_key
    if (![parmers objectForKey:@"apiKey"] && [[VSSystemConfig shareInstance] apiKey]) {
        [parmers setObject:[[VSSystemConfig shareInstance] apiKey]  forKey:@"apiKey"];
    }
    
    //json
    // [parmers setObject:@"json" forKey:@"format"];
    
    //app_name
    if (![parmers objectForKey:@"appName"] && [[VSSystemConfig shareInstance] serverAppName]) {
        [parmers setObject:[[VSSystemConfig shareInstance] serverAppName]  forKey:@"appName"];
    }
    
    //app_version
    NSString *version = [parmers objectForKey:@"appVersion"];
    if (version && [version isEqualToString:@"1"]) {
        [parmers setObject:[[VSSystemConfig shareInstance] appVersion]  forKey:@"appVersion"];
    }
    [parmers setObject:@"1.0.0"  forKey:@"appVersion"];
    
#warning 测试新的验证后删除
    if (Later_Sign) {
        if (![parmers objectForKey:@"timestamp"]) {
            NSInteger inteval = [[NSDate date] timeIntervalSince1970];
            [parmers setObject:[NSString stringWithFormat:@"%d",inteval] forKey:@"timestamp"];
        }
    }else{
        if (![parmers objectForKey:@"ts"]) {
            NSInteger inteval = [[NSDate date] timeIntervalSince1970];
            [parmers setObject:[NSString stringWithFormat:@"%d",inteval] forKey:@"ts"];
        }
    }
    //warehouse
    NSString *warehouse = [parmers objectForKey:@"warehouse"];
    if (warehouse && [warehouse isEqualToString:@"1"] && [VSStartManager shareInstance].externParam.warehouse.length>0) {
        [parmers setObject:[VSStartManager shareInstance].externParam.warehouse forKey:@"warehouse"];
    }
    
    
    NSString *userId = [parmers objectForKey:@"userId"];
    if (userId && [userId isEqualToString:@"1"] && [[VSSessionInterface shareInstance] userId]) {
        [parmers setObject:[[VSSessionInterface shareInstance] userId] forKey:@"userId"];
    }
    
    
    NSString *userToken = [parmers objectForKey:@"userToken"];
    if (userToken && [userToken isEqualToString:@"1"] && [[VSSessionInterface shareInstance] userToken] ) {
        [parmers setObject:[[VSSessionInterface shareInstance] userToken] forKey:@"userToken"];
        
        if (!Later_Sign) {
            NSString *signStr = [self signString:parmers withUserSecrect:[[VSSessionInterface shareInstance] userSecret]];
            [parmers setObject:signStr forKey:@"apiSign"];
        }

    }else{
         if (!Later_Sign) {
             NSString *signStr = [self signString:parmers];
             [parmers setObject:signStr forKey:@"apiSign"];
         }
    
    }
    
    NSString *source = [parmers objectForKey:@"source"];
    if (source  && [source isEqualToString:@"1"] && [VSStartManager shareInstance].externParam.source) {
        [parmers setObject:[VSStartManager shareInstance].externParam.source forKey:@"source"];
    }
}

/**
 *  根据配置文件，将请求对象映射成dictionary
 *
 *  @param config        该请求的dictionary
 *  @param requestObject 请求的对象
 *
 *  @return 请求的dictionary
 */
+(void)baserequsetConfig:(BaseNetwork*)config requestObj:(NSObject *)requestObject :(void (^)(NSInteger code,NSString *msg)) callBack
{
    NSMutableDictionary *parmers = [BFMRequest assembleRequestValue:config :callBack request:requestObject];
//    NSString *url = config.url;
    
    NSString *url = [NSString stringWithFormat:@"%@%@",VSSERVERURL,config.url];
    
    NSString *configurl = [VSStartManager shareInstance].externParam.serverUrl;//[VSSystemConfig shareInstance].serverUrl;
    if (configurl && ![configurl isEqualToString:@""] ) {
        url = [NSString stringWithFormat:@"%@%@",configurl,config.url];
    }
    
    if ([config.url hasPrefix:@"http://"]) {
        url = config.url;
    }
    
    NSString *method = config.method;
    AFHTTPRequestOperationManager *manager = [AFHTTPRequestOperationManager manager];
    manager.responseSerializer = [AFJSONResponseSerializer serializer];
    manager.responseSerializer.acceptableContentTypes = [NSSet setWithObjects:@"application/json", @"text/json", @"text/javascript", @"text/plain", nil];
    
    if (Debug) {
        NSLog(@"url:%@ request:%@", url, parmers);
    }
    
    NSObject *wRequestObject = requestObject;
    if ([[method uppercaseString] isEqualToString:@"POST"]) {
        AFHTTPRequestOperation *afRequest = [manager POST:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mork
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
            
            
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else if ([[method uppercaseString] isEqualToString:@"PUT"]){
        AFHTTPRequestOperation *afRequest = [manager PUT:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
            
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == -1011) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }else{
        AFHTTPRequestOperation *afRequest = [manager GET:url parameters:parmers  success:^(AFHTTPRequestOperation *operation, id responseObject) {
            if (DEBUG) {
                NSLog(@"%@", responseObject);
            }
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
            [BFMRequest parseData:responseObject config:config :callBack request:wRequestObject];
        } failure:^(AFHTTPRequestOperation *operation, NSError *error) {
            [[BFMRequestManager shareInstance] removeRequest:url];//删除dictionary保存的该请求
#ifdef Mock
            if (error.code == 404) {
                [BFMRequest mork:config];
            }
#endif
            NSLog(@"%@", error.description);
            callBack(-1, NetException);
        }];
        [[BFMRequestManager shareInstance] addUrlAndRequest:url request:afRequest];
        [BFMRequestManager shareInstance].currentRequest = afRequest;
    }
}

+ (NSMutableDictionary *)assembleRequestValue:(BaseNetwork*)config :(void (^)(NSInteger code,NSString *msg))callBack request:(NSObject *)requestObject{
    NSMutableDictionary *parmers = [NSMutableDictionary dictionary];
    
    [config.reqParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
        NSArray *array = [(NSString*)obj componentsSeparatedByString:@"."];
        if (array.count == 1) {
            [parmers setObject:array[0] forKey:key];
        }else {
            NSString *strClass = array[0];
            NSObject *object;
            NSString *requestClassName = NSStringFromClass([requestObject class]);
            if ([strClass isEqualToString:requestClassName]) {
                object = requestObject;
            }else{
                object = [NSClassFromString(array[0]) shareInstance];
            }
            
            for (int i = 1; i<array.count; i++) {
                @try {
                    //                object = [object valueForKey:array[i]];
                    NSString *strValue = array[i];
                    NSRange rangeFun = [strValue rangeOfString:@"{"];
                    if (rangeFun.length > 0) {
                        NSString *selectorName = [strValue substringFromIndex:rangeFun.location+1];
                        SEL function = NSSelectorFromString(selectorName);
#pragma clang diagnostic ignored "-Warc-performSelector-leaks"
                        object = [object performSelector:function];
                    }else{
                        object = [object valueForKey:array[i]];
                    }
                }
                @catch (NSException *exception) {
                    [BFMRequest showException:exception path:key];
//                    callBack(-1,nil);
//                    return ;
                }
                @finally {
                    
                }
            }
            
            @try {
                [parmers setObject:object forKey:key];
            }
            @catch (NSException *exception) {
                [BFMRequest showException:exception path:key];
            }
            @finally {
                
            }
        }
    }];
    return parmers;
}

/**
 *  负责解析服务器返回的数据，并将数据赋值到相关的model中
 *
 *  @param responseObject 服务器返回的数据
 *  @param config         配置信息
 *  @param requestObject  被赋值的model对象
 */
+(void)parseData:(id)responseObject config:(BaseNetwork*)config :(void (^)(NSInteger code,NSString *msg)) callBack request:(NSObject *)requestObject{
    NSInteger code = -1;
    if ([responseObject isKindOfClass:[NSDictionary class]]) {
        code = [responseObject[@"code"] integerValue];
        [config.resParam enumerateKeysAndObjectsUsingBlock:^(id key, id obj, BOOL *stop) {
            //根据路径（key）获取返回数据中的值
            NSArray *keyArr = [(NSString*)key componentsSeparatedByString:@"."];
            id value = responseObject;
            for (int i = 0; i<keyArr.count; i++) {
                @try {
                    value =  [value valueForKey:keyArr[i]];
                    if (i != keyArr.count-1) {
                        if (!value) {
#ifdef SHOW_Debug
                            UIAlertView *alert = [[UIAlertView alloc] initWithTitle:@"结构化错误,路径不对" message:key delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
                            [alert show];
#endif
                        }
                    }
                }
                @catch (NSException *exception) {
                    [BFMRequest showException:exception path:key];
                }
                @finally {
                    
                }
            }
            //根据路径（obj）获取对应类的属性名
            NSArray *array = [(NSString*)obj componentsSeparatedByString:@"."];
            NSString *strClass = array[0];
            NSObject *object;
            if ([strClass isEqualToString:NSStringFromClass([requestObject class])]) {
                object = requestObject;
            }else{
                object = [NSClassFromString(array[0]) shareInstance];
            }
            for (int i = 1; i<array.count-1; i++) {
                @try {
                    object = [object valueForKey:array[i]];
                }
                @catch (NSException *exception) {
                    [BFMRequest showException:exception path:key];
                }
                @finally {
                    
                }
            }
            
            //将返回数据中的值 赋值给 对应类的属性名
            unsigned int propertyCount;
            objc_property_t *pProperty = class_copyPropertyList([object class], &propertyCount);
            NSString *type = nil;
            for (int i = 0; i<propertyCount; i++) {
                objc_property_t property = pProperty[i];
                NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                if ([propertyname isEqualToString:[array lastObject]]) {
                    //匹配的属性
                    type = [NSString stringWithUTF8String:getPropertyType(property)];
                    break;
                }
            }
            if (!type) {//当本类中不包含这个属性名，则在父类中查找
                Class A = [[object class] superclass];
                while (![NSStringFromClass(A) isEqualToString:@"NSObject"]) {
                    pProperty = class_copyPropertyList(A, &propertyCount);
                    for (int i = 0; i<propertyCount; i++) {
                        objc_property_t property = pProperty[i];
                        NSString *propertyname = [NSString stringWithUTF8String:property_getName(property)];
                        if ([propertyname isEqualToString:[array lastObject]]) {
                            //匹配的属性
                            type = [NSString stringWithUTF8String:getPropertyType(property)];
                            break;
                        }
                    }
                    A = [A superclass];
                }
            }
            
            NSString *propertyKey = [array lastObject];
            [BFMRequest setResponseDataToValue:type value:value key:key object:object propertyKey:propertyKey];
        }];
    }else{
        NSLog(@"%@",responseObject);
    }
    NSLog(@"code:%d, msg:%@", (int)code, responseObject[@"msg"]);
    callBack(code,responseObject[@"msg"]);
}

/**
 *  将返回的数据赋值给类的对应属性,解析的一部分功能
 *
 *  @param type        属性类型(eg i, f)
 *  @param value       属性值
 *  @param key         返回数据的路径
 *  @param object      接收对象的属性名
 *  @param propertyKey 接收对象
 */
+ (void)setResponseDataToValue:(NSString *)type value:(id)value key:(NSString *)key object:(NSObject *)object propertyKey:(NSString *)propertyKey{
    if (type) {
        @try {
            if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"]) {
                if (value){
                    if (![value isKindOfClass:[NSNumber class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else {
                        [object setValue:[NSNumber numberWithInteger:[value integerValue]] forKey:propertyKey];
                    }
                }
            }else if ([type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
                if (value){
                    if (![value isKindOfClass:[NSNumber class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else {
                        [object setValue:[NSNumber numberWithLongLong:[value longLongValue]] forKey:propertyKey];
                    }
                }
            }else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
                if (value){
                    if (![value isKindOfClass:[NSNumber class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else {
                        [object setValue:[NSNumber numberWithDouble:[value doubleValue]] forKey:propertyKey];
                    }
                }
            }else if([type isEqualToString:@"NSNumber"]){
                if (value) {
                    if (![value isKindOfClass:[NSNumber class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else {
                        [object setValue:value forKey:propertyKey];
                    }
                }
            }else if ([type isEqualToString:@"NSString"]) {
                if (value) {
                    if (![value isKindOfClass:[NSString class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else {
                        [object setValue:value forKey:propertyKey];
                    }
                }
            }else if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSMutableArray"]) {
                if (value) {
                    if (![value isKindOfClass:[NSArray class]]) {
                        [BFMRequest showErrortype:type value:value path:key];
                    }else{
                        if ([object respondsToSelector:@selector(classForArrayProperty)]) {
                            NSDictionary *dic = [object classForArrayProperty];
                            NSString *className = dic[propertyKey];
                            NSArray *arr = [BFMRequest recursion:value className:className];
                            [object setValue:arr forKey:propertyKey];
                        }
                    }
                }
            }else {
                id objectParam = [BFMRequest contentToClass:value className:type];//不是基本类型
                [object setValue:objectParam forKey:propertyKey];
            }
        }
        @catch (NSException *exception) {
            [BFMRequest showException:exception path:key];
        }
        @finally {
            
        }
    }else {
#ifdef SHOW_Debug
        UIAlertView *alert = [[UIAlertView alloc] initWithTitle:value message:@"该属性不存在" delegate:nil cancelButtonTitle:@"确定" otherButtonTitles: nil];
        [alert show];
#endif
    }
}

/**
 *  json数据转换模型对象
 *
 *  @param content   json数据
 *  @param className 类名称
 *  @param object    转换之后的对象
 */
+ (void)contentToClass:(id)content className:(NSString *)className object:(NSObject **)object{
    Class class = NSClassFromString(className);
    // 获取父类并处理父类
    Class superClass = class_getSuperclass(class);
    if (superClass != [NSObject class] && superClass != nil) {
        [self contentToClass:content className:NSStringFromClass(superClass) object:object];
    }
    //对象中数组元素和类型映射关系字典
    NSDictionary *arrayClassMapping = nil;
    if ([*object respondsToSelector:@selector(classForArrayProperty)]) {
        arrayClassMapping = [*object classForArrayProperty];
    }
    unsigned int propertyCount;
    objc_property_t *pProperty = class_copyPropertyList(class, &propertyCount);
    for (int i=0; i<propertyCount; i++) {
        objc_property_t property = pProperty[i];
        const char *propertyName = property_getName(property);
        const char *propertyType = getPropertyType(property);
        NSString *key = [NSString stringWithUTF8String:propertyName];
        NSString *type = [NSString stringWithUTF8String:propertyType];
        //不确定类型的属性值
        if ([type isEqualToString:@"NSArray"] || [type isEqualToString:@"NSMutableArray"]) {
            //json数据的格式
            if ([content isKindOfClass:[NSDictionary class]]) {
                NSArray *datas = [content objectForKey:key];//valueForProperty;
                if (datas.count > 0) {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:datas.count];
                    for (NSDictionary *dic in datas) {
                        // 根据key从arrayClassMapping中获取元素类型
                        NSString *className = [arrayClassMapping objectForKey:key];
                        if (className) {
                            NSObject *obj = [BFMRequest contentToClass:dic className:className];
                            [arr addObject:obj];
                        }
                    }
                    if (arr.count != datas.count) {
                        [*object setValue:datas forKey:key];
                    }else{
                        [*object setValue:arr forKey:key];
                    }
                }
            }
            else if([content isKindOfClass:[NSArray class]]){ //如果是arr类型
                NSArray *arrContent = content;
                if (arrContent.count > 0) {
                    NSMutableArray *arr = [[NSMutableArray alloc] initWithCapacity:arrContent.count];
                    for (NSDictionary *dic in arrContent) {
                        // 根据key从arrayClassMapping中获取元素类型
                        NSString *className = [arrayClassMapping objectForKey:key];
                        if (className) {
                            NSObject *obj = [BFMRequest contentToClass:dic className:className];
                            [arr addObject:obj];
                        }
                    }
                    if (arr.count!=arrContent.count) {
                        [*object setValue:arrContent forKey:key];
                    }else{
                        [*object setValue:arr forKey:key];
                    }
                }
            }
        }
        else{
            id valueForProperty = [content objectForKey:key];
            
            if ([valueForProperty isKindOfClass:[NSDictionary class]]) { // 如果是Dictionary类型
                if (type != nil && ![type isEqualToString:@""]) {
                    NSObject *obj = [BFMRequest contentToClass:valueForProperty className:type];
                    [*object setValue:obj forKey:key];
                }
            } else {
                id obj = valueForProperty;//[content objectForKey:key];
                [BFMRequest baseDataParse:*object propertyType:type propertyName:key content:obj];
            }
        }
    }
    if (pProperty) {
        free(pProperty);
    }
}

/**
 *  将json数据转换成模型对象，是上面方法的拓展，即可以根据类名创建这个对象
 *
 *  @param content   json数据
 *  @param className 对象名称
 *
 *  @return 转换后的对象
 */
+ (id)contentToClass:(id)content className:(NSString *)className{
    Class class = NSClassFromString(className);
    // 实例对象
    NSObject *object = [[class alloc] init];
    [BFMRequest contentToClass:content className:className object:&object];
    return object;
}

/**
 *  数据类型的赋值, 当不是基础类型的时候创建这个对象
 *
 *  @param object 赋值的对象
 *  @param type   赋值对象的属性Type
 *  @param name   赋值对象的属性名称
 *  @param obj    值
 */
+ (void)baseDataParse:(NSObject *)object propertyType:(NSString *)type propertyName:(NSString *)name content:(id)obj{
    if (!obj)
        return;
    @try {
        if ([type isEqualToString:@"i"] || [type isEqualToString:@"l"] || [type isEqualToString:@"s"] || [type isEqualToString:@"q"] ||
            [type isEqualToString:@"I"] || [type isEqualToString:@"L"] || [type isEqualToString:@"S"] || [type isEqualToString:@"Q"]) {
            [object setValue:[NSNumber numberWithInteger:[obj integerValue]] forKey:name];
        }else if ([type isEqualToString:@"f"] || [type isEqualToString:@"d"]) {
            [object setValue:[NSNumber numberWithDouble:[obj doubleValue]] forKey:name];
        }else if ([type isEqualToString:@"c"] || [type isEqualToString:@"C"]) {
            [object setValue:[NSNumber numberWithChar:[obj charValue]] forKey:name];
        }else if([type isEqualToString:@"NSNumber"]){
            [object setValue:obj forKey:name];
        }else if ([type isEqualToString:@"B"]){
            [object setValue:[NSNumber numberWithInteger:[obj boolValue]] forKey:name];
        }else if ([type isEqualToString:@"NSString"]) {
            if (obj) {
                [object setValue:[NSString stringWithFormat:@"%@",obj] forKey:name];
            }
        }else if([type isEqualToString:@"id"]){
            id objectParam = [BFMRequest contentToClass:obj className:type];
            
            [object setValue:objectParam forKey:name];
        }
    }
    @catch (NSException *exception) {
        [self showException:exception path:name];
    }
    @finally {
    }
}

#pragma mark private method
#pragma mark --api_sign
+ (NSString *)signString:(NSDictionary *)dic  {
    if (!dic ||  [dic count] == 0) return @"";
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedKeys = [[dic allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeys) {
        NSString *value =[dic objectForKey:key];
        [signString appendFormat:@"%@",value];
    }
    [signString appendString:[[VSSystemConfig shareInstance] apiSecrect]];
    return [self md5String:signString];
}


+ (NSString *)signString:(NSDictionary *)dic  withUserSecrect:(NSString *)userSecrect{
    if (!dic ||  [dic count] == 0) return @"";
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedKeys = [[dic allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeys) {
        NSString *value =[dic objectForKey:key];
        [signString appendFormat:@"%@",value];
    }
    
    [signString appendString:userSecrect];
    [signString appendString:[[VSSystemConfig shareInstance] apiSecrect]];
    
    return [self md5String:signString];
}

+ (NSString *)md5String :(NSString *)string{
    const char *cStr = [string UTF8String];
    unsigned char result[16];
    CC_MD5( cStr, strlen(cStr), result );
    return [[NSString stringWithFormat:
             @"%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X%02X",
             result[0], result[1], result[2], result[3],
             result[4], result[5], result[6], result[7],
             result[8], result[9], result[10], result[11],
             result[12], result[13], result[14], result[15]
             ] lowercaseString];
}


+ (NSString *)sha1SignString:(NSDictionary *)dic  withUserSecrect:(NSString *)userSecrect{
    if (!dic ||  [dic count] == 0) return @"";
    
    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedKeys = [[dic allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeys) {
        NSString *value =[dic objectForKey:key];
        [signString appendFormat:@"%@",value];
    }
    
    NSString *result = [NSString stringWithFormat:@"%@&%@%@",[[VSSystemConfig shareInstance] apiSecrect],userSecrect,signString];

    
    return [self sha1:result];
}

+ (NSString *)sha1SignString:(NSDictionary *)dic
{
    if (!dic ||  [dic count] == 0) return @"";

    NSSortDescriptor *descriptor = [NSSortDescriptor sortDescriptorWithKey:nil ascending:YES];
    NSArray *sortedKeys = [[dic allKeys] sortedArrayUsingDescriptors:[NSArray arrayWithObjects:descriptor, nil]];
    NSMutableString *signString = [NSMutableString stringWithString:@""];
    for (NSString *key in sortedKeys) {
        NSString *value =[dic objectForKey:key];
        [signString appendFormat:@"%@",value];
    }
    NSString *result = [NSString stringWithFormat:@"%@%@",[[VSSystemConfig shareInstance] apiSecrect],signString];
    return [self sha1:result];
}

+ (NSString *)sha1:(NSString *)string{
//    const char *cstr = [string cStringUsingEncoding:NSUTF8StringEncoding];
//    NSData *data = [NSData dataWithBytes:cstr length:string.length];
    
    NSData *data = [string dataUsingEncoding:NSUTF8StringEncoding];
    uint8_t digest[CC_SHA1_DIGEST_LENGTH];
    
    CC_SHA1(data.bytes, data.length, digest);
    
    NSMutableString* output = [NSMutableString stringWithCapacity:CC_SHA1_DIGEST_LENGTH * 2];
    
    for(int i = 0; i < CC_SHA1_DIGEST_LENGTH; i++)
        [output appendFormat:@"%02x", digest[i]];
    
    return output;
}
@end

@interface BFMRequestManager ()

@property(nonatomic, strong) NSMutableDictionary *dicUrlAndRequest;

@end

@implementation BFMRequestManager

+ (BFMRequestManager *)shareInstance{
    static BFMRequestManager *requestManager = nil;
    static dispatch_once_t predicate;
    dispatch_once(&predicate, ^{
        requestManager = [[BFMRequestManager alloc] init];
    });
    return requestManager;
}

- (id)init{
    if (self = [super init]) {
        _dicUrlAndRequest = [[NSMutableDictionary alloc] init];
    }
    return self;
}

- (void)addUrlAndRequest:(NSString *)url request:(AFHTTPRequestOperation *)request{
    [_dicUrlAndRequest setObject:request forKey:url];
}

- (void)removeRequest:(NSString *)url{
    AFHTTPRequestOperation *request = _dicUrlAndRequest[url];
    if (request) {
        [_dicUrlAndRequest removeObjectForKey:url];
    }
}

- (void)cancelClassRequest:(NSString *)className{
    NSDictionary *dic = [VSClassAndRequest getClassAndRequests];
    NSArray *urls = dic[className];
    for (NSString *classUrl in urls) {
        NSArray *arrClassAndUrl = [classUrl componentsSeparatedByString:@":"];//根据:分离UIViewController和url
        if (arrClassAndUrl.count > 0) {
            NSString *url = arrClassAndUrl[1];
            AFHTTPRequestOperation *request = _dicUrlAndRequest[url];
            if (request) {
                [_dicUrlAndRequest removeObjectForKey:url];
                //需要手动的把请求取消，置为nil
                [request cancel];
                request = nil;
            }
        }
    }
}

- (void)cancelCurrentRequest{
    [self.currentRequest cancel];
    self.currentRequest = nil;
}

@end

