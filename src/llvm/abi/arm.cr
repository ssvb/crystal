require "../abi"

# Based on https://github.com/rust-lang/rust/blob/master/src/librustc_trans/trans/cabi_arm.rs
class LLVM::ABI::ARM < LLVM::ABI
  def abi_info(atys : Array(Type), rty : Type, ret_def : Bool)
    ret_ty = compute_return_type(rty, ret_def)
    arg_tys = compute_arg_types(atys)
    FunctionType.new arg_tys, ret_ty
  end

  def align(type : Type)
    case type.kind
    when Type::Kind::Integer
      (type.int_width + 7) / 8
    when Type::Kind::Float
      4
    when Type::Kind::Double
      8
    when Type::Kind::Pointer
      4
    when Type::Kind::Struct
      if type.packed_struct?
        1
      else
        type.struct_element_types.inject(1) do |memo, elem|
          Math.max(memo, align(elem))
        end
      end
    else
      raise "Unhandled Type::Kind in align: #{type.kind}"
    end
  end

  def size(type : Type)
    case type.kind
    when Type::Kind::Integer
      (type.int_width + 7) / 8
    when Type::Kind::Float
      4
    when Type::Kind::Double
      8
    when Type::Kind::Pointer
      4
    when Type::Kind::Struct
      if type.packed_struct?
        type.struct_element_types.inject(0) do |memo, elem|
          memo + size(elem)
        end
      else
        size = type.struct_element_types.inject(0) do |memo, elem|
          align(memo, elem) + size(elem)
        end
        align(size, type)
      end
    else
      raise "Unhandled Type::Kind in size: #{type.kind}"
    end
  end

  def align(offset, type)
    align = align(type)
    (offset + align - 1) / align * align
  end

  def register?(type)
    case type.kind
    when Type::Kind::Integer, Type::Kind::Float, Type::Kind::Double, Type::Kind::Pointer
      true
    else
      false
    end
  end

  private def compute_return_type(rty, ret_def)
    if !ret_def
      ArgType.direct(LLVM::Void)
    elsif register?(rty)
      attr = rty == LLVM::Int1 ? LLVM::Attribute::ZExt : nil
      ArgType.direct(rty, attr: attr)
    elsif rty.kind == Type::Kind::Struct
      case size(rty)
      when 1
        ArgType.direct(rty, LLVM::Int8)
      when 2
        ArgType.direct(rty, LLVM::Int16)
      when 3, 4
        ArgType.direct(rty, LLVM::Int32)
      else
        ArgType.indirect(rty, LLVM::Attribute::StructRet)
      end
    else
      raise "Unhandled Type::Kind in compute_return_type: #{rty.kind}"
    end
  end

  private def compute_arg_types(atys)
    atys.map do |aty|
      if register?(aty)
        attr = aty == LLVM::Int1 ? LLVM::Attribute::ZExt : nil
        ArgType.direct(aty, attr: attr)
      elsif aty.kind == Type::Kind::Struct
        if align(aty) <= 4
          ArgType.direct(aty, Type.new(LibLLVM.array_type(LLVM::Int32, ((size(aty) + 3) / 4).to_u32)))
        else
          ArgType.direct(aty, Type.new(LibLLVM.array_type(LLVM::Int64, ((size(aty) + 7) / 8).to_u32)))
        end
      else
        raise "Unhandled Type::Kind in compute_arg_types: #{aty.kind}"
      end
    end
  end
end
