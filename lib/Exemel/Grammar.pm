## Grammar originally based on krunen's XML::Grammar::Document.
## With several modifications to make it work with the new Rakudo,
## and to make it more optimized for the Exemel model.

grammar Exemel::Grammar;

rule TOP {
  ^
  <xmldecl>?      [ <comment> | <pi> ]*
  <doctypedecl>?  [ <comment> | <pi> ]*
  <root=element>  [ <comment> | <pi> ]*
  $
}

regex comment { '<!--' <content> '-->' }
regex pi { '<?' <content> '?>' }
token content { .*? }

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
  '<!DOCTYPE' \s+ <name> <content> '>'
}

rule element {
  '<' <name> <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>'
  ]
}

## The \s+ below should not be necessary. Remove it once this is fixed in nom.
rule attribute {
   \s+ <name> '=' '"' <value>? '"'
}

rule child {
  | <element>
  | <cdata>
  | <text=textnode>
  | <comment>
  | <pi>
}

regex cdata {
 '<![CDATA[' <content> ']]>'
}

token textnode { <-[<]>+ }
token pident {
  | <.ident>
  | '-'
}
token name { <pident>+ [ ':' <pident>+ ]? }

