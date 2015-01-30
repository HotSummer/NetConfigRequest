//
//  ReflectionDefine.h
//  Reflect
//
//  Created by summer.zhu on 2/12/14.
//  Copyright (c) 2014年 summer.zhu. All rights reserved.
//

#ifndef Reflect_ReflectionDefine_h
#define Reflect_ReflectionDefine_h

#define ShowException

#define Debug

#ifdef Debug
#define RLog(fmt, ...) NSLog((@"%s [Line %d] " fmt), __PRETTY_FUNCTION__, __LINE__, ##__VA_ARGS__)
#else
#define RLog(xx, ...) ((void)0)
#endif

#endif
