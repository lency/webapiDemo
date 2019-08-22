var s_s_s = "try"

function npccall(order) {
    let s = JSON.stringify(order)
    let ret = JSON.parse(prompt('__native__command__', s))
    if(!'type' in ret)return
    if(ret.type == 'value')return ret.value
    if(ret.type == 'promise')return new Promise(function(reslove){
        window[ret.promise] = function(value) {
            delete window[ret.promise]
            reslove(value)
        }
    })
}



function imp_stub(api, name) {
    function extract_args(fun) {
        let x = fun.toString()
        let arg_str = (/\((.*)\)).exec(fun.toString())[1].split(',').map(e=>e.trim())
    }
    function zip_paras(keys, vals) {
        var obj = {}
        for (idx in keys)obj[keys[idx]] = vals[idx]
        return obj
    }
    //enumarator
    let descs = Object.getOwnPropertyDescriptors(api.prototype)
    for (pp in descs) {
        if(pp == 'constructor')continue
            if('value' in descs[pp]) {
                let x = descs[pp]['value']
                let keys = extract_args(x)
                api.prototype[pp] = function(...args) {
                    let s = {
                        'class': name,
                        'method': pp,
                        'args': zip_paras(keys, args)
                    }
                    return npccall(s)
                }
            }
        if('get' in descs[pp]) {
            let x = api.prototype.__lookupGetter__(pp)
            api.prototype.__defineGetter__(pp, function(){
                                           let s = {
                                           'class': name,
                                           'method': 'get_'+pp,
                                           }
                                           return npccall(s)
                                           })
        }
        if('set' in descs[pp]) {
            let x = api.prototype.__lookupSetter__(pp)
            let keys = extract_args(x)
            api.prototype.__defineSetter__(pp, function(v){
                                           let s = {
                                           'class': name,
                                           'method': 'set_'+pp,
                                           'args': {keys[0]: v}
                                           }
                                           return npccall(s)
                                           })
        }
    }
    return new api
}
try {
let webapi = imp_stub(class {
                      tims(obj1, obj2) {}
                      hime(oo) { }
                      get x() {}
                      set x(newVal) {}
                      },'webapi')
} catch(e) {
    alert(e)
}
