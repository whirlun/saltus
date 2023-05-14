////
// Copyright (c) whirlun <whirlun@yahoo.co.jp>. All rights reserved.
// Licensed under the MIT license. See LICENSE file in the project root for details.
//

import Foundation

typealias mrb_func = @convention(c) (UnsafeMutablePointer<mrb_state>?, mrb_value) -> mrb_value
typealias mrb_argv = UnsafeMutablePointer<UnsafeMutableRawPointer?>
typealias mrb_arg<T> = UnsafeMutablePointer<T>
typealias mrb_fptr = UnsafeMutablePointer<mrb_func_t?>

struct PluginMetaData {
    let name: String
    let altname: [String]
    let hook: String
}

class PluginHost {
    let mrb: MRuby = MRuby()
    var pluginList: [PluginMetaData] = []
    
    init() {
        register_plugins()
    }
    
    private func register_plugins() {
        let manager = FileManager.default
        let application_support = manager.urls(for: .applicationSupportDirectory, in: .userDomainMask).first
        let directory = application_support?.appending(path: "zip.ddc.saltus/plugins")
        do{
            if let dir = directory {
                if !manager.fileExists(atPath: dir.path(percentEncoded: true)) {
                    print("file not exist")
                    try manager.createDirectory(atPath: dir.path(percentEncoded: true), withIntermediateDirectories: true)
                }
                let directory_content = try manager.contentsOfDirectory(atPath: dir.path(percentEncoded: true))
                for fn in directory_content {
                    let file_path = dir.appendingPathComponent(fn)
                    let content = try String(contentsOfFile: file_path.path(percentEncoded: true))
                    mrb.run(content)
                    let filename = fn.components(separatedBy: ".").first!
                    let mrb_class = mrb.getClass(filename)
                    if mrb.mrb_vm.pointee.exc != nil {
                        mrb_print_error(mrb.mrb_vm)
                    } else {
                        let new_obj = mrb_class?.newObj(0, argv: nil)
                        let plugin_info = new_obj?.call("register", argc: 0, argv: nil)
                        let dict = mrb.unboxValue(plugin_info ?? mrb_nil_value(), raw: false).o as? NSDictionary
                        if mrb.mrb_vm.pointee.exc != nil {
                            mrb_print_error(mrb.mrb_vm)
                            continue
                        }
                        if let dict = dict {
                            let name = dict["name"]
                            let altname = dict["altname"]
                            let hook = dict["hook"]
                            if let name = name as? String, let altname = altname as? [String], let hook = hook as? String {
                                pluginList.append(PluginMetaData(name: name, altname: altname, hook: hook))
                            }
                        }
                    }
                    
                }
                
            }
        } catch {
            print("\(error)")
        }
    }
}

func test_mruby() {
    let mrb = MRuby()
    let rbclass = MRubyClass(class: "Test", state: mrb!.mrb_vm, parent: mrb?.mrb_vm.pointee.object_class)
    let str_concat_func: mrb_func? = {
        mrb_vm, _self in
        let argv = mrb_argv.allocate(capacity: 2)
        let arg1 = mrb_arg<mrb_value>.allocate(capacity: 1)
        let arg2 = mrb_arg<mrb_value>.allocate(capacity: 1)
        argv.initialize(to: arg1)
        (argv+1).initialize(to: arg2)
        let c = mrb_args(mrb_vm, "SS", 2, argv)
        let s1 = arg1.pointee
        let s2 = arg2.pointee
        mrb_str_concat(mrb_vm, s1, s2)
        return s1
    }
    let str_concat_func_pointer = mrb_fptr.allocate(capacity: 1)
    str_concat_func_pointer.initialize(to: str_concat_func)
    rbclass?.defMethod("concat", func: str_concat_func_pointer)
    let obj = rbclass?.newObj(0, argv: nil)
    let rbclass2 = MRubyClass(class: "Test2", state: mrb!.mrb_vm, parent: rbclass?.clas)
    var i = mrb_int_value(mrb?.mrb_vm, 2)
    let arr = mrb?.run(
        #"""
        {hello:"world"}
        """#)
    if mrb?.mrb_vm.pointee.exc != nil {
        mrb_print_error(mrb?.mrb_vm)
    } else {
        //unbox_mrb_value(mrb: mrb, value: arr)
    }
    str_concat_func_pointer.deallocate()
}

func unbox_mrb_value(mrb: MRuby?, value: mrb_value?) {
    let unboxed = mrb?.unboxValue(value!, raw: false)
    switch unboxed?.t {
    case .INT:
        print(unboxed!.i)
    case .FLOAT:
        print(unboxed!.f)
    case .STRING:
        print(unboxed?.o as! NSString)
    case .T:
        print(true)
    case .F:
        print(false)
    case .ARRAY:
        /*let ptr = unboxed!.p
        let len = Int(truncatingIfNeeded: unboxed!.i)
        let p: UnsafeMutablePointer<mrb_value>! = ptr?.bindMemory(to: mrb_value.self, capacity: len)
        print("[")
        for i in 0..<len {
            unbox_mrb_value(mrb: mrb, value: (p+i).pointee)
        }
        print("]")*/
        print(unboxed!.o as! NSArray)
    case .HASH:
        print(unboxed!.o as! NSDictionary)
    default:
        print("invalid")
    }
}
