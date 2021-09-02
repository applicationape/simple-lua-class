
local function instanceof (self, cls)
    if self.__cls then
        return self.__cls:instanceof(cls)
    end

    if self == cls then
        return true
    end

    if self.__super then
        return self.__super:instanceof(cls)
    end

    return false
end

local allowedBaseClassTypes = {
    ["nil"] = true,
    ["table"] = true,
    ["userdata"] = true,
}

local function stringify(self)
    return self.__rawstr
end

function Class (BaseClass)
    local cls = { tostring = stringify }

    local basetype = type(BaseClass)
    assert(allowedBaseClassTypes[basetype], string.format("invalid base class type: \"%s\"", basetype))

    local clsaddr = string.sub(tostring(cls), 8)
    local clsstr = string.format("class: %s", clsaddr)

    return setmetatable(cls, {
        __index = function (tab, key)
            if key == "__super" then
                return BaseClass
            end

            if key == "__rawstr" then
                return clsstr
            end

            if key == "instanceof" then
                return instanceof
            end

            if BaseClass then
                return BaseClass[key]
            end
        end,
        __newindex = function (tab, key, value)
            assert(key ~= "__super", "readonly property \"__super\"")
            assert(key ~= "__rawstr", "readonly property \"__rawstr\"")
            assert(key ~= "instanceof", "readonly property \"instanceof\"")

            rawset(tab, key, value)
        end,
        __tostring = function (tab)
            return tab.__rawstr
        end,
        __call = function (tab, ...)
            local obj = {}
            local objaddr = string.sub(tostring(obj), 8)
            local objstr = string.format("object: %s", objaddr)

            setmetatable(obj, {
                __index = function (self, key)
                    if key == "__cls" then
                        return cls
                    end

                    if key == "__rawstr" then
                        return objstr
                    end

                    if key == "isinstanceof" then
                        return instanceof
                    end

                    return cls[key]
                end,
                __newindex = function (self, key, value)
                    assert(key ~= "__cls", "readonly property \"__cls\"")
                    assert(key ~= "__rawstr", "readonly property \"__rawstr\"")
                    assert(key ~= "instanceof", "readonly property \"instanceof\"")

                    rawset(self, key, value)
                end,
                __tostring = function (self)
                    return self:tostring()
                end,
                __add = function (...)
                    assert(cls.operatoradd, "no overload operator '+'")
                    return cls.operatoradd(...)
                end,
                __sub = function (...)
                    assert(cls.operatorsub, "no overload operator '-'")
                    return cls.operatorsub(...)
                end,
                __mul = function (...)
                    assert(cls.operatormul, "no overload operator '*'")
                    return cls.operatormul(...)
                end,
                __div = function (...)
                    assert(cls.operatordiv, "no overload operator '/'")
                    return cls.operatordiv(...)
                end,
                __pow = function (...)
                    assert(cls.operatorpow, "no overload operator '^'")
                    return cls.operatorpow(...)
                end,
                __mod = function (...)
                    assert(cls.operatormod, "no overload operator '%'")
                    return cls.operatormod(...)
                end,
                __unm = function (...)
                    assert(cls.operatorunm, "no overload operator '-(neg)'")
                    return cls.operatorunm(...)
                end,
                __concat = function (...)
                    assert(cls.operatorconcat, "no overload operator '..'")
                    return cls.operatorconcat(...)
                end,
                __eq = function (...)
                    assert(cls.operatoreq, "no overload operator '=='")
                    return cls.operatoreq(...)
                end,
                __lt = function (...)
                    assert(cls.operatorlt, "no overload operator '<'")
                    return cls.operatorlt(...)
                end,
                __le = function (...)
                    assert(cls.operatorle, "no overload operator '<='")
                    return cls.operatorle(...)
                end,
                __call = function (...)
                    assert(cls.operatorcall, "no overload operator '()'")
                    return cls.operatorcall(...)
                end,
            })

            if obj.ctor then
                obj:ctor(...)
            end

            return obj
        end
    })
end
