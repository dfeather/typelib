require 'typelib/test'
require_relative './cxx_common_tests'

class TC_CXX_Clang < Minitest::Test
    include Typelib
    include CXXCommonTests

    def setup
        super
        @loader = Typelib::CXX::CXX_LOADERS['clang']
    end
end

