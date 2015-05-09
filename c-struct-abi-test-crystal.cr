@[Link(ldflags: "c-struct-abi-test-clang.o")]
lib LibT
  struct VectI8
    x : Int8
    y : Int8
    z : Int8
  end

  struct VectF64
    x : Float64
    y : Float64
    z : Float64
    dummy : Int8
  end

  fun dot_product_i8(a : VectI8, b : VectI8) : Int32
  fun dot_product_f64(a : VectF64, b : VectF64) : Int32

  fun conv_i8_to_f64(a : VectI8) : VectF64
  fun conv_f64_to_i8(a : VectF64) : VectI8
end

a = LibT::VectI8.new
b = LibT::VectI8.new

a.x = 1.to_i8
a.y = 2.to_i8
a.z = 3.to_i8

b.x = 1.to_i8
b.y = 2.to_i8
b.z = 3.to_i8

result = LibT.dot_product_i8(a, b)
abort "LibT.dot_product_i8(a, b) failed" if result != 14
abort "LibT.conv_i8_to_f64(a) failed" if LibT.conv_i8_to_f64(a).z != 3

a = LibT::VectF64.new
b = LibT::VectF64.new

a.x = 1.to_f64
a.y = 2.to_f64
a.z = 3.to_f64

b.x = 1.to_f64
b.y = 2.to_f64
b.z = 3.to_f64

result = LibT.dot_product_f64(a, b)
abort "LibT.dot_product_if64(a, b) failed" if result != 14
abort "LibT.conv_f64_to_i8(a) failed" if LibT.conv_f64_to_i8(a).z != 3

puts "Everything is OK"
