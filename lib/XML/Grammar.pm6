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
token value { <-[\"]>+ }

regex doctypedecl {
  '<!DOCTYPE' \s+ <name> $<content>=[.*?] '>'
}

regex element {
  '<' <name> <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>'
  ]
}

rule attribute {
   <name> '=' '"' $<value>=[.*?] '"' 
}

rule child {
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

