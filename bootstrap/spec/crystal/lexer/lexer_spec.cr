#!/usr/bin/env bin/crystal -run
require "spec"
require "../../../../bootstrap/crystal/lexer"

def it_lexes(string, type)
  it "lexes #{string}" do
    lexer = Crystal::Lexer.new string
    token = lexer.next_token
    token.type.should eq(type)
  end
end

def it_lexes(string, type, value)
  it "lexes #{string}" do
    lexer = Crystal::Lexer.new string
    token = lexer.next_token
    token.type.should eq(type)
    token.value.should eq(value)
  end
end

def it_lexes(string, type, value, number_kind)
  it "lexes #{string}" do
    lexer = Crystal::Lexer.new string
    token = lexer.next_token
    token.type.should eq(type)
    token.value.should eq(value)
    token.number_kind.should eq(number_kind)
  end
end

def it_lexes_many(values, type)
  values.each do |value|
    it_lexes value, type, value
  end
end

def it_lexes_keywords(keywords)
  keywords.each do |keyword|
    it_lexes keyword.to_s, :IDENT, keyword
  end
end

def it_lexes_idents(idents)
  idents.each do |ident|
    it_lexes ident, :IDENT, ident
  end
end

def it_lexes_i32(values)
  values.each { |value| it_lexes_number :i32, value }
end

def it_lexes_i64(values)
  values.each { |value| it_lexes_number :i64, value }
end

def it_lexes_f32(values)
  values.each { |value| it_lexes_number :f32, value }
end

def it_lexes_f64(values)
  values.each { |value| it_lexes_number :f64, value }
end

def it_lexes_number(number_kind, value : Array)
  it_lexes value[0], :NUMBER, value[1], number_kind
end

def it_lexes_number(number_kind, value : String)
  it_lexes value, :NUMBER, value, number_kind
end

def it_lexes_char(string, value)
  it "lexes #{string}" do
    lexer = Crystal::Lexer.new string
    token = lexer.next_token
    token.type.should eq(:CHAR)
    token.value.to_s.should eq(value.to_s)
  end
end

def it_lexes_operators(ops)
  ops.each do |op|
    it_lexes op.to_s, op
  end
end

def it_lexes_const(value)
  it_lexes value, :CONST, value
end

def it_lexes_instance_var(value)
  it_lexes value, :INSTANCE_VAR, value
end

def it_lexes_globals(globals)
  it_lexes_many globals, :GLOBAL
end

def it_lexes_symbols(symbols)
  symbols.each do |symbol|
    value = symbol[1, symbol.length - 1]
    value = value[1, value.length - 2] if value.starts_with?("\"")
    it_lexes symbol, :SYMBOL, value
  end
end

def it_lexes_regex(regex)
  it_lexes regex, :REGEXP, regex[1, regex.length - 2]
end

def it_lexes_global_match(globals)
  globals.each do |global|
    it_lexes global, :GLOBAL_MATCH, global[1, global.length - 1].to_i
  end
end

describe "Lexer" do
  it_lexes "", :EOF
  it_lexes " ", :SPACE
  it_lexes "\t", :SPACE
  it_lexes "\n", :NEWLINE
  it_lexes "\n\n\n", :NEWLINE
  it_lexes "\"foo\"", :STRING, "foo"
  it_lexes_keywords [:"def", :"if", :"else", :"elsif", :"end", :"true", :"false", :"class", :"module", :"include", :"while", :"nil", :"do", :"yield", :"return", :"unless", :"next", :"break", :"begin", :"lib", :"fun", :"type", :"struct", :"macro", :"ptr", :"out", :"require", :"case", :"when", :"then", :"of", :"abstract"]
  it_lexes_idents ["ident", "something", "with_underscores", "with_1", "foo?", "bar!"]
  it_lexes_idents ["def?", "if?", "else?", "elsif?", "end?", "true?", "false?", "class?", "while?", "nil?", "do?", "yield?", "return?", "unless?", "next?", "break?", "begin?"]
  it_lexes_idents ["def!", "if!", "else!", "elsif!", "end!", "true!", "false!", "class!", "while!", "nil!", "do!", "yield!", "return!", "unless!", "next!", "break!", "begin!"]
  it_lexes_i32 ["1", ["1hello", "1"], "+1", "-1", "1234", "+1234", "-1234", ["1.foo", "1"]]
  it_lexes_i64 [["1L", "1"], ["1Lhello", "1"], ["+1L", "+1"], ["-1L", "-1"]]
  it_lexes_f32 [["1f", "1"], ["1.0f", "1.0"], ["1.0fhello", "1.0"], ["+1.0f", "+1.0"], ["-1.0f", "-1.0"]]
  it_lexes_f64 ["1.0", ["1.0hello", "1.0"], "+1.0", "-1.0"]
  it_lexes_char "'a'", 'a'
  it_lexes_char "'\\n'", '\n'
  it_lexes_char "'\\t'", '\t'
  it_lexes_char "'\\v'", '\v'
  it_lexes_char "'\\f'", '\f'
  it_lexes_char "'\\r'", '\r'
  it_lexes_char "'\\0'", '\0'
  it_lexes_char "'\\0'", '\0'
  it_lexes_char "'\\''", '\''
  it_lexes_char "'\\\\'", '\\'
  it_lexes_operators [:"=", :"<", :"<=", :">", :">=", :"+", :"-", :"*", :"/", :"(", :")", :"==", :"!=", :"=~", :"!", :",", :".", :"..", :"...", :"!@", :"+@", :"-@", :"&&", :"||", :"|", :"{", :"}", :"?", :":", :"+=", :"-=", :"*=", :"/=", :"%=", :"&=", :"|=", :"^=", :"**=", :"<<", :">>", :"%", :"&", :"|", :"^", :"**", :"<<=", :">>=", :"~", :"~@", :"[]", :"[]=", :"[", :"]", :"::", :"<=>", :"=>", :"||=", :"&&=", :"===", :";"]
  it_lexes "!@foo", :"!"
  it_lexes "+@foo", :"+"
  it_lexes "-@foo", :"-"
  it_lexes_const "Foo"
  it_lexes_instance_var "@foo"
  it_lexes_globals ["$foo", "$FOO", "$_foo", "$foo123", "$~"]
  it_lexes_symbols [":foo", ":foo!", ":foo?", ":\"foo\""]
  it_lexes_regex "/foo/"
  it_lexes_global_match ["$1", "$10"]

  it "lexes not instance var" do
    lexer = Crystal::Lexer.new "!@foo"
    token = lexer.next_token
    token.type.should eq(:"!")
    token = lexer.next_token
    token.type.should eq(:INSTANCE_VAR)
    token.value.should eq("@foo")
  end

  it "lexes space after keyword" do
    lexer = Crystal::Lexer.new "end 1"
    token = lexer.next_token
    token.type.should eq(:IDENT)
    token.value.should eq(:end)
    token = lexer.next_token
    token.type.should eq(:SPACE)
  end

  it "lexes space after char" do
    lexer = Crystal::Lexer.new "'a' "
    token = lexer.next_token
    token.type.should eq(:CHAR)
    token.value.should eq('a')
    token = lexer.next_token
    token.type.should eq(:SPACE)
  end

  it "lexes comment and token" do
    lexer = Crystal::Lexer.new "# comment\n="
    token = lexer.next_token
    token.type.should eq(:NEWLINE)
    token = lexer.next_token
    token.type.should eq(:"=")
  end

  it "lexes comment at the end" do
    lexer = Crystal::Lexer.new "# comment"
    token = lexer.next_token
    token.type.should eq(:EOF)
  end

  it "lexes __LINE__" do
    lexer = Crystal::Lexer.new "__LINE__"
    token = lexer.next_token
    token.type.should eq(:INT)
    token.value.should eq(1)
  end

  it "lexes __FILE__" do
    lexer = Crystal::Lexer.new "__FILE__"
    lexer.filename = "foo"
    token = lexer.next_token
    token.type.should eq(:STRING)
    token.value.should eq("foo")
  end

  it "lexes dot and ident" do
    lexer = Crystal::Lexer.new ".read"
    token = lexer.next_token
    token.type.should eq(:".")
    token = lexer.next_token
    token.type.should eq(:IDENT)
    token.value.should eq("read")
    token = lexer.next_token
    token.type.should eq(:EOF)
  end
end