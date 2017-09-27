require 'minitest/autorun'
require 'buildar'

describe Buildar do
  describe :bump do
    it "must handle empty version" do
      Buildar.bump(:build, '').must_equal '0.0.0.1'
      Buildar.bump(:patch, '').must_equal '0.0.1'
      Buildar.bump(:minor, '').must_equal '0.1'
      Buildar.bump(:major, '').must_equal '1'
    end

    it "must handle 0 version" do
      Buildar.bump(:build, '0').must_equal '0.0.0.1'
      Buildar.bump(:patch, '0').must_equal '0.0.1'
      Buildar.bump(:minor, '0').must_equal '0.1'
      Buildar.bump(:major, '0').must_equal '1'
    end

    it "must handle 1 version" do
      Buildar.bump(:build, '1').must_equal '1.0.0.1'
      Buildar.bump(:patch, '1').must_equal '1.0.1'
      Buildar.bump(:minor, '1').must_equal '1.1'
      Buildar.bump(:major, '1').must_equal '2'
    end

    it "must handle 0.1 version" do
      Buildar.bump(:build, '0.1').must_equal '0.1.0.1'
      Buildar.bump(:patch, '0.1').must_equal '0.1.1'
      Buildar.bump(:minor, '0.1').must_equal '0.2'
      Buildar.bump(:major, '0.1').must_equal '1.0'
    end

    it "must handle 0.1.2 version" do
      Buildar.bump(:build, '0.1.2').must_equal '0.1.2.1'
      Buildar.bump(:patch, '0.1.2').must_equal '0.1.3'
      Buildar.bump(:minor, '0.1.2').must_equal '0.2.0'
      Buildar.bump(:major, '0.1.2').must_equal '1.0.0'
    end

    it "must handle 9.9.9 version" do
      Buildar.bump(:build, '9.9.9').must_equal '9.9.9.1'
      Buildar.bump(:patch, '9.9.9').must_equal '9.9.10'
      Buildar.bump(:minor, '9.9.9').must_equal '9.10.0'
      Buildar.bump(:major, '9.9.9').must_equal '10.0.0'
    end

    it "must handle 0.1.2.3 version" do
      Buildar.bump(:build, '0.1.2.3').must_equal '0.1.2.4'
      Buildar.bump(:patch, '0.1.2.3').must_equal '0.1.3.0'
      Buildar.bump(:minor, '0.1.2.3').must_equal '0.2.0.0'
      Buildar.bump(:major, '0.1.2.3').must_equal '1.0.0.0'
    end
  end
end
