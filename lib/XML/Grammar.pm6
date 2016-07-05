unit grammar XML::Grammar;

rule TOP {
  ^
  <xmldecl>?      [ <comment> | <pi> ]*
  <doctypedecl>?  [ <comment> | <pi> ]*
  <root=element>  [ <comment> | <pi> ]*
  $
}

regex comment { '<!--' $<content>=[.*?] '-->' }
regex pi { '<?' $<content>=[.*?] '?>' }

rule xmldecl {
   '<?xml'
    <version>
    <encoding>?
   '?>'
}

token version { 'version' '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}
token encoding { 'encoding' '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}

proto token char {*}
token char:sym<common> {
    (||   [ <?{ $*STOPPER eq '"' }>
           <!["&]> .+? <?["&]> ]
    ||   [ <?{ $*STOPPER eq "'" }>
           <!['&]> .+? <?['&]> ])
           { make ~$/ }
}
token char:sym<dec> { '&#' $<dec>=[<digit>+] ';' { make $<dec>.Int.chr } }
token char:sym<hex>{ '&#x' $<hex>=[<xdigit>+] ';' { make :16(~$<hex>).chr } }
token char:sym<quot> { '&quot;' { make '"' } }
token char:sym<lt> { '&lt;' { make '<' } }
token char:sym<gt> { '&gt;' { make '>' } }
token char:sym<apos> { '&apos;' { make "'" } }
token char:sym<amp> { '&amp;' { make '&' } }
token value($*STOPPER = '"') {
    \"
    [
    | \"
    | <char>+ \"
    ]
}
token value-sq($*STOPPER = "'") {
    \'
    [
    | \'
    | <char>+ \'
    ]
}

regex doctypedecl {
  '<!DOCTYPE' \s+ <name> $<content>=[.*?] '>'
}

token element {
  '<' \s* <name> \s* <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>'
  ]
}

rule attribute {
   <name> '=' [
                | <value>
                | $<value>=<value-sq>
              ]
}

token child {
  | <element>
  | <cdata>
  | <text=textnode>
  | <comment>
  | <pi>
}

regex cdata {
 '<![CDATA[' $<content>=[.*?] ']]>'
}

token textnode { <-[<]>+ }
token pident {
  <!before \d> [ \d+ <.ident>* || <.ident>+ ]+ % '-'
}
token name { <.pident>+ [ ':' <.pident>+ ]? }
