require 'test/unit'
require './test_config'

class TC_TypelibGCCXML < Test::Unit::TestCase
    include Typelib

    attr_reader :cxx_test_dir

    def setup
        @cxx_test_dir = File.expand_path('cxx_import_tests', File.dirname(__FILE__))
    end

    def test_tokenize_template
        assert_equal ['int'],
            Typelib::GCCXMLLoader.template_tokenizer('int')
        assert_equal ['std::vector', '<', 'int', ',', 'std::allocator', '<', 'int', '>', '>'],
            Typelib::GCCXMLLoader.template_tokenizer('std::vector<int, std::allocator<int> >')

        assert_equal ['std::vector', '<', 'std::vector', '<', 'int', ',', 'std::allocator', '<', 'int', '>', '>', ',', 'std::allocator', '<', 'std::vector', '<', 'int', ',', 'std::allocator', '<', 'int', '>', '>', '>', '>'],
            Typelib::GCCXMLLoader.template_tokenizer('std::vector <std::vector <int ,std::allocator<int>>, std::allocator< std::vector<int , std::allocator <int>>      > >')

        assert_equal ['std::vector', '<', 'std::vector', '<', 'int', ',', 'std::allocator', '<', 'int', '>', '>', ',', 'std::allocator', '<', 'std::vector', '<', 'int', ',', 'std::allocator', '<', 'int', '>', '>', '>', '>', '::size_t'],
            Typelib::GCCXMLLoader.template_tokenizer('std::vector <std::vector <int ,std::allocator<int>>, std::allocator< std::vector<int , std::allocator <int>>      > >::size_t')
    end

    def test_collect_template_arguments
        tokenized = %w{< < bla , 6 , blo > , test > ::int>}
        assert_equal [%w{< bla , 6 , blo >}, %w{test}],
            Typelib::GCCXMLLoader.collect_template_arguments(tokenized)

    end

    def test_cxx_to_typelib
        cxx_name = 'std::vector <std::vector <int ,std::allocator<int>>, std::allocator< std::vector<int , std::allocator <int>>      > >::size_t'
        assert_equal '/std/vector</std/vector</int>>/size_t',
            Typelib::GCCXMLLoader.cxx_to_typelib(cxx_name)
    end

    def test_parse_template
        assert_equal ['int', []],
            Typelib::GCCXMLLoader.parse_template('int')
        assert_equal ['std::vector', ['int', 'std::allocator<int>']],
            Typelib::GCCXMLLoader.parse_template('std::vector<int, std::allocator<int> >')
        assert_equal ['std::vector', ['std::vector<int,std::allocator<int>>', 'std::allocator<std::vector<int,std::allocator<int>>>']],
            Typelib::GCCXMLLoader.parse_template('std::vector <std::vector <int ,std::allocator<int>>, std::allocator< std::vector<int , std::allocator <int>>      > >')

    end

    def test_import_non_virtual_inheritance
        reg = Typelib::Registry.import File.join(cxx_test_dir, 'non_virtual_inheritance.h')
        type = reg.get('/Derived')
        assert_equal ['/FirstBase', '/SecondBase'], type.metadata.get('base_classes')

        field_type = reg.get('/uint64_t')
        expected = [
            ['first', field_type, 0],
            ['second', field_type, 8],
            ['third', field_type, 16]
        ]
        assert_equal expected, type.fields.map { |name, field_type| [name, field_type, type.offset_of(name)] }
    end

    def test_import_virtual_methods
        reg = Typelib::Registry.import File.join(cxx_test_dir, 'virtual_methods.h')
        assert !reg.include?('/Class')
    end

    def test_import_virtual_inheritance
        reg = Typelib::Registry.import File.join(cxx_test_dir, 'virtual_inheritance.h')
        assert reg.include?('/Base')
        assert !reg.include?('/Derived')
    end

    def test_import_private_base_class
        reg = Typelib::Registry.import File.join(cxx_test_dir, 'private_base_class.h')
        assert reg.include?('/Base')
        assert !reg.include?('/Derived')
    end

    def test_import_ignored_base_class
        reg = Typelib::Registry.import File.join(cxx_test_dir, 'ignored_base_class.h')
        assert !reg.include?('/Base')
        assert !reg.include?('/Derived')
    end
end

