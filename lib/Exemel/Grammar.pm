## Grammar based on krunen's XML::Grammar::Document.
## With modifications to make it work with the Exemel model.

grammar Exemel::Grammar;

rule TOP {
  ^
  <xmldecl>?      [ <comment> | <pi> ]*
  <doctypedecl>?  [ <comment> | <pi> ]*
  <root=element>  [ <comment> | <pi> ]*
  $
}

token comment { '<!--' ~ '-->' <content> }
token pi { '<?' ~ '?>' <content> }
token content { .*? }

rule xmldecl {
   '<?xml'
    <version>
    <encoding>?
   '?>'
}

token version { 'version' '=' '"' ~ '"' <value> }
token encoding { 'encoding' '=' '"' ~ '"' <value> }
token value { <-[\"]>+ }

rule doctypedecl {
  '<!DOCTYPE ' <name> ~ '>' <content>
}

rule element {
  '<' <name> <attribute>*
  [
  | '/>'
  | '>' <child>* '</' $<name> '>'
  ]
}

rule attribute {
    <name> '=' '"' ~ '"' <value>
}

rule child {
  | <element>
  | <cdata>
  | <text=textnode>
  | <comment>
  | <pi>
}

token cdata {
 '<![CDATA[' ~ ']]>' <content>
}

token textnode { <-[<]>+ }
token name { <.alpha> <.ident>+ [ ':' <.ident>+ ]? }

