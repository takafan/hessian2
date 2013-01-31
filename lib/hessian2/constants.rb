# Hessian 2.0 Web Services Protocol Bytecode map
# x00 - x42    # reserved
# x43          # rpc call ('C')
# x44          # reserved
# x45          # envelope ('E')
# x46          # fault ('F')
# x47          # reserved
# x48          # hessian version ('H')
# x49 - x4f    # reserved
# x4f          # packet chunk ('O')
# x50          # packet end ('P')
# x51          # reserved
# x52          # rpc result ('R')
# x53 - x59    # reserved
# x5a          # terminator ('Z')
# x5b - x5f    # reserved
# x70 - x7f    # final packet (0 - 4096)
# x80 - xff    # final packet for envelope (0 - 127)

# Hessian 2.0 Serialization Protocol Bytecode map
# x00 - x1f    # utf-8 string length 0-31
# x20 - x2f    # binary data length 0-15
# x30 - x33    # utf-8 string length 0-1023
# x34 - x37    # binary data length 0-1023
# x38 - x3f    # three-octet compact long (-x40000 to x3ffff)
# x40          # reserved (expansion/escape)
# x41          # 8-bit binary data non-final chunk ('A')
# x42          # 8-bit binary data final chunk ('B')
# x43          # object type definition ('C')
# x44          # 64-bit IEEE encoded double ('D')
# x45          # reserved
# x46          # boolean false ('F')
# x47          # reserved
# x48          # untyped map ('H')
# x49          # 32-bit signed integer ('I')
# x4a          # 64-bit UTC millisecond date
# x4b          # 32-bit UTC minute date
# x4c          # 64-bit signed long integer ('L')
# x4d          # map with type ('M')
# x4e          # null ('N')
# x4f          # object instance ('O')
# x50          # reserved
# x51          # reference to map/list/object - integer ('Q')
# x52          # utf-8 string non-final chunk ('R')
# x53          # utf-8 string final chunk ('S')
# x54          # boolean true ('T')
# x55          # variable-length list/vector ('U')
# x56          # fixed-length list/vector ('V')
# x57          # variable-length untyped list/vector ('W')
# x58          # fixed-length untyped list/vector ('X')
# x59          # long encoded as 32-bit int ('Y')
# x5a          # list/map terminator ('Z')
# x5b          # double 0.0
# x5c          # double 1.0
# x5d          # double represented as byte (-128.0 to 127.0)
# x5e          # double represented as short (-32768.0 to 32767.0)
# x5f          # double represented as float
# x60 - x6f    # object with direct type
# x70 - x77    # fixed list with direct length
# x78 - x7f    # fixed untyped list with direct length
# x80 - xbf    # one-octet compact int (-x10 to x3f, x90 is 0)
# xc0 - xcf    # two-octet compact int (-x800 to x7ff)
# xd0 - xd7    # three-octet compact int (-x40000 to x3ffff)
# xd8 - xef    # one-octet compact long (-x8 to xf, xe0 is 0)
# xf0 - xff    # two-octet compact long (-x800 to x7ff, xf8 is 0)

module Hessian2
  module Constants
    BC_BINARY = 0x42
    BC_BINARY_CHUNK = 0x41
    BC_BINARY_DIRECT = 0x20
    BINARY_DIRECT_MAX = 0x0f
    BC_BINARY_SHORT = 0x34
    BINARY_SHORT_MAX = 0x3ff

    BC_CLASS_DEF = 0x43

    BC_DATE = 0x4a
    BC_DATE_MINUTE = 0x4b
    
    BC_DOUBLE = 0x44

    BC_DOUBLE_ZERO = 0x5b
    BC_DOUBLE_ONE = 0x5c
    BC_DOUBLE_BYTE = 0x5d
    BC_DOUBLE_SHORT = 0x5e
    BC_DOUBLE_MILL = 0x5f
    
    BC_FALSE = 0x46
    
    BC_INT = 0x49
    
    INT_DIRECT_MIN = -0x10
    INT_DIRECT_MAX = 0x2f
    BC_INT_ZERO = 0x90

    INT_BYTE_MIN = -0x800
    INT_BYTE_MAX = 0x7ff
    BC_INT_BYTE_ZERO = 0xc8
    
    BC_END = 0x5a

    INT_SHORT_MIN = -0x40000
    INT_SHORT_MAX = 0x3ffff
    BC_INT_SHORT_ZERO = 0xd4

    BC_LIST_VARIABLE = 0x55
    BC_LIST_FIXED = 0x56
    BC_LIST_VARIABLE_UNTYPED = 0x57
    BC_LIST_FIXED_UNTYPED = 0x58

    BC_LIST_DIRECT = 0x70
    BC_LIST_DIRECT_UNTYPED = 0x78
    LIST_DIRECT_MAX = 0x7

    BC_LONG = 0x4c
    LONG_DIRECT_MIN = -0x08
    LONG_DIRECT_MAX =  0x0f
    BC_LONG_ZERO = 0xe0

    LONG_BYTE_MIN = -0x800
    LONG_BYTE_MAX =  0x7ff
    BC_LONG_BYTE_ZERO = 0xf8

    LONG_SHORT_MIN = -0x40000
    LONG_SHORT_MAX = 0x3ffff
    BC_LONG_SHORT_ZERO = 0x3c
    
    BC_LONG_INT = 0x59
    
    BC_MAP = 0x4d
    BC_MAP_UNTYPED = 0x48
    
    BC_NULL = 0x4e
    
    BC_OBJECT = 0x4f
    BC_OBJECT_DEF = 0x43
    
    BC_OBJECT_DIRECT = 0x60
    OBJECT_DIRECT_MAX = 0x0f
    
    BC_REF = 0x51

    BC_STRING = 0x53
    BC_STRING_CHUNK = 0x52
    
    BC_STRING_DIRECT = 0x00
    STRING_DIRECT_MAX = 0x1f
    BC_STRING_SHORT = 0x30
    STRING_SHORT_MAX = 0x3ff
    
    BC_TRUE = 0x54

    P_PACKET_CHUNK = 0x4f
    P_PACKET = 0x50

    P_PACKET_DIRECT = 0x80
    PACKET_DIRECT_MAX = 0x7f

    P_PACKET_SHORT = 0x70
    PACKET_SHORT_MAX = 0xfff
  end
end
