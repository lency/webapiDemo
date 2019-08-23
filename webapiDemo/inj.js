function imp_stub(api, name) {
  function npccall(order) {
    let s = JSON.stringify(order);
    let ret = JSON.parse(prompt("__native__command__", s)) || {};
    if (!"type" in ret) return;
    if (ret.type == "value") return ret.value;
    if (ret.type == "error") throw ret.value;
    if (ret.type == "promise")
      return new Promise(function(reslove) {
        window[ret.promise] = function(value) {
          delete window[ret.promise];
          value = JSON.parse(value);
          reslove(value.value);
        };
      });
  }

  function extract_args(fun) {
    let x = fun.toString();
    return /\((.*)\)/
      .exec(x)[1]
      .split(",")
      .map(e => e.trim());
  }
  function zip_paras(keys, vals) {
    var obj = {};
    for (idx in keys) obj[keys[idx]] = vals[idx];
    return obj;
  }
  //enumarator
  let descs = Object.getOwnPropertyDescriptors(api.prototype);
  for (let pp in descs) {
    if (pp == "constructor") continue;
    if ("value" in descs[pp]) {
      let x = descs[pp]["value"];
      let type = Object.prototype.toString.call(x);
      if (type == '[object AsyncFunction]') type = 'AsyncFunction'
          else type = 'Function'
      let keys = extract_args(x);
      api.prototype[pp] = function(...args) {
        let s = {
          class: name,
          method: pp,
          type: type,
          args: zip_paras(keys, args)
        };
        return npccall(s);
      };
    }
    if ("get" in descs[pp]) {
      let x = api.prototype.__lookupGetter__(pp);
      api.prototype.__defineGetter__(pp, function() {
        let s = {
          class: name,
                                     type:"Getter",
          method: pp
        };
        return npccall(s);
      });
    }
    if ("set" in descs[pp]) {
      let x = api.prototype.__lookupSetter__(pp);
      let keys = extract_args(x);
      api.prototype.__defineSetter__(pp, function(v) {
        let s = {
          class: name,
                                     type:"Setter",
          method: pp,
          args: { newVal: v }
        };
        npccall(s);
      });
    }
  }
  return new api();
}

class Emitter {
    constructor() {
        var delegate = document.createDocumentFragment();
        [
         'addEventListener',
         'dispatchEvent',
         'removeEventListener'
         ].forEach(f =>
                   this[f] = (...xs) => delegate[f](...xs)
                   )
    }
}


let webapi = imp_stub(
  class extends Emitter {
    times(obj1, obj2) {}
    async waitAndAdd(seconds) {}
    get x() {}
    set x(newVal) {}
    trigger(){}
  },
  "webapi"
);
