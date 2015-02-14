grammar XML::Grammar;

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

token version { 'version' '=' '"' <value> '"' }
token encoding { 'encoding' '=' '"' <value> '"' }

proto token char {*}
token char:sym<common> { <!before $*STOPPER | '&'> .+? <?before $*STOPPER | '&'> { make ~$/ } }
token char:sym<dec> { '&#' $<dec>=[<digit>+] ';' { make $<dec>.Int.chr } }
token char:sym<hex>{ '&#x' $<hex>=[<xdigit>+] ';' { make :16(~$<hex>).chr } }
token char:sym<quot> { '&quot;' { make '"' } }
token char:sym<lt> { '&lt;' { make '<' } }
token char:sym<gt> { '&gt;' { make '>' } }
token char:sym<apos> { '&apos;' { make "'" } }
token char:sym<amp> { '&amp;' { make '&' } }
token value($*STOPPER = '"') {
    | <?before $*STOPPER>
    | <char>+
}
token value-sq($*STOPPER = "'") {
    | <?before $*STOPPER>
    | <char>+
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
                | '"' <value> '"'
                | \' $<value>=<value-sq> \'
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
  | <.ident>
  | '-'
}
token name { <.pident>+ [ ':' <.pident>+ ]? }
