require 'spec_helper'

describe "Intermediate Representation Strinfication" do

  it "converts literal integers" do
    r(:lit, 5).to_s.should.equal "5"
  end

  it "converts literal strings" do
    r(:lit, "hello").to_s.should.equal "\"hello\""
  end

  it "converts local getvar expressions" do
    r(:getvar, "somevar").to_s.should.equal "somevar"
  end

  it "converts ivar getvar expressions" do
    r(:getvar, "@some_ivar").to_s.should.equal "@some_ivar"
  end

  it "converts constant getvar expressions" do
    r(:getvar, :SOME_CONSTANT).to_s.should.equal "SOME_CONSTANT"
  end

  it "converts local setvar expressions" do
    r(:setvar, "some_var", "some_value").to_s.should.equal "some_var = some_value"
  end

  it "converts constant setvar expressions" do
    r(:setvar, "A_CONSTANT", r(:lit, 5)).to_s.should.equal "A_CONSTANT = 5"
  end

  it "converts splat expressions" do
    r(:splat, r(:lit, [1, 2, 3, 4])).to_s.should.equal "*[1, 2, 3, 4]"
  end

  it "converts array literal expressions" do
    r(:array, [r(:lit, 3), r(:lit, :hello)]).to_s.should.equal "[3, :hello]"
  end

  it "converts inclusive range literal expressions" do
    r(:range, r(:lit, "aaa"), r(:lit, "zzz"), true).to_s.should.equal "(\"aaa\"..\"zzz\")"
  end

  it "converts exclusive range literal expressions" do
    r(:range, r(:lit, 3), r(:lit, 300), false).to_s.should.equal "(3...300)"
  end

  it "converts a simple infix expression" do
    r(:infix, :+, [r(:lit, 3), r(:lit, 4)]).to_s.should.equal "3 + 4"
  end

  it "converts an infix expression with many arguments" do
    r(:infix, :*, [r(:lit, "hi"), r(:lit, 3), r(:lit, 20)]).to_s.should.equal "\"hi\" * 3 * 20"
  end

  it "converts a complex infix expression, introducing parentheses" do
    r(:infix, :+, [r(:lit, 3), r(:setvar, "avar", 10)]).to_s.should.equal("(3 + (avar = 10))")
  end

  it "converts a hash literal" do
    ir = r(:hash, [[r(:lit, :key), r(:lit, :value)], [r(:lit, "hello"), r(:lit, "world")]])
    ir.to_s.should.equal "{:key => :value, \"hello\" => \"world\"}"
  end

  it "converts nil literals" do
    r(:nil).to_s.should.equal "nil"
  end

  it "converts not expressions" do
    r(:not, r(:lit, "something")).to_s.should.equal "!\"something\""
  end

  it "converts array reference expressions" do
    r(:aref, r(:getvar, :ahash), r(:lit, :akey)).to_s.should.equal "ahash[:akey]"
  end

  it "converts array setting expressions" do
    r(:aset, r(:getvar, :ahash), r(:lit, :akey), r(:lit, 5)).to_s.should.equal "ahash[:akey] = 5"
  end

  it "converts blocks with no arguments" do
    ir = r(:block, "", Reversal::IRList.new([r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))]))
    ir.to_s.should.equal(" do\n  avar\n  avar = 5\nend")
  end

  it "converts blocks with arguments" do
    ir = r(:block, "arg1, *rest", Reversal::IRList.new([r(:getvar, "avar"), r(:setvar, "avar", r(:lit, 5))]))
    ir.to_s.should.equal(" do |arg1, *rest|\n  avar\n  avar = 5\nend")
  end

  it "converts method calls with no receiver or arguments" do
    ir = r(:send, :sillymethod, :implicit, [], nil)
    ir.to_s.should.equal("sillymethod")
  end

  it "converts method calls with a receiver but no arguments" do
    ir = r(:send, :sillymethod, r(:lit, 5), [], nil)
    ir.to_s.should.equal("5.sillymethod")
  end

  it "converts method calls with a receiver and a simple argument" do
    ir = r(:send, :sillymethod, r(:lit, "hello"), [r(:getvar, "arg")], nil)
    ir.to_s.should.equal("\"hello\".sillymethod(arg)")
  end
end