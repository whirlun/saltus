////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

#import "mruby_bridge.h"

mrb_int mrb_args(mrb_state *mrb, NSString *format, int argc, void* argv[]) {
    switch (argc) {
        case 1:
            return mrb_get_args(mrb, format.UTF8String, argv[0]);
            break;
        case 2:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1]);
            break;
        case 3:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2]);
            break;
        case 4:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2], argv[3]);
            break;
        case 5:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2], argv[3], argv[4]);
            break;
        case 6:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5]);
            break;
        case 7:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6]);
            break;
        case 8:
            return mrb_get_args(mrb, format.UTF8String, argv[0], argv[1], argv[2], argv[3], argv[4], argv[5], argv[6], argv[7]);
            break;
        default:
            break;
    }
    return -1;
}

@implementation MRubyUnboxedValue
- (id)toNSType {
    switch (self.t) {
        case INT:
            return [NSNumber numberWithInt:self.i];
        case FLOAT:
            return [NSNumber numberWithInt:self.f];
        case T:
            return [NSNumber numberWithBool:YES];
        case F:
            return [NSNumber numberWithBool:NO];
        case STRING:
        case ARRAY:
        case HASH:
            return self.o;
        default:
            return NULL;
    }
}
@end

@implementation MRuby
-(id)init {
    self = [super init];
    self.mrb_vm = mrb_open();
    return self;
}

- (MRubyClass *)getClass:(NSString *)name {
    struct RClass *cla = mrb_class_get(self.mrb_vm, name.UTF8String);
    MRubyClass *clas = [[MRubyClass alloc] initWithClassObject:cla state: self.mrb_vm];
    return clas;
}

-(MRubyUnboxedValue *)unboxValue:(mrb_value)value raw:(BOOL)raw {
    MRubyUnboxedValue *unboxed = [[MRubyUnboxedValue alloc] init];
    if (mrb_integer_p(value)) {
        unboxed.t = INT;
        unboxed.i = mrb_integer(value);
    } else if (mrb_float_p(value)) {
        unboxed.t = FLOAT;
        unboxed.f = mrb_float(value);
    } else if (mrb_true_p(value)) {
        unboxed.t = T;
        unboxed.i = YES;
    } else if (mrb_false_p(value)) {
        unboxed.t = F;
        unboxed.i = NO;
    }else if (mrb_string_p(value)) {
        const char *cstr = RSTRING_CSTR(self.mrb_vm, value);
        NSString *nsstr = @(cstr);
        unboxed.t = STRING;
        unboxed.o = nsstr;
    } else if (mrb_symbol_p(value)) {
        mrb_sym sym = mrb_symbol(value);
        NSString *nsstr = [self unboxValue:mrb_sym_str(self.mrb_vm, sym) raw:false].o;
        unboxed.t = STRING;
        unboxed.o = nsstr;
    }
    else if (mrb_array_p(value)) {
        struct RArray *aryptr = mrb_ary_ptr(value);
        mrb_ssize alen = ARY_LEN(aryptr);
        mrb_value *valptr = ARY_PTR(aryptr);
        if (raw) {
            unboxed.t = RAWARRAY;
            unboxed.i = alen;
            unboxed.p = (void *)valptr;
        } else {
            NSMutableArray *ary = [NSMutableArray arrayWithCapacity:alen];
            for (int i = 0; i < alen; i++) {
                id val = [[self unboxValue:(valptr[i]) raw:false] toNSType];
                [ary addObject:val];
            }
            unboxed.t = ARRAY;
            unboxed.o = ary;
        }
    } else if (mrb_hash_p(value)) {
        struct RHash *hashptr = mrb_hash_ptr(value);
        mrb_value mrb_val = mrb_hash_value(hashptr);
        mrb_value keys = mrb_hash_keys(self.mrb_vm, mrb_val);
        NSArray *keysary = [[self unboxValue:keys raw:false] toNSType];
        mrb_value *rawkeysary = [self unboxValue:keys raw:true].p;
        if (raw) {
            unboxed.t = RAWHASH;
            unboxed.p = (void *)hashptr;
        } else {
            NSMutableDictionary *dict = [[NSMutableDictionary alloc] init];
            for (int i = 0; i < keysary.count; i++) {
                mrb_value hashval = mrb_hash_get(self.mrb_vm, mrb_val, rawkeysary[i]);
                id val = [[self unboxValue:hashval raw:false] toNSType];
                [dict setObject:val forKey:keysary[i]];
            }
            unboxed.t = HASH;
            unboxed.o = dict;
        }
    }else {
        unboxed.t = INVALID;
        unboxed.p = NULL;
    }
    return unboxed;
}

- (mrb_value)runString:(NSString *)rbcode {
    return mrb_load_string(self.mrb_vm, rbcode.UTF8String);
}

-(void)dealloc {
    mrb_close(self.mrb_vm);
}


@end

@implementation MRubyObject

- (mrb_value)call:(NSString *)method argc:(int)argc argv:(mrb_value *)argv {
    mrb_sym m_sym = mrb_intern(self->mrb_vm, method.UTF8String, [method length]);
    return mrb_funcall_argv(self->mrb_vm, self->obj, m_sym, argc, argv);
    
}
- (id)initWithValue:(mrb_value)v state:(mrb_state *)state {
    self = [super init];
    self->obj = v;
    self->mrb_vm = state;
    return self;
}

@end

@implementation MRubyClass

+(instancetype) define:(NSString *)name state:(mrb_state*)state parent:(struct RClass*)parent {
    return [[self alloc] initClass:name state:state parent:parent];
}

-(void) defMethod:(NSString *)name func:(mrb_func_t *)func {
    // nobody cares aspec, so just pass a random value
    mrb_define_method(self->mrb_vm, self.clas, name.UTF8String, *func, MRB_ARGS_ANY());
}

-(void) defClassMethod:(NSString *)name func:(mrb_func_t *)func {
    mrb_define_class_method(self->mrb_vm, self.clas, name.UTF8String, *func, MRB_ARGS_ANY());
}

- (MRubyObject *)newObj:(int)argc argv:(mrb_value *)argv {
    mrb_value obj = mrb_obj_new(self->mrb_vm, self.clas, argc, argv);
    MRubyObject *mrb_obj = [[MRubyObject alloc] initWithValue: obj state:self->mrb_vm];
    return mrb_obj;
}

-(id)initWithClassObject:(struct RClass *)cla state:(mrb_state*)state {
    self = [super init];
    self.clas = cla;
    self->mrb_vm = state;
    return self;
}

-(id)initClass:(NSString *)name state:(mrb_state*)state parent:(struct RClass*)parent {
    self = [super init];
    self.clas = mrb_define_class(state, name.UTF8String, parent);
    self->mrb_vm = state;
    return self;
}
@end
