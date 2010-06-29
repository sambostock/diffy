require 'spec'
require File.join(File.dirname(__FILE__), '..', 'lib', 'dirb')

describe Dirb::Diff do
  describe "#to_s" do
    describe "with no line different" do
      before do
        @string1 = "foo\nbar\nbang\n"
        @string2 = "foo\nbar\nbang\n"
      end

      it "should show everything" do
        Dirb::Diff.new(@string1, @string2).to_s.should == <<-DIFF
 foo
 bar
 bang
        DIFF
      end
    end
    describe "with one line different" do
      before do
        @string1 = "foo\nbar\nbang\n"
        @string2 = "foo\nbang\n"
      end

      it "should show one line removed" do
        Dirb::Diff.new(@string1, @string2).to_s.should == <<-DIFF
 foo
-bar
 bang
        DIFF
      end

      it "to_s should accept a format key" do
        Dirb::Diff.new(@string1, @string2).to_s(:color).
          should == " foo\n\n\e[31m-bar\e[0m\n bang\n"
      end

      it "should accept a default format option" do
        old_format = Dirb::Diff.default_format
        Dirb::Diff.default_format = :color
        Dirb::Diff.new(@string1, @string2).to_s.
          should == " foo\n\n\e[31m-bar\e[0m\n bang\n"
        Dirb::Diff.default_format = old_format
      end

      it "should show one line added" do
        Dirb::Diff.new(@string2, @string1).to_s.should == <<-DIFF
 foo
+bar
 bang
        DIFF
      end
    end

    describe "with one line changed" do
      before do
        @string1 = "foo\nbar\nbang\n"
        @string2 = "foo\nbong\nbang\n"
      end
      it "should show one line added and one removed" do
        Dirb::Diff.new(@string1, @string2).to_s.should == <<-DIFF
 foo
-bar
+bong
 bang
        DIFF
      end
    end

    describe "with totally different strings" do
      before do
        @string1 = "foo\nbar\nbang\n"
        @string2 = "one\ntwo\nthree\n"
      end
      it "should show one line added and one removed" do
        Dirb::Diff.new(@string1, @string2).to_s.should == <<-DIFF
-foo
-bar
-bang
+one
+two
+three
        DIFF
      end
    end

    describe "with a somewhat complicated diff" do
      before do
        @string1 = "foo\nbar\nbang\nwoot\n"
        @string2 = "one\ntwo\nthree\nbar\nbang\nbaz\n"
        @diff = Dirb::Diff.new(@string1, @string2)
      end
      it "should show one line added and one removed" do
        @diff.to_s.should == <<-DIFF
-foo
+one
+two
+three
 bar
 bang
-woot
+baz
        DIFF
      end

      it "should make an awesome html diff" do
        @diff.to_s(:html).should == <<-HTML
<ul class="diff">
  <li class="del"><del>foo</del></li>
  <li class="ins"><ins>one</ins></li>
  <li class="ins"><ins>two</ins></li>
  <li class="ins"><ins>three</ins></li>
  <li class="unchanged"><span>bar</span></li>
  <li class="unchanged"><span>bang</span></li>
  <li class="del"><del>woot</del></li>
  <li class="ins"><ins>baz</ins></li>
</ul>
        HTML
      end

      it "should accept overrides to diff's options" do
        @diff = Dirb::Diff.new(@string1, @string2, "--rcs")
        @diff.to_s.should == <<-DIFF
d1 1
a1 3
one
two
three
d4 1
a4 1
baz
          DIFF
      end
    end
  end
end
