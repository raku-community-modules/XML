## XML -- Object Oriented XML Library
use XML::Element;
use XML::Document;

module XML {
    sub from-xml (Str $xml-string) is export {
        XML::Document.new($xml-string);
    }

    sub from-xml-stream (IO::Handle $input) is export {
        XML::Document.new($input.slurp-rest);
    }

    sub from-xml-file (IO::Path() $file) is export {
        XML::Document.load($file);
    }

    sub make-xml (Str $name, *@contents, *%attribs) is export {
        XML::Element.craft($name, |@contents, |%attribs);
    }

    multi sub open-xml (IO::Path(Str) $src where :f) is export {
        from-xml-file $src
    }

    multi sub open-xml (Str $src) is export {
        from-xml $src
    }

    multi sub open-xml (IO::Handle $src) is export {
        from-xml-stream $src
    }
}

# vim: expandtab shiftwidth=4
