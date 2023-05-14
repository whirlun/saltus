////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#ifndef mruby_binding_h
#define mruby_binding_h

#include <Foundation/Foundation.h>

#include <stdio.h>
#include <mruby.h>
#include <mruby/compile.h>
#include <mruby/string.h>
#include <mruby/array.h>
#include <mruby/hash.h>

mrb_int mrb_args(mrb_state *mrb, NSString * format, int argc, void* args[]);

typedef NS_ENUM(NSInteger, mrb_value_types) {
    INT,
    FLOAT,
    T,
    F,
    STRING,
    ARRAY,
    HASH,
    RAWARRAY,
    RAWHASH,
    INVALID
};

typedef union mrb_value_union {
    long long i;
    float f;
    id o;
    void *p;
} mrb_value_union;

@interface MRubyUnboxedValue: NSObject {
}

@property mrb_value_types t;
@property long long i;
@property double f;
@property id o;
@property void *p;

-(id)toNSType;

@end


@class MRubyClass;

@interface MRuby : NSObject {
}
@property mrb_state *mrb_vm;

-(MRubyClass *)getClass:(NSString *)name;
-(MRubyUnboxedValue *)unboxValue:(mrb_value) value raw:(BOOL)raw;
-(mrb_value)runString:(NSString *)rbcode;
-(id)init;
-(void)dealloc;


@end

@interface MRubyObject : NSObject {
    mrb_value obj;
    mrb_state *mrb_vm;
}

-(mrb_value)call:(NSString *)method argc:(int)argc argv:(mrb_value *)argv;

-(id)initWithValue:(mrb_value) v state:(mrb_state *)state;
@end

@interface MRubyClass : NSObject {
    mrb_state *mrb_vm;
}

@property struct RClass *clas;

+(instancetype) define:(NSString *)name state:(mrb_state*)state parent:(struct RClass*)parent;
-(void) defMethod:(NSString *)name func:(mrb_func_t *)func;
-(void) defClassMethod:(NSString *)name func:(mrb_func_t *)func;
-(MRubyObject *) newObj:(int)argc argv:(mrb_value *)argv;
-(id)initWithClassObject:(struct RClass *)cla state:(mrb_state*)state;
-(id)initClass:(NSString *)name state:(mrb_state *)state parent:(struct RClass *)parent;

@end
#endif /* mruby_binding_h */
